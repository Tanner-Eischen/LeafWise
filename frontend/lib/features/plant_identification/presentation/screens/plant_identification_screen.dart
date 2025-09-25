import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafwise/features/plant_identification/providers/plant_identification_provider.dart';
import 'package:leafwise/features/plant_identification/providers/enhanced_plant_identification_provider.dart';
import 'package:leafwise/features/plant_identification/presentation/widgets/plant_identification_result.dart';
import 'package:leafwise/features/plant_identification/presentation/widgets/plant_identification_loading.dart';
import 'package:leafwise/features/plant_identification/presentation/widgets/offline_identification_result.dart';

class PlantIdentificationScreen extends ConsumerStatefulWidget {
  const PlantIdentificationScreen({super.key});

  @override
  ConsumerState<PlantIdentificationScreen> createState() =>
      _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState
    extends ConsumerState<PlantIdentificationScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      // Check connectivity and use appropriate identification method
      final offlineState = ref.read(enhancedPlantIdentificationStateProvider);
      final isOffline = offlineState.connectivityStatus?.maybeWhen(
               offline: () => true,
               orElse: () => false,
             ) ?? false;

      if (isOffline || offlineState.currentModel != null) {
        // Use offline identification
        await ref
            .read(enhancedPlantIdentificationStateProvider.notifier)
            .identifyPlantOffline(imageFile);
      } else {
        // Use online identification
        await ref
            .read(plantIdentificationProvider.notifier)
            .identifyPlant(imageFile);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Check connectivity and use appropriate identification method
        final offlineState = ref.read(enhancedPlantIdentificationStateProvider);
        final isOffline = offlineState.connectivityStatus?.maybeWhen(
              offline: () => true,
              orElse: () => false,
            ) ?? false;

        if (isOffline || offlineState.currentModel != null) {
          // Use offline identification
          await ref
              .read(enhancedPlantIdentificationStateProvider.notifier)
              .identifyPlantOffline(imageFile);
        } else {
          // Use online identification
          await ref
              .read(plantIdentificationProvider.notifier)
              .identifyPlant(imageFile);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantIdentificationProvider);
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);
    final theme = Theme.of(context);

    // Determine if we're in offline mode
    final isOffline = offlineState.connectivityStatus?.maybeWhen(
               offline: () => true,
               orElse: () => false,
             ) ?? false;
    final hasOfflineModel = offlineState.currentModel != null;
    final isLoading = plantState.isLoading || offlineState.isLoading;
    final currentOfflineIdentification =
        offlineState.localIdentifications.isNotEmpty
        ? offlineState.localIdentifications.first
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Plant Identification',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            // Connectivity status indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline ? Icons.wifi_off : Icons.wifi,
                  color: isOffline ? Colors.orange : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isOffline ? 'Offline Mode' : 'Online',
                  style: TextStyle(
                    color: isOffline ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
                if (hasOfflineModel) ...
                  [
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.model_training,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Ready',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
              ],
            ),
          ],
        ),
        actions: [
          // Sync status indicator
          if (offlineState.localIdentifications.any(
            (id) => id.syncStatus.maybeWhen(
                  notSynced: () => true,
                  orElse: () => false,
                ),
          ))
            IconButton(
              icon: const Icon(Icons.sync_problem, color: Colors.orange),
              onPressed: () {
                context.push('/home/plants/identify/offline-mode');
              },
              tooltip: 'Pending sync',
            ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              context.push('/home/plants/identify/history');
            },
            tooltip: 'Identification History',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'search':
                  context.push('/home/plants/identify/search');
                  break;
                case 'my_plants':
                  context.push('/home/plants/care');
                  break;
                case 'community':
                  context.push('/home/plants/community');
                  break;
                case 'care_plans':
                  context.push('/home/plants/care-plans');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Plant Search'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'my_plants',
                child: Row(
                  children: [
                    Icon(Icons.eco, color: Colors.black),
                    SizedBox(width: 8),
                    Text('My Plants'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'community',
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Community'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'care_plans',
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Care Plans'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Plant identification overlay
          if (isLoading)
            const PlantIdentificationLoading()
          else if (plantState.currentIdentification != null)
            PlantIdentificationResult(
              identification: plantState.currentIdentification!,
              onClose: () {
                ref
                    .read(plantIdentificationProvider.notifier)
                    .clearCurrentIdentification();
              },
              onSaveToCollection: () {
                ref
                    .read(plantIdentificationProvider.notifier)
                    .saveToCollection(plantState.currentIdentification!.id);
              },
            )
          else if (currentOfflineIdentification != null &&
              currentOfflineIdentification.identifiedAt.isAfter(
                DateTime.now().subtract(const Duration(seconds: 10)),
              ))
            OfflineIdentificationResult(
              identification: currentOfflineIdentification,
              onClose: () {
                // Clear the recent offline identification by reloading
                ref
                    .read(enhancedPlantIdentificationStateProvider.notifier)
                    .loadLocalIdentifications();
              },
              onSync: () {
                ref
                    .read(enhancedPlantIdentificationStateProvider.notifier)
                    .syncIdentification(currentOfflineIdentification.localId);
              },
            ),

          // Camera controls
          if (!isLoading &&
              plantState.currentIdentification == null &&
              (currentOfflineIdentification == null ||
                  !currentOfflineIdentification.identifiedAt.isAfter(
                    DateTime.now().subtract(const Duration(seconds: 10)),
                  )))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Switch camera button
                    GestureDetector(
                      onTap: () {
                        // Switch between front and back camera
                        // Implementation depends on camera setup
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions overlay
          if (!isLoading &&
              plantState.currentIdentification == null &&
              (currentOfflineIdentification == null ||
                  !currentOfflineIdentification.identifiedAt.isAfter(
                    DateTime.now().subtract(const Duration(seconds: 10)),
                  )))
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      isOffline ? Icons.offline_bolt : Icons.eco,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOffline
                          ? 'Offline Plant Identification'
                          : 'Point your camera at a plant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOffline
                          ? hasOfflineModel
                                ? 'Using on-device AI model for identification'
                                : 'No offline model available. Download a model to identify plants offline.'
                          : 'Take a clear photo to identify the species',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isOffline && !hasOfflineModel) ...
                      [
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/model-management');
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download Model'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ),

          // Error message
          if (plantState.error != null || offlineState.error != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plantState.error ?? offlineState.error ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        if (plantState.error != null) {
                          ref
                              .read(plantIdentificationProvider.notifier)
                              .clearError();
                        }
                        if (offlineState.error != null) {
                          ref
                              .read(
                                enhancedPlantIdentificationStateProvider
                                    .notifier,
                              )
                              .clearError();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Sync status overlay
          if (offlineState.localIdentifications.any(
            (id) => id.syncStatus.maybeWhen(
                  syncing: () => true,
                  orElse: () => false,
                ),
          ))
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Syncing...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
