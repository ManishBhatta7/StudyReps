import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/study_reps_theme.dart';

/// Discover Screen
/// 
/// Browse and search for educational content by category
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _selectedCategory = 'Mathematics';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Literature',
    'History',
    'Biology',
    'Computer Science',
  ];

  final List<Map<String, dynamic>> _trendingReps = [
    {
      'title': 'Algebra II: Quadratic Formulas',
      'creator': 'Saman',
      'views': '1.2M',
      'duration': '12:34',
      'subject': 'Mathematics',
    },
    {
      'title': 'Quantum Mechanics Basics',
      'creator': 'Arian',
      'views': '850K',
      'duration': '12:34',
      'subject': 'Physics',
    },
    {
      'title': 'Organic Chemistry Intro',
      'creator': 'Rex',
      'views': '720K',
      'duration': '15:20',
      'subject': 'Chemistry',
    },
  ];

  final List<Map<String, dynamic>> _forYouReps = [
    {'title': 'Calculus: Derivatives', 'subject': 'Math', 'views': '11.3K'},
    {'title': 'The Roman Empire', 'subject': 'History', 'views': '85K'},
    {'title': 'Organic Chemistry Reactions', 'subject': 'Chemistry', 'views': '37K'},
    {'title': 'Shakespeare\'s Hamlet', 'subject': 'Literature', 'views': '30K'},
    {'title': 'World War II: President', 'subject': 'History', 'views': '9.3K'},
    {'title': 'World War II: Armistice', 'subject': 'History', 'views': '12.2K'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyRepsTheme.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            
            // Category Chips
            SliverToBoxAdapter(
              child: _buildCategoryChips(),
            ),
            
            // Trending Section
            SliverToBoxAdapter(
              child: _buildTrendingSection(),
            ),
            
            // For You Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: const Text(
                  'For You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: StudyRepsTheme.textPrimary,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ),
            
            // For You Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final rep = _forYouReps[index];
                    return _buildForYouCard(rep, index);
                  },
                  childCount: _forYouReps.length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: StudyRepsTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudyRepsTheme.borderSubtle),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: StudyRepsTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search subjects, reps...',
            hintStyle: TextStyle(color: StudyRepsTheme.textMuted),
            prefixIcon: Icon(Icons.search_rounded, color: StudyRepsTheme.textMuted),
            suffixIcon: Icon(Icons.tune_rounded, color: StudyRepsTheme.textMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? StudyRepsTheme.primaryIndigo 
                      : StudyRepsTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? StudyRepsTheme.primaryIndigo 
                        : StudyRepsTheme.borderSubtle,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : StudyRepsTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 + index * 50).ms);
        },
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              const Text(
                'Trending Reps',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: StudyRepsTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🔥', style: TextStyle(fontSize: 18)),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trendingReps.length,
            itemBuilder: (context, index) {
              final rep = _trendingReps[index];
              return _buildTrendingCard(rep, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(Map<String, dynamic> rep, int index) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: StudyRepsTheme.bgTertiary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: StudyRepsTheme.textMuted,
                    size: 40,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rep['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rep['title'],
                  style: const TextStyle(
                    color: StudyRepsTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: StudyRepsTheme.primaryIndigo.withOpacity(0.3),
                      child: Icon(
                        Icons.person_rounded,
                        size: 12,
                        color: StudyRepsTheme.primaryIndigo,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rep['creator'],
                      style: TextStyle(
                        color: StudyRepsTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.visibility_outlined, size: 12, color: StudyRepsTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      rep['views'],
                      style: TextStyle(
                        color: StudyRepsTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (250 + index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildForYouCard(Map<String, dynamic> rep, int index) {
    return Container(
      decoration: BoxDecoration(
        color: StudyRepsTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyRepsTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: StudyRepsTheme.bgTertiary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: StudyRepsTheme.textMuted,
                      size: 36,
                    ),
                  ),
                  // Subject tag
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: StudyRepsTheme.primaryIndigo,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rep['subject'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Views
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white70),
                        const SizedBox(width: 2),
                        Text(
                          rep['views'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Title
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                rep['title'],
                style: const TextStyle(
                  color: StudyRepsTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (450 + index * 80).ms).scale(begin: const Offset(0.95, 0.95));
  }
}
