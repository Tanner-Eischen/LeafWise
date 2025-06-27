import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_identification/presentation/screens/plant_identification_screen.dart';
import 'package:plant_social/features/plant_care/presentation/screens/plant_care_dashboard_screen.dart';
import 'package:plant_social/features/plant_community/presentation/screens/plant_community_screen.dart';
import 'package:plant_social/core/theme/app_theme.dart';

class PlantFeaturesScreen extends ConsumerStatefulWidget {
  const PlantFeaturesScreen({super.key});

  @override
  ConsumerState<PlantFeaturesScreen> createState() => _PlantFeaturesScreenState();
}

class _PlantFeaturesScreenState extends ConsumerState<PlantFeaturesScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    PlantIdentificationScreen(),
    PlantCareDashboardScreen(),
    PlantCommunityScreen(),
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
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Identify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'My Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}

// Alternative grid-based layout for plant features
class PlantFeaturesGridScreen extends ConsumerWidget {
  const PlantFeaturesGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Features'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover & Care for Plants',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Identify plants, track care, and connect with fellow plant lovers',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'Plant ID',
                    subtitle: 'Identify any plant with AI',
                    icon: Icons.camera_alt,
                    color: Colors.green,
                    onTap: () => _navigateToIdentification(context),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'My Plants',
                    subtitle: 'Track care & reminders',
                    icon: Icons.eco,
                    color: Colors.blue,
                    onTap: () => _navigateToPlantCare(context),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Q&A',
                    subtitle: 'Ask plant experts',
                    icon: Icons.help_outline,
                    color: Colors.orange,
                    onTap: () => _navigateToQuestions(context),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Plant Trades',
                    subtitle: 'Buy, sell & trade plants',
                    icon: Icons.swap_horiz,
                    color: Colors.purple,
                    onTap: () => _navigateToTrades(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToIdentification(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Identify Plant'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToPlantCare(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Plant'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToIdentification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantIdentificationScreen(),
      ),
    );
  }

  void _navigateToPlantCare(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantCareDashboardScreen(),
      ),
    );
  }

  void _navigateToQuestions(BuildContext context) {
    Navigator.pushNamed(context, '/plant-questions');
  }

  void _navigateToTrades(BuildContext context) {
    Navigator.pushNamed(context, '/plant-trades');
  }
}