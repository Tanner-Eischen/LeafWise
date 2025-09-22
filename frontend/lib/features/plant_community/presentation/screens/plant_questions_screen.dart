import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/plant_community/models/plant_community_models.dart';
import 'package:leafwise/features/plant_community/providers/plant_community_provider.dart';
import 'package:leafwise/features/plant_community/presentation/widgets/question_card.dart';
import 'package:leafwise/core/widgets/custom_search_bar.dart';

class PlantQuestionsScreen extends ConsumerStatefulWidget {
  const PlantQuestionsScreen({super.key});

  @override
  ConsumerState<PlantQuestionsScreen> createState() =>
      _PlantQuestionsScreenState();
}

class _PlantQuestionsScreenState extends ConsumerState<PlantQuestionsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSort = SortOption.newest;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantCommunityProvider.notifier).loadQuestions(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(plantCommunityProvider);
      if (!state.isLoading && state.hasMoreQuestions) {
        ref
            .read(plantCommunityProvider.notifier)
            .loadQuestions(
              category: _selectedCategory,
              search: _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
              sortBy: _selectedSort,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(plantCommunityProvider);
    final questions = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Q&A'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
          ),
          IconButton(
            onPressed: _navigateToAskQuestion,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search questions...',
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Filters
          if (_showFilters) _buildFilters(theme),

          // Questions list
          Expanded(child: _buildQuestionsList(questions, state)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAskQuestion,
        tooltip: 'Ask a Question',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          Text(
            'Categories',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: QuestionCategory.all.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip(
                    'All',
                    _selectedCategory == null,
                    () => _selectCategory(null),
                  );
                }

                final category = QuestionCategory.all[index - 1];
                return _buildCategoryChip(
                  QuestionCategory.getDisplayName(category),
                  _selectedCategory == category,
                  () => _selectCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sort options
          Row(
            children: [
              Text(
                'Sort by:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: SortOption.questionSortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(SortOption.getDisplayName(option)),
                    );
                  }).toList(),
                  onChanged: _selectSort,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: theme.primaryColor.withOpacity(0.2),
        checkmarkColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? theme.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuestionsList(
    List<PlantQuestion> questions,
    PlantCommunityState state,
  ) {
    if (state.isLoading && questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load questions',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No questions found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to ask a question!',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToAskQuestion,
              child: const Text('Ask a Question'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshQuestions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: questions.length + (state.hasMoreQuestions ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= questions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final question = questions[index];
          return QuestionCard(
            question: question,
            onTap: () => _navigateToQuestionDetail(question),
            onVote: (voteType) => _voteQuestion(question.id, voteType),
            onBookmark: () => _bookmarkQuestion(question.id),
          );
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    // Implement debounced search if needed
  }

  void _onSearchSubmitted(String value) {
    _refreshQuestions();
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _refreshQuestions();
  }

  void _selectSort(String? sortBy) {
    setState(() {
      _selectedSort = sortBy;
    });
    _refreshQuestions();
  }

  Future<void> _refreshQuestions() async {
    await ref
        .read(plantCommunityProvider.notifier)
        .loadQuestions(
          refresh: true,
          category: _selectedCategory,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          sortBy: _selectedSort,
        );
  }

  void _voteQuestion(String questionId, String voteType) {
    ref
        .read(plantCommunityProvider.notifier)
        .voteQuestion(questionId, voteType);
  }

  void _bookmarkQuestion(String questionId) {
    ref.read(plantCommunityProvider.notifier).bookmarkQuestion(questionId);
  }

  void _navigateToAskQuestion() {
    Navigator.pushNamed(context, '/ask-question').then((result) {
      if (result == true) {
        _refreshQuestions();
      }
    });
  }

  void _navigateToQuestionDetail(PlantQuestion question) {
    Navigator.pushNamed(context, '/question-detail', arguments: question.id);
  }
}
