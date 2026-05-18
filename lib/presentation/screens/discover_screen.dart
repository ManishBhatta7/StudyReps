import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/study_reps_theme.dart';
import '../../domain/models/video_model.dart';
import '../providers/video_feed_provider.dart';
import 'swipe_gated_feed_screen.dart';

// ── Discover Providers ──

final discoverSearchProvider = StateProvider<String>((ref) => '');
final discoverCategoryProvider = StateProvider<String?>((ref) => null);

final discoverSearchResultsProvider =
    FutureProvider<List<VideoModel>>((ref) async {
  final query = ref.watch(discoverSearchProvider);
  if (query.isEmpty) return [];

  try {
    final repo = ref.read(videosRepositoryProvider);
    final results = await repo.searchVideos(query);
    if (results.isNotEmpty) return results;
  } catch (_) {}

  // Fallback: search main data source locally
  final allVideos = await ref.read(allVideosProvider.future);
  final q = query.toLowerCase();
  return allVideos
      .where((v) =>
          v.title.toLowerCase().contains(q) ||
          v.subject.toLowerCase().contains(q) ||
          v.creatorName.toLowerCase().contains(q) ||
          v.tags.any((t) => t.toLowerCase().contains(q)))
      .toList();
});

final trendingVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final category = ref.watch(discoverCategoryProvider);
  List<VideoModel> videos = [];
  try {
    final repo = ref.read(videosRepositoryProvider);
    videos = await repo.fetchVideos(limit: 20);
  } catch (_) {}

  if (videos.isEmpty) videos = await ref.read(allVideosProvider.future);

  if (category != null && category.isNotEmpty) {
    videos = videos
        .where((v) => v.subject.toLowerCase() == category.toLowerCase())
        .toList();
  }
  return videos.take(10).toList();
});

final categoryVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final category = ref.watch(discoverCategoryProvider);
  if (category == null || category.isEmpty) {
    return await ref.read(allVideosProvider.future);
  }

  try {
    final repo = ref.read(videosRepositoryProvider);
    final videos = await repo.fetchBySubject(category);
    if (videos.isNotEmpty) return videos;
  } catch (_) {}

  final fallbackVideos = await ref.read(allVideosProvider.future);
  return fallbackVideos
      .where((v) => v.subject.toLowerCase().contains(category.toLowerCase()))
      .toList();
});

// ═══ BOLDVOICE WARM PALETTE ═══
const _warmCream = StudyRepsTheme.warmCream;
const _warmCard = StudyRepsTheme.warmCard;
const _warmDarkCard = StudyRepsTheme.warmDarkCard;
const _warmOrange = StudyRepsTheme.warmOrange;
const _warmOrangeDark = StudyRepsTheme.warmOrangeDark;
const _warmGreen = StudyRepsTheme.warmGreen;
const _warmTextDark = StudyRepsTheme.warmTextDark;
const _warmTextMedium = StudyRepsTheme.warmTextMedium;
const _warmTextLight = StudyRepsTheme.warmTextLight;
const _warmBorder = StudyRepsTheme.warmBorder;
const _warmChipBg = StudyRepsTheme.warmChipBg;

// ── Discover Screen ──

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  const _CategoryItem(this.name, this.icon, this.color);
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _isSearchActive = false;

  final List<_CategoryItem> _categories = const [
    _CategoryItem('All', Icons.explore_rounded, Color(0xFFFF7043)),
    _CategoryItem('Physics', Icons.rocket_launch_rounded, Color(0xFFEC4899)),
    _CategoryItem('Math', Icons.calculate_rounded, Color(0xFF3B82F6)),
    _CategoryItem('Chemistry', Icons.science_rounded, Color(0xFF10B981)),
    _CategoryItem('Biology', Icons.biotech_rounded, Color(0xFFF59E0B)),
    _CategoryItem('History', Icons.history_edu_rounded, Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) ref.invalidate(savedVideosProvider);
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

  void _onCategoryTap(String category) {
    HapticFeedback.lightImpact();
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
      backgroundColor: _warmCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(selectedCategory),
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

  // ════════════════════════════════════
  // HEADER
  // ════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _warmTextDark,
              letterSpacing: -0.5,
            ),
          ),
          Semantics(
            button: true,
            label: 'Saved Videos',
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showSavedVideos(context);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _warmCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: _warmOrange,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Semantics(
        textField: true,
        label: 'Search for content',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _isSearchActive ? _warmCard : _warmCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isSearchActive
                  ? _warmOrange.withOpacity(0.5)
                  : _warmBorder,
              width: _isSearchActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isSearchActive
                    ? _warmOrange.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isSearchActive ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: GoogleFonts.outfit(
              color: _warmTextDark,
              fontSize: 15,
            ),
            onChanged: (val) =>
                ref.read(discoverSearchProvider.notifier).state = val,
            decoration: InputDecoration(
              hintText: 'Search subjects, topics...',
              hintStyle: GoogleFonts.outfit(
                color: _warmTextLight,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isSearchActive ? _warmOrange : _warmTextLight,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: _warmTextLight,
                      onPressed: () {
                        _searchController.clear();
                        ref.read(discoverSearchProvider.notifier).state = '';
                        _searchFocusNode.unfocus();
                      },
                    )
                  : const Icon(Icons.tune_rounded,
                      color: _warmTextLight, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ════════════════════════════════════
  // CATEGORY CHIPS — Warm styled
  // ════════════════════════════════════
  Widget _buildCategoryChips(String? selectedCategory) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = (selectedCategory == null && cat.name == 'All') ||
              selectedCategory == cat.name;

          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Filter by ${cat.name}',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () => _onCategoryTap(cat.name),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      width: isSelected ? 64 : 56,
                      height: isSelected ? 64 : 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color
                            : _warmCard,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : Border.all(color: _warmBorder),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: cat.color.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Icon(
                        cat.icon,
                        color: isSelected ? Colors.white : _warmTextMedium,
                        size: isSelected ? 28 : 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: GoogleFonts.outfit(
                        color: isSelected ? _warmTextDark : _warmTextMedium,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (150 + index * 50).ms),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════
  // TAB BAR & CONTENT
  // ════════════════════════════════════
  Widget _buildMainContent() {
    return Column(
      children: [
        // Warm Tab Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _warmChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _warmOrange,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _warmOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: _warmTextMedium,
              labelStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: '🔥 Trending'),
                Tab(text: '✨ For You'),
                Tab(text: '📚 Saved'),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ),

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

  Widget _buildTrendingTab() {
    final trendingAsync = ref.watch(trendingVideosProvider);
    return trendingAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: _warmOrange)),
      error: (e, _) => const Center(
          child: Text('Error loading content',
              style: TextStyle(color: _warmTextLight))),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState('No trending videos yet', Icons.trending_up);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) =>
              _buildVideoListTile(videos[index], index, showRank: true)
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .slideX(begin: 0.05),
        );
      },
    );
  }

  Widget _buildForYouTab() {
    final categoryAsync = ref.watch(categoryVideosProvider);
    return categoryAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: _warmOrange)),
      error: (e, _) => const Center(
          child: Text('Error loading content',
              style: TextStyle(color: _warmTextLight))),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState('No videos found', Icons.category_rounded);
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) =>
              _buildVideoGridCard(videos[index], index)
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    final savedAsync = ref.watch(savedVideosProvider);
    return savedAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: _warmOrange)),
      error: (e, _) => const Center(
          child: Text('Error loading videos',
              style: TextStyle(color: _warmTextLight))),
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyState(
              'No saved videos yet', Icons.bookmark_border_rounded);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) =>
              _buildVideoListTile(videos[index], index, showSaved: true)
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .slideY(begin: 0.05),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(discoverSearchResultsProvider);
    return searchAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: _warmOrange)),
      error: (e, _) => const Center(
          child: Text('Search failed',
              style: TextStyle(color: _warmTextLight))),
      data: (results) {
        if (results.isEmpty) {
          return _buildEmptyState('No results found', Icons.search_off_rounded);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) =>
              _buildVideoListTile(results[index], index)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.05),
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  //  SHARED WIDGETS — Warm white cards
  // ══════════════════════════════════════════════

  Widget _buildVideoListTile(VideoModel video, int index,
      {bool showRank = false, bool showSaved = false}) {
    return Semantics(
      button: true,
      label: 'Play video: ${video.title} by ${video.creatorName}',
      child: GestureDetector(
        onTap: () => _navigateToVideo([video], 0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _warmCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showRank) ...[
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: index < 3
                        ? LinearGradient(
                            colors: [
                              [
                                const Color(0xFFFFD700),
                                const Color(0xFFFFC107)
                              ],
                              [
                                const Color(0xFFC0C0C0),
                                const Color(0xFF9E9E9E)
                              ],
                              [
                                const Color(0xFFCD7F32),
                                const Color(0xFFA0522D)
                              ],
                            ][index],
                          )
                        : null,
                    color: index >= 3 ? _warmChipBg : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.outfit(
                        color: index < 3 ? Colors.white : _warmTextMedium,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],

              // Thumbnail
              Container(
                width: 88,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      _subjectColor(video.subject).withOpacity(0.7),
                      _subjectColor(video.subject).withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.play_circle_fill_rounded,
                          color: Colors.white, size: 26),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'L${video.difficultyLevel}',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: GoogleFonts.outfit(
                        color: _warmTextDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '@${video.creatorName}',
                          style: GoogleFonts.outfit(
                              color: _warmTextLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _subjectColor(video.subject).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            video.subject,
                            style: GoogleFonts.outfit(
                                color: _subjectColor(video.subject),
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (showSaved)
                const Icon(Icons.bookmark_rounded,
                    color: _warmOrange, size: 22)
              else
                const Icon(Icons.chevron_right_rounded,
                    color: _warmTextLight, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGridCard(VideoModel video, int index) {
    return GestureDetector(
      onTap: () => _navigateToVideo([video], 0),
      child: Container(
        decoration: BoxDecoration(
          color: _warmCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _subjectColor(video.subject).withOpacity(0.7),
                      _subjectColor(video.subject).withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _subjectColor(video.subject).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.subject,
                        style: GoogleFonts.outfit(
                            color: _subjectColor(video.subject),
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.title,
                      style: GoogleFonts.outfit(
                          color: _warmTextDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 12, color: _warmTextLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.creatorName,
                            style: GoogleFonts.outfit(
                                color: _warmTextLight, fontSize: 11),
                            maxLines: 1,
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

  void _navigateToVideo(List<VideoModel> videos, int index) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeGatedFeedScreen(
          initialVideos: videos,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showSavedVideos(BuildContext context) {
    _tabController.animateTo(2); // Go to "Saved" tab
  }

  Color _subjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return const Color(0xFFEC4899);
      case 'math':
        return const Color(0xFF3B82F6);
      case 'chemistry':
        return const Color(0xFF10B981);
      case 'biology':
        return const Color(0xFFF59E0B);
      case 'history':
        return const Color(0xFF8B5CF6);
      default:
        return _warmOrange;
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _warmTextLight.withOpacity(0.5), size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                color: _warmTextLight,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ],
      ).animate().fadeIn().scaleXY(begin: 0.9, duration: 400.ms),
    );
  }
}
