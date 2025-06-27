import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

/// Profile edit screen for updating user information
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final authState = ref.read(authProvider).value;
    
    // Initialize with mock data for demonstration
    _nameController.text = authState?.user?.name ?? 'Plant Lover';
    _bioController.text = 'Passionate about plants and sustainable living 🌱\nSharing my green journey with fellow plant enthusiasts!';
    _locationController.text = 'San Francisco, CA';
    _websiteController.text = 'https://myplantblog.com';
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          onPressed: () => _handleBackPress(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture section
              _buildProfilePictureSection(theme),
              const SizedBox(height: 32),
              
              // Basic information
              _buildBasicInfoSection(theme),
              const SizedBox(height: 24),
              
              // Bio section
              _buildBioSection(theme),
              const SizedBox(height: 24),
              
              // Contact information
              _buildContactInfoSection(theme),
              const SizedBox(height: 24),
              
              // Privacy settings
              _buildPrivacySection(theme),
              const SizedBox(height: 32),
              
              // Danger zone
              _buildDangerZone(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _nameController.text.split(' ').map((name) => name.isNotEmpty ? name[0] : '').join(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _changeProfilePicture,
                    icon: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _changeProfilePicture,
            child: const Text('Change Profile Picture'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your display name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Display name is required';
            }
            if (value.trim().length < 2) {
              return 'Display name must be at least 2 characters';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Enter your location',
            prefixIcon: Icon(Icons.location_on),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildBioSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell others about yourself and your plant journey...',
            prefixIcon: const Icon(Icons.info_outline),
            alignLabelWithHint: true,
            helperText: '${_bioController.text.length}/500 characters',
          ),
          maxLines: 4,
          maxLength: 500,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Bio must be 500 characters or less';
            }
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _websiteController,
          decoration: const InputDecoration(
            labelText: 'Website',
            hintText: 'https://yourwebsite.com',
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final urlPattern = r'^https?:\/\/.+';
              if (!RegExp(urlPattern).hasMatch(value)) {
                return 'Please enter a valid URL starting with http:// or https://';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPrivacyOption(
                  'Private Account',
                  'Only approved followers can see your posts',
                  false,
                  (value) {
                    setState(() {
                      _hasChanges = true;
                    });
                    _showComingSoon('Private Account');
                  },
                ),
                const Divider(),
                _buildPrivacyOption(
                  'Show Activity Status',
                  'Let others see when you\'re active',
                  true,
                  (value) {
                    setState(() {
                      _hasChanges = true;
                    });
                    _showComingSoon('Activity Status');
                  },
                ),
                const Divider(),
                _buildPrivacyOption(
                  'Allow Plant Identification',
                  'Let others identify plants in your photos',
                  true,
                  (value) {
                    setState(() {
                      _hasChanges = true;
                    });
                    _showComingSoon('Plant Identification');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDangerZone(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            'Permanently delete your account and all data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _showDeleteAccountDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade700),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  Icons.camera_alt,
                  'Camera',
                  () {
                    Navigator.pop(context);
                    _showComingSoon('Camera');
                  },
                ),
                _buildImageSourceOption(
                  Icons.photo_library,
                  'Gallery',
                  () {
                    Navigator.pop(context);
                    _showComingSoon('Gallery');
                  },
                ),
                _buildImageSourceOption(
                  Icons.delete,
                  'Remove',
                  () {
                    Navigator.pop(context);
                    _showComingSoon('Remove Photo');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.pop(); // Go back
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _hasChanges = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This action cannot be undone. All your data, including posts, plants, and connections will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Account Deletion');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}