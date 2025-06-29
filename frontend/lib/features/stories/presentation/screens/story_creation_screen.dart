import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Story creation screen for editing and publishing captured photos
/// Allows users to add captions and create stories from camera captures
class StoryCreationScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  
  const StoryCreationScreen({
    super.key,
    this.imagePath,
  });

  @override
  ConsumerState<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends ConsumerState<StoryCreationScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Publish the story (placeholder implementation)
  Future<void> _publishStory() async {
    if (widget.imagePath == null) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish story: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isPublishing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          'Create Story',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isPublishing ? null : _publishStory,
            child: _isPublishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: widget.imagePath == null
          ? _buildNoImageState(theme)
          : _buildStoryEditor(theme),
    );
  }

  Widget _buildNoImageState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Selected',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo to create your story',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryEditor(ThemeData theme) {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Caption input and controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caption input
              TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a caption to your story...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Story options
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.public,
                      label: 'Public',
                      isSelected: true,
                      onTap: () {
                        // Handle privacy selection
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.people,
                      label: 'Friends',
                      isSelected: false,
                      onTap: () {
                        // Handle privacy selection
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.local_florist,
                    label: 'Tag Plants',
                    onTap: () {
                      _showPlantTagDialog(context, theme);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.location_on,
                    label: 'Add Location',
                    onTap: () {
                      _showLocationTagDialog(context, theme);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.tune,
                    label: 'Filters',
                    onTap: () {
                      _showFiltersDialog(context, theme);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantTagDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag Plants'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select plants to tag in your story:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildPlantTagItem(theme, 'Monstera Deliciosa', 'Indoor Plant', true),
                    _buildPlantTagItem(theme, 'Peace Lily', 'Flowering Plant', false),
                    _buildPlantTagItem(theme, 'Snake Plant', 'Succulent', false),
                    _buildPlantTagItem(theme, 'Fiddle Leaf Fig', 'Tree', false),
                    _buildPlantTagItem(theme, 'Pothos', 'Vine', true),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plants tagged successfully!')),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantTagItem(ThemeData theme, String plantName, String category, bool isSelected) {
    return StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          title: Text(plantName),
          subtitle: Text(category),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              // Toggle selection
            });
          },
          secondary: CircleAvatar(
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.local_florist, color: theme.primaryColor),
          ),
        );
      },
    );
  }

  void _showLocationTagDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how to add location:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use Current Location'),
              subtitle: const Text('GPS location will be used'),
              onTap: () {
                Navigator.of(context).pop();
                _useCurrentLocation();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Location'),
              subtitle: const Text('Search for a specific place'),
              onTap: () {
                Navigator.of(context).pop();
                _showLocationSearchDialog(context, theme);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Select from Saved'),
              subtitle: const Text('Choose from saved locations'),
              onTap: () {
                Navigator.of(context).pop();
                _showSavedLocationsDialog(context, theme);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _useCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current location added to story!')),
    );
  }

  void _showLocationSearchDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for a place...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                children: [
                  _buildLocationSearchResult(theme, 'Central Park, New York', 'Park'),
                  _buildLocationSearchResult(theme, 'Brooklyn Botanic Garden', 'Garden'),
                  _buildLocationSearchResult(theme, 'High Line Park', 'Public Garden'),
                  _buildLocationSearchResult(theme, 'The New York Botanical Garden', 'Botanical Garden'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSearchResult(ThemeData theme, String name, String type) {
    return ListTile(
      leading: const Icon(Icons.place),
      title: Text(name),
      subtitle: Text(type),
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location "$name" added to story!')),
        );
      },
    );
  }

  void _showSavedLocationsDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Locations'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView(
            children: [
              _buildSavedLocationItem(theme, 'My Garden', 'Home', Icons.home),
              _buildSavedLocationItem(theme, 'Local Nursery', 'Plant Store', Icons.store),
              _buildSavedLocationItem(theme, 'Community Garden', 'Public Space', Icons.group),
              _buildSavedLocationItem(theme, 'Office Plants', 'Workplace', Icons.business),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLocationItem(ThemeData theme, String name, String type, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(name),
      subtitle: Text(type),
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location "$name" added to story!')),
        );
      },
    );
  }

  void _showFiltersDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Filters'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brightness & Color',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilterSlider('Brightness', 0.5),
                _buildFilterSlider('Contrast', 0.5),
                _buildFilterSlider('Saturation', 0.5),
                
                const SizedBox(height: 16),
                Text(
                  'Plant Enhancement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilterSlider('Green Boost', 0.3),
                _buildFilterSlider('Leaf Detail', 0.4),
                _buildFilterSlider('Natural Light', 0.6),
                
                const SizedBox(height: 16),
                Text(
                  'Creative Filters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildFilterChip('Vintage', false),
                    _buildFilterChip('Warm', true),
                    _buildFilterChip('Cool', false),
                    _buildFilterChip('Dramatic', false),
                    _buildFilterChip('Soft', false),
                    _buildFilterChip('Vibrant', false),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters applied successfully!')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSlider(String label, double value) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Slider(
              value: value,
              onChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return StatefulBuilder(
      builder: (context, setState) {
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              isSelected = selected;
            });
          },
        );
      },
    );
  }
}