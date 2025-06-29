import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_social/core/router/app_router.dart';
import 'package:plant_social/features/camera/widgets/plant_ar_filters.dart';

/// Camera screen for capturing photos and videos with AR plant features
/// Implements camera functionality with AR overlays connected to real backend data
class CameraScreen extends ConsumerStatefulWidget {
  final String? selectedPlantId; // Optional plant ID for personalized AR data
  final String? userLocation; // Optional user location for environmental data

  const CameraScreen({
    super.key,
    this.selectedPlantId,
    this.userLocation,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  bool _isCapturing = false;
  int _selectedCameraIndex = 0;
  
  // AR Filter state
  String? _currentFilter;
  bool _showARFilters = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize camera with permission checks
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      
      if (cameraPermission != PermissionStatus.granted) {
        setState(() {
          _error = 'Camera permission is required to use this feature';
          _isLoading = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = 'No cameras found on this device';
          _isLoading = false;
        });
        return;
      }

      // Initialize camera controller
      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Setup camera controller for specified camera index
  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Dispose existing controller
    await _cameraController?.dispose();

    // Create new controller
    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Switch between front and back cameras
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
      _isLoading = true;
    });

    await _setupCamera(_selectedCameraIndex);
  }

  /// Toggle AR filters visibility
  void _toggleARFilters() {
    setState(() {
      _showARFilters = !_showARFilters;
      if (!_showARFilters) {
        _currentFilter = null;
      }
    });
  }

  /// Handle AR filter selection
  void _onFilterSelected(String filterType) {
    setState(() {
      _currentFilter = filterType == 'none' ? null : filterType;
    });
  }

  /// Capture photo
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile photo = await _cameraController!.takePicture();
      
      if (mounted) {
        // Navigate to story creation with captured image
        context.push(
          '${AppRoutes.storyCreation}?imagePath=${photo.path}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  /// Request camera permission
  Future<void> _requestPermission() async {
    final permission = await Permission.camera.request();
    if (permission == PermissionStatus.granted) {
      _initializeCamera();
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
          'Plant Camera',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // AR Filters toggle
          IconButton(
            onPressed: _toggleARFilters,
            icon: Icon(
              _showARFilters ? Icons.visibility : Icons.visibility_off,
              color: _showARFilters ? Colors.green : Colors.white,
            ),
            tooltip: 'Toggle AR Filters',
          ),
          if (_cameras != null && _cameras!.length > 1)
            IconButton(
              onPressed: _isLoading ? null : _switchCamera,
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // AR Filters overlay
        if (_showARFilters)
          Positioned.fill(
            child: PlantARFilters(
              cameraController: _cameraController!,
              onFilterSelected: _onFilterSelected,
              currentFilter: _currentFilter,
              selectedPlantId: widget.selectedPlantId,
              userLocation: widget.userLocation ?? 'Unknown',
            ),
          ),
        
        // Camera controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildCameraControls(theme),
        ),
        
        // Current filter indicator
        if (_currentFilter != null)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getFilterDisplayName(_currentFilter!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            if (_error!.contains('permission'))
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Grant Permission'),
              )
            else
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to gallery or plant selection
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
              ),
            ),
          ),
          
          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _capturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isCapturing 
                    ? Colors.grey 
                    : Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: _currentFilter != null ? Colors.green : Colors.white,
                  width: 4,
                ),
              ),
              child: _isCapturing
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _currentFilter == 'plant_identification' 
                        ? Icons.search 
                        : Icons.camera_alt,
                      color: Colors.black,
                      size: 32,
                    ),
            ),
          ),
          
          // Plant selection button
          GestureDetector(
            onTap: () {
              _showPlantSelectionDialog();
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.selectedPlantId != null 
                  ? Colors.green.withOpacity(0.8)
                  : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: widget.selectedPlantId != null 
                    ? Colors.green 
                    : Colors.white.withOpacity(0.3)
                ),
              ),
              child: Icon(
                Icons.local_florist,
                color: widget.selectedPlantId != null ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show plant selection dialog
  void _showPlantSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Plant'),
        content: const Text(
          'Choose a plant from your collection to get personalized AR data like health metrics, care reminders, and growth timeline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to plant selection screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plant selection feature coming soon!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Select Plant'),
          ),
        ],
      ),
    );
  }

  /// Get display name for filter
  String _getFilterDisplayName(String filterType) {
    switch (filterType) {
      case 'growth_timelapse':
        return 'Growth Timeline';
      case 'health_overlay':
        return 'Health Analysis';
      case 'seasonal_transformation':
        return 'Seasonal Care';
      case 'plant_identification':
        return 'Plant ID';
      case 'care_reminder':
        return 'Care Reminders';
      default:
        return 'AR Filter';
    }
  }
}