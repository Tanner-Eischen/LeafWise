import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../modules/growth_tracker/growth_tracker.dart';

/// Growth Photo Capture Screen
///
/// This screen allows users to capture photos of their plants to track growth
/// over time. Users can take a new photo or select one from their gallery,
/// add notes, and save the photo to the plant's growth timeline.
class GrowthPhotoCaptureScreen extends ConsumerStatefulWidget {
  final String? plantId;
  
  const GrowthPhotoCaptureScreen({this.plantId, super.key});

  @override
  ConsumerState<GrowthPhotoCaptureScreen> createState() => _GrowthPhotoCaptureScreenState();
}

class _GrowthPhotoCaptureScreenState extends ConsumerState<GrowthPhotoCaptureScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  String? _selectedPlantId;
  String? _notes;
  String _errorMessage = '';
  GrowthRecord? _currentRecord;
  
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final GrowthTracker _growthTracker = GrowthTracker();
  
  @override
  void initState() {
    super.initState();
    _selectedPlantId = widget.plantId;
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  /// Takes a photo using the device camera
  Future<void> _takePhoto() async {
    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = '';
      });
      
      final record = await _growthTracker.captureGrowthPhoto(
        useCamera: true,
        notes: _notes,
      );
      
      if (record != null) {
        setState(() {
          _imageFile = File(record.photoPath);
          _currentRecord = record;
          _errorMessage = '';
        });
        
        // Analyze the photo for metrics
        await _analyzePhoto(record);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing camera: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  /// Selects a photo from the device gallery
  Future<void> _selectFromGallery() async {
    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = '';
      });
      
      final record = await _growthTracker.captureGrowthPhoto(
        useCamera: false,
        notes: _notes,
      );
      
      if (record != null) {
        setState(() {
          _imageFile = File(record.photoPath);
          _currentRecord = record;
          _errorMessage = '';
        });
        
        // Analyze the photo for metrics
        await _analyzePhoto(record);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing gallery: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  /// Analyzes the captured photo to extract growth metrics
  Future<void> _analyzePhoto(GrowthRecord record) async {
    try {
      final analyzedRecord = await _growthTracker.analyzeGrowthRecord(record);
      setState(() {
        _currentRecord = analyzedRecord;
      });
    } catch (e) {
      // Analysis failed, but we can still save the photo without metrics
      debugPrint('Photo analysis failed: $e');
    }
  }
  
  /// Saves the captured photo with metadata
  Future<void> _savePhoto() async {
    if (_imageFile == null || _currentRecord == null) {
      setState(() {
        _errorMessage = 'Please capture or select a photo first';
      });
      return;
    }
    
    if (_selectedPlantId == null) {
      setState(() {
        _errorMessage = 'Please select a plant';
      });
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });
    
    try {
      // Update the record with the latest notes
      final finalRecord = _currentRecord!.copyWith(
        notes: _notes?.isNotEmpty == true ? _notes : _currentRecord!.notes,
      );
      
      // TODO: Implement saving to telemetry history
      // This would involve uploading the image and metadata to storage
      // and creating a record in the telemetry database
      // For now, we have the complete growth record with metrics
      
      // Log the growth record details for debugging
      debugPrint('Saving growth record:');
      debugPrint('  ID: ${finalRecord.id}');
      debugPrint('  Photo path: ${finalRecord.photoPath}');
      debugPrint('  Timestamp: ${finalRecord.timestamp}');
      debugPrint('  Notes: ${finalRecord.notes}');
      if (finalRecord.metrics != null) {
        debugPrint('  Metrics:');
        debugPrint('    Height: ${finalRecord.metrics!.height} cm');
        debugPrint('    Width: ${finalRecord.metrics!.width} cm');
        debugPrint('    Leaf count: ${finalRecord.metrics!.leafCount}');
        debugPrint('    Health score: ${finalRecord.metrics!.healthScore}');
        debugPrint('    Dominant color: ${finalRecord.metrics!.customMetrics?['dominant_color'] ?? 'N/A'}');
      }
      
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isProcessing = false;
      });
      
      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth photo saved successfully with metrics')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving photo: $e';
        _isProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Growth Photo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo capture/selection area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plant Photo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_imageFile != null) ...[  
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _imageFile!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Growth metrics display (if available)
            if (_currentRecord?.metrics != null) ...[  
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Growth Analysis',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow('Height', '${_currentRecord!.metrics!.height?.toStringAsFixed(1) ?? 'N/A'} cm'),
                      _buildMetricRow('Width', '${_currentRecord!.metrics!.width?.toStringAsFixed(1) ?? 'N/A'} cm'),
                      _buildMetricRow('Leaf Count', '${_currentRecord!.metrics!.leafCount ?? 'N/A'}'),
                      _buildMetricRow('Health Score', '${_currentRecord!.metrics!.healthScore != null ? (_currentRecord!.metrics!.healthScore! * 100).toStringAsFixed(0) : 'N/A'}%'),
                      _buildMetricRow('Dominant Color', '', color: _currentRecord!.metrics!.customMetrics?['dominant_color'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Plant selection (if not provided)
            if (widget.plantId == null) ...[  
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Plant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // TODO: Implement plant selection dropdown
                      // This would be populated from the user's plant collection
                      Text('Plant selection to be implemented'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Notes input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., New leaf growth, Flowering started',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _notes = value.isEmpty ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            if (_errorMessage.isNotEmpty) ...[  
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton(
              onPressed: _isProcessing ? null : _savePhoto,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('SAVE PHOTO'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds a metric display row
  Widget _buildMetricRow(String label, String value, {String? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (color != null)
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(color.toUpperCase()),
              ],
            )
          else
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}