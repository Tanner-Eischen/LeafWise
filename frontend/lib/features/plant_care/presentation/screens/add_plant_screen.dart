import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';
import 'package:plant_social/features/plant_care/providers/plant_care_provider.dart';
import 'package:plant_social/features/plant_identification/models/plant_identification_models.dart';
import 'package:plant_social/features/plant_identification/providers/plant_identification_provider.dart';
import 'package:plant_social/core/theme/app_theme.dart';
import 'package:plant_social/core/widgets/custom_button.dart';
import 'package:plant_social/core/widgets/custom_text_field.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  final PlantSpecies? preselectedSpecies;
  final String? preselectedImagePath;

  const AddPlantScreen({
    super.key,
    this.preselectedSpecies,
    this.preselectedImagePath,
  });

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  
  PlantSpecies? _selectedSpecies;
  File? _selectedImage;
  DateTime _acquiredDate = DateTime.now();
  bool _isSearching = false;
  List<PlantSpecies> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.preselectedSpecies;
    if (widget.preselectedImagePath != null) {
      _selectedImage = File(widget.preselectedImagePath!);
    }
    if (_selectedSpecies != null) {
      _searchController.text = _selectedSpecies!.commonName;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plantCareState = ref.watch(plantCareProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant image section
              _buildImageSection(theme),
              const SizedBox(height: 24),

              // Plant species search
              _buildSpeciesSection(theme),
              const SizedBox(height: 24),

              // Plant details
              _buildDetailsSection(theme),
              const SizedBox(height: 32),

              // Add button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Add Plant',
                  onPressed: plantCareState.isLoading ? null : _addPlant,
                  isLoading: plantCareState.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Photo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                color: Colors.grey[50],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Species',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _searchController,
          hint: 'Search for plant species...',
          prefixIcon: const Icon(Icons.search),
          onChanged: _searchSpecies,
          validator: (value) {
            if (_selectedSpecies == null) {
              return 'Please select a plant species';
            }
            return null;
          },
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final species = _searchResults[index];
                return ListTile(
                  title: Text(species.commonName),
                  subtitle: Text(species.scientificName),
                  onTap: () => _selectSpecies(species),
                  selected: _selectedSpecies?.id == species.id,
                );
              },
            ),
          ),
        if (_selectedSpecies != null)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSpecies!.commonName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedSpecies!.scientificName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedSpecies = null;
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nicknameController,
          label: 'Plant Nickname',
          hint: 'Give your plant a name...',
          prefixIcon: const Icon(Icons.pets),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a nickname for your plant';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _locationController,
          label: 'Location (Optional)',
          hint: 'Where is this plant located?',
          prefixIcon: const Icon(Icons.location_on),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.calendar_today,
            color: theme.primaryColor,
          ),
          title: const Text('Date Acquired'),
          subtitle: Text(
            '${_acquiredDate.day}/${_acquiredDate.month}/${_acquiredDate.year}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _selectAcquiredDate,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _notesController,
          label: 'Notes (Optional)',
          hint: 'Any additional notes about your plant...',
          prefixIcon: const Icon(Icons.note),
          maxLines: 3,
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _searchSpecies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ref.read(plantSpeciesSearchProvider(query).future);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectSpecies(PlantSpecies species) {
    setState(() {
      _selectedSpecies = species;
      _searchController.text = species.commonName;
      _searchResults = [];
    });
  }

  Future<void> _selectAcquiredDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _acquiredDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _acquiredDate = selectedDate;
      });
    }
  }

  Future<void> _addPlant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final request = UserPlantRequest(
        nickname: _nicknameController.text.trim(),
        speciesId: _selectedSpecies!.id,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        acquiredDate: _acquiredDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ref.read(plantCareProvider.notifier).createUserPlant(request);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nicknameController.text} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add plant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}