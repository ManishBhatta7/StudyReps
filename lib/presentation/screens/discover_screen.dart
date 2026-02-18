import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import '../../data/repositories/videos_repository.dart';
import '../providers/video_feed_provider.dart';
import 'swipe_gated_feed_screen.dart';

// ── Discover Providers ──

/// Search query state
final discoverSearchProvider = StateProvider<String>((ref) => '');

/// Selected category filter
final discoverCategoryProvider = StateProvider<String?>((ref) => null);

/// Search results (from Supabase with mock fallback)
final discoverSearchResultsProvider = FutureProvider<List<VideoModel>>((ref) async {
  final query = ref.watch(discoverSearchProvider);
  if (query.isEmpty) return [];

  try {
    final repo = ref.read(videosRepositoryProvider);
    final results = await repo.searchVideos(query);
    if (results.isNotEmpty) return results;
  } catch (_) {}

  // Fallback: search mock data locally
  final allVideos = ref.read(mockVideosProvider);
  final q = query.toLowerCase();
  return allVideos
      .where((v) =>
          v.title.toLowerCase().contains(q) ||
          v.subject.toLowerCase().contains(q) ||
          v.creatorName.toLowerCase().contains(q) ||
          v.tags.any((t) => t.toLowerCase().contains(q)))
      .toList();
});

/// Trending videos (most liked / viewed)
/// Trending videos (most liked / viewed)
final trendingVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final category = ref.watch(discoverCategoryProvider);

  List<VideoModel> videos = [];
  try {
    final repo = ref.read(videosRepositoryProvider);
    // TODO: Pass category to repo.fetchVideos if backend supports it
    // For now, fetch generic trending and filter locally
    videos = await repo.fetchVideos(limit: 20); 
  } catch (_) {}

  // Fallback to mock data if empty
  if (videos.isEmpty) {
    videos = ref.read(mockVideosProvider);
  }

  // Filter by category if selected
  if (category != null && category.isNotEmpty) {
    videos = videos.where((v) => v.subject.toLowerCase() == category.toLowerCase()).toList();
  }

  return videos.take(10).toList();
});

/// Category-filtered videos
final categoryVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final category = ref.watch(discoverCategoryProvider);
  if (category == null || category.isEmpty) {
    return ref.read(mockVideosProvider);
  }

  try {
    final repo = ref.read(videosRepositoryProvider);
    final videos = await repo.fetchBySubject(category);
    if (videos.isNotEmpty) return videos;
  } catch (_) {}

  return ref.read(mockVideosProvider)
      .where((v) => v.subject.toLowerCase().contains(category.toLowerCase()))
      .toList();
});



// ── Discover Screen ──

/// Discover Screen — Explore and search educational content
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _isSearchActive = false;

  final List<_CategoryItem> _categories = [
    _CategoryItem('All', Icons.explore_rounded, [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]),
    _CategoryItem('Physics', Icons.rocket_launch_rounded, [const Color(0xFFEC4899), const Color(0xFFF43F5E)]),
    _CategoryItem('Math', Icons.calculate_rounded, [const Color(0xFF3B82F6), const Color(0xFF6366F1)]),
    _CategoryItem('Chemistry', Icons.science_rounded, [const Color(0xFF10B981), const Color(0xFF059669)]),
    _CategoryItem('Biology', Icons.biotech_rounded, [const Color(0xFFF59E0B), const Color(0xFFEF4444)]),
    _CategoryItem('History', Icons.history_edu_rounded, [const Color(0xFF8B5CF6), const Color(0xFFA855F7)]),
    _CategoryItem('Literature', Icons.auto_stories_rounded, [const Color(0xFF14B8A6), const Color(0xFF06B6D4)]),
    _CategoryItem('CS', Icons.code_rounded, [const Color(0xFF64748B), const Color(0xFF475569)]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) { // Saved Tab
        ref.invalidate(savedVideosProvider);
      }
    });
    _searchFocusNode.addListener(() {
      setState(() => _isSearchActive = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(discoverSearchProvider.notifier).state = query;
  }

  void _onCategoryTap(String category) {
    final current = ref.read(discoverCategoryProvider);
    if (category == 'All' || current == category) {
      ref.read(discoverCategoryProvider.notifier).state = null;
    } else {
      ref.read(discoverCategoryProvider.notifier).state = category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(discoverSearchProvider);
    final selectedCategory = ref.watch(discoverCategoryProvider);

    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Search Bar ──
            _buildSearchBar(),

            // ── Category Chips ──
            _buildCategoryChips(selectedCategory),

            // ── Content Area ──
            Expanded(
              child: searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ).createShader(rect),
            child: const Text(
              'Discover',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // Saved Videos Button
          Container(
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StudyRepsTheme.borderSubtle),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.bookmark_rounded,
                color: StudyRepsTheme.accentCyan,
                size: 22,
              ),
              onPressed: () => _showSavedVideos(context),
              tooltip: 'Saved Videos',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _isSearchActive
              ? StudyRepsTheme.bgTertiary
              : StudyRepsTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearchActive
                ? StudyRepsTheme.primaryIndigo.withOpacity(0.5)
                : StudyRepsTheme.borderSubtle,
            width: _isSearchActive ? 1.5 : 1,
          ),
          boxShadow: _isSearchActive
              ? [
                  BoxShadow(
                    color: StudyRepsTheme.primaryIndigo.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: StudyRepsTheme.textPrimary, fontSize: 15),
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Search subjects, topics, creators...',
            hintStyle: TextStyle(
              color: StudyRepsTheme.textMuted.withOpacity(0.6),
              fontSize: 15,
            ),
            prefixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearchActive ? Icons.search_rounded : Icons.search_rounded,
                color: _isSearchActive
                    ? StudyRepsTheme.primaryIndigo
                    : StudyRepsTheme.textMuted,
                key: ValueKey(_isSearchActive),
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: StudyRepsTheme.textMuted,
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                      _searchFocusNode.unfocus();
                    },
                  )
                : Icon(Icons.tune_rounded, color: StudyRepsTheme.textMuted, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.05);
  }

  Widget _buildCategoryChips(String? selectedCategory) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = (selectedCategory == null && cat.name == 'All') ||
              selectedCategory == cat.name;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => _onCategoryTap(cat.name),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: cat.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : StudyRepsTheme.bgSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : StudyRepsTheme.borderSubtle,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cat.gradientColors.first.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      cat.icon,
                      color: isSelected
                          ? Colors.white
                          : StudyRepsTheme.textMuted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected
                          ? StudyRepsTheme.textPrimary
                          : StudyRepsTheme.textMuted,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (80 + index * 40).ms).slideY(begin: 0.15);
        },
      ),
    );
  }

  // ── Main Content (Tabs: Trending / For You / Saved) ──

  Widget _buildMainContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: StudyRepsTheme.bgSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: StudyRepsTheme.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: '🔥 Trending'),
              Tab(text: '✨ For You'),
              Tab(text: '📚 Saved'),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTrendingTab(),
              _buildForYouTab(),
              _buildSavedTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Trending Tab ──

  Widget _buildTrendingTab() {
    final trendingAsync = ref.watch(trendingVideosProvider);

    return trendingAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudyRepsTheme.primaryIndigo),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: StudyRepsTheme.textMuted, size: 48),
            const SizedBox(height: 12),
            Text('Could not load trending', style: TextStyle(color: StudyRepsTheme.textMuted)),
          ],
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState('No trending videos yet', Icons.trending_up_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return _buildVideoListTile(videos[index], index, showRank: true, onTap: () {
              _navigateToVideo(videos, index);
            })
                .animate()
                .fadeIn(delay: (index * 60).ms)
                .slideX(begin: 0.05);
          },
        );
      },
    );
  }

  // ── For You Tab ──

  Widget _buildForYouTab() {
    final categoryAsync = ref.watch(categoryVideosProvider);

    return categoryAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudyRepsTheme.primaryIndigo),
      ),
      error: (e, _) => Center(
        child: Text('Error loading content', style: TextStyle(color: StudyRepsTheme.textMuted)),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState('No videos found for this category', Icons.category_rounded);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) =>
              _buildVideoGridCard(videos[index], index, onTap: () {
                _navigateToVideo(videos, index);
              })
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .scale(begin: const Offset(0.95, 0.95)),
        );
      },
    );
  }

  // ── Saved Tab ──

  Widget _buildSavedTab() {
    final savedAsync = ref.watch(savedVideosProvider);

    return savedAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudyRepsTheme.accentCyan),
      ),
      error: (e, _) => Center(
        child: Text('Could not load saved videos', style: TextStyle(color: StudyRepsTheme.textMuted)),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState(
            'No saved videos yet\nBookmark videos from the feed!',
            Icons.bookmark_border_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          itemBuilder: (context, index) =>
              _buildVideoListTile(videos[index], index, showSaved: true, onTap: () {
                _navigateToVideo(videos, index);
              })
                  .animate()
                  .fadeIn(delay: (index * 60).ms)
                  .slideX(begin: 0.05),
        );
      },
    );
  }

  // ── Search Results ──

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(discoverSearchResultsProvider);

    return searchAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudyRepsTheme.primaryIndigo),
      ),
      error: (e, _) => Center(
        child: Text('Search failed', style: TextStyle(color: StudyRepsTheme.textMuted)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return _buildEmptyState(
            'No results found\nTry a different search term',
            Icons.search_off_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) =>
              _buildVideoListTile(results[index], index, onTap: () {
                _navigateToVideo(results, index);
              })
                  .animate()
                  .fadeIn(delay: (index * 40).ms)
                  .slideY(begin: 0.03),
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  //  SHARED WIDGETS
  // ══════════════════════════════════════════════

  /// Rich list tile for a video — used in Trending, Search, Saved
  Widget _buildVideoListTile(VideoModel video, int index,
      {bool showRank = false, bool showSaved = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: Row(
          children: [
            // Rank Badge or Thumbnail
            if (showRank)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: index < 3
                      ? LinearGradient(
                          colors: [
                            [const Color(0xFFFFD700), const Color(0xFFFFC107)],
                            [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
                            [const Color(0xFFCD7F32), const Color(0xFFA0522D)],
                          ][index],
                        )
                      : null,
                  color: index >= 3 ? StudyRepsTheme.bgTertiary : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index < 3 ? Colors.white : StudyRepsTheme.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            // Video Thumbnail
            Container(
              width: 80,
              height: 56,
              decoration: BoxDecoration(
                color: StudyRepsTheme.bgTertiary,
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    StudyRepsTheme.primaryIndigo.withOpacity(0.3),
                    StudyRepsTheme.bgTertiary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.play_circle_filled_rounded,
                      color: Colors.white54,
                      size: 28,
                    ),
                  ),
                  // Difficulty badge
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _difficultyColor(video.difficultyLevel),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'L${video.difficultyLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Video Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      color: StudyRepsTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '@${video.creatorName}',
                        style: TextStyle(
                          color: StudyRepsTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: StudyRepsTheme.primaryIndigo.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.subject,
                          style: const TextStyle(
                            color: StudyRepsTheme.primaryIndigo,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (video.likesCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 12, color: StudyRepsTheme.errorPink),
                          const SizedBox(width: 4),
                          Text(
                            '${video.likesCount}',
                            style: TextStyle(
                              color: StudyRepsTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Trailing: Saved badge or chevron
            if (showSaved)
              const Icon(Icons.bookmark_rounded, color: StudyRepsTheme.accentCyan, size: 20)
            else
              const Icon(Icons.chevron_right_rounded, color: StudyRepsTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  /// Grid card for "For You" tab
  Widget _buildVideoGridCard(VideoModel video, int index, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _subjectColor(video.subject).withOpacity(0.4),
                      StudyRepsTheme.bgTertiary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Play icon
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),

                    // Subject Tag
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _subjectColor(video.subject),
                              _subjectColor(video.subject).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Difficulty indicator
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.circle,
                              size: 6,
                              color: i < video.difficultyLevel
                                  ? _difficultyColor(video.difficultyLevel)
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Likes
                    if (video.likesCount > 0)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_rounded, size: 10, color: Colors.pinkAccent),
                              const SizedBox(width: 3),
                              Text(
                                '${video.likesCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: StudyRepsTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: StudyRepsTheme.primaryIndigo.withOpacity(0.2),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: StudyRepsTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            video.creatorName,
                            style: TextStyle(
                              color: StudyRepsTheme.textMuted,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: StudyRepsTheme.textMuted, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StudyRepsTheme.textMuted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ── Navigation ──

  void _navigateToVideo(List<VideoModel> contextList, int index) {
    // Navigate to the video in a dedicated feed screen
    // This allows playing the clicked video and swiping to others in the list
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeGatedFeedScreen(
          initialVideos: contextList,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showSavedVideos(BuildContext context) {
    _tabController.animateTo(2); // Switch to Saved tab
  }

  // ── Helpers ──

  Color _subjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('physics') || s.contains('force')) return const Color(0xFFEC4899);
    if (s.contains('math') || s.contains('calculus')) return const Color(0xFF3B82F6);
    if (s.contains('chem')) return const Color(0xFF10B981);
    if (s.contains('bio')) return const Color(0xFFF59E0B);
    if (s.contains('history')) return const Color(0xFF8B5CF6);
    if (s.contains('lit')) return const Color(0xFF14B8A6);
    if (s.contains('computer') || s.contains('cs') || s.contains('code')) return const Color(0xFF64748B);
    return StudyRepsTheme.primaryIndigo;
  }

  Color _difficultyColor(int level) {
    return [
      const Color(0xFF22C55E), // 1 - Easy
      const Color(0xFF3B82F6), // 2
      const Color(0xFFF59E0B), // 3
      const Color(0xFFEF4444), // 4
      const Color(0xFFDC2626), // 5 - Hardest
    ][level.clamp(1, 5) - 1];
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;

  _CategoryItem(this.name, this.icon, this.gradientColors);
}
