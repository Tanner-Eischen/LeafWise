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
  final String? selectedPlantId;
  final String? selectedPlantType; // New parameter for plant type
  final String? userLocation;

  const CameraScreen({
    Key? key,
    this.selectedPlantId,
    this.selectedPlantType,
    this.userLocation,
  }) : super(key: key);

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _currentFilter;
  bool _isCapturing = false;
  String? _selectedPlantType; // Track selected plant type
  String? _selectedPlantId; // Track selected plant ID
  String? _error; // Error message state
  bool _isLoading = true; // Loading state
  bool _showARFilters = false; // AR filters visibility state

  @override
  void initState() {
    super.initState();
    _selectedPlantType = widget.selectedPlantType;
    _selectedPlantId = widget.selectedPlantId;
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found on this device';
          _isLoading = false;
        });
        return;
      }

      // Initialize camera controller
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
        
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
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Capture photo
  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });

      final image = await _controller!.takePicture();
      
      // Handle the captured image based on current filter
      await _handleCapturedImage(image);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _handleCapturedImage(XFile image) async {
    if (_currentFilter == 'plant_identification') {
      // Plant identification is handled by the AR overlay
      return;
    }
    
    // Handle other capture scenarios
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo captured successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            onPressed: null, // TODO: Implement view action
          ),
        ),
      );
    }
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
    
    // Show error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Show camera preview
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
          IconButton(
            onPressed: _toggleARFilters,
            icon: Icon(
              _showARFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_controller != null && _controller!.value.isInitialized)
            Center(
              child: CameraPreview(_controller!),
            ),

          // AR filters overlay
          if (_showARFilters && _controller != null)
            PlantARFilters(
              cameraController: _controller!,
              onFilterSelected: _onFilterSelected,
              currentFilter: _currentFilter,
              selectedPlantId: _selectedPlantId,
              selectedPlantType: _selectedPlantType,
              userLocation: widget.userLocation,
            ),

          // Capture button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _capturePhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.grey : Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 