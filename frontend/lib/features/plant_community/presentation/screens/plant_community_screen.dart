import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_community/presentation/screens/plant_questions_screen.dart';
import 'package:plant_social/features/plant_community/presentation/screens/plant_trades_screen.dart';
import 'package:plant_social/core/theme/app_theme.dart';

class PlantCommunityScreen extends ConsumerStatefulWidget {
  const PlantCommunityScreen({super.key});

  @override
  ConsumerState<PlantCommunityScreen> createState() => _PlantCommunityScreenState();
}

class _PlantCommunityScreenState extends ConsumerState<PlantCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Community'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'Q&A',
            ),
            Tab(
              icon: Icon(Icons.swap_horiz),
              text: 'Trades',
            ),
          ],
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey[600],
        ),
        actions: [
          IconButton(
            onPressed: _navigateToMyContent,
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Content',
          ),
          IconButton(
            onPressed: _navigateToBookmarks,
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Bookmarks',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PlantQuestionsScreen(),
          PlantTradesScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: _onFabPressed,
      child: Icon(
        _currentIndex == 0 ? Icons.add_comment : Icons.add_business,
      ),
      tooltip: _currentIndex == 0 ? 'Ask Question' : 'Create Trade',
      backgroundColor: theme.primaryColor,
    );
  }

  void _onFabPressed() {
    if (_currentIndex == 0) {
      _navigateToAskQuestion();
    } else {
      _navigateToCreateTrade();
    }
  }

  void _navigateToAskQuestion() {
    Navigator.pushNamed(context, '/ask-question');
  }

  void _navigateToCreateTrade() {
    Navigator.pushNamed(context, '/create-trade');
  }

  void _navigateToMyContent() {
    Navigator.pushNamed(context, '/my-community-content');
  }

  void _navigateToBookmarks() {
    Navigator.pushNamed(context, '/community-bookmarks');
  }
}

// Alternative layout with bottom navigation
class PlantCommunityBottomNavScreen extends ConsumerStatefulWidget {
  const PlantCommunityBottomNavScreen({super.key});

  @override
  ConsumerState<PlantCommunityBottomNavScreen> createState() => _PlantCommunityBottomNavScreenState();
}

class _PlantCommunityBottomNavScreenState extends ConsumerState<PlantCommunityBottomNavScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    PlantQuestionsScreen(),
    PlantTradesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            activeIcon: Icon(Icons.swap_horizontal_circle),
            label: 'Trades',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: Icon(
          _currentIndex == 0 ? Icons.add_comment : Icons.add_business,
        ),
        tooltip: _currentIndex == 0 ? 'Ask Question' : 'Create Trade',
      ),
    );
  }

  void _onFabPressed() {
    if (_currentIndex == 0) {
      Navigator.pushNamed(context, '/ask-question');
    } else {
      Navigator.pushNamed(context, '/create-trade');
    }
  }
}