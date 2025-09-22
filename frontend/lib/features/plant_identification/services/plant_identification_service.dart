import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/network/api_client.dart';
import 'package:leafwise/features/plant_identification/models/plant_identification_models.dart';
import 'package:leafwise/features/plant_care/models/plant_care_models.dart'
    as plant_care;

/// Provider for the plant identification service
final plantIdentificationServiceProvider = Provider<PlantIdentificationService>(
  (ref) {
    // This would need to be properly wired with the actual ApiClient provider
    // For now, we'll create a placeholder that can be replaced
    throw UnimplementedError(
      'PlantIdentificationService provider needs proper ApiClient integration',
    );
  },
);

class PlantIdentificationService {
  final ApiClient _apiClient;

  PlantIdentificationService(this._apiClient);

  /// Upload and identify a plant image with full AI analysis and database storage
  Future<PlantIdentification> identifyPlant(
    File imageFile, {
    String? location,
    String? notes,
  }) async {
    try {
      // Create multipart form data for file upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      });

      final response = await _apiClient.post(
        '/plant-id/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return _parseIdentificationResponse(response.data);
    } catch (e) {
      throw Exception('Failed to identify plant: $e');
    }
  }

  /// Analyze a plant image without saving to database (quick identification)
  Future<PlantIdentificationResult> analyzePlant(File imageFile) async {
    try {
      // Create multipart form data for file upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/plant-id/analyze',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return PlantIdentificationResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to analyze plant: $e');
    }
  }

  Future<List<PlantIdentification>> getIdentificationHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/plant-id/',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      // Parse the paginated response
      final List<dynamic> items = response.data['items'];
      return items.map((json) => _parseIdentificationResponse(json)).toList();
    } catch (e) {
      throw Exception('Failed to get identification history: $e');
    }
  }

  Future<PlantIdentification> getIdentification(String identificationId) async {
    try {
      final response = await _apiClient.get('/plant-id/$identificationId');
      return _parseIdentificationResponse(response.data);
    } catch (e) {
      throw Exception('Failed to get identification: $e');
    }
  }

  Future<Map<String, dynamic>> getIdentificationAIDetails(
    String identificationId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/plant-id/$identificationId/ai-details',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to get AI details: $e');
    }
  }

  Future<plant_care.PlantSpecies> getPlantSpecies(String speciesId) async {
    try {
      final response = await _apiClient.get('/plant-species/$speciesId');
      return _parsePlantSpeciesResponse(response.data);
    } catch (e) {
      throw Exception('Failed to get plant species: $e');
    }
  }

  Future<List<plant_care.PlantSpecies>> searchPlantSpecies(String query) async {
    try {
      final response = await _apiClient.get(
        '/plant-species/search',
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => _parsePlantSpeciesResponse(json)).toList();
    } catch (e) {
      throw Exception('Failed to search plant species: $e');
    }
  }

  /// Search for plants by name or characteristics and return identification results
  Future<List<PlantIdentification>> searchPlants(String query) async {
    try {
      final response = await _apiClient.get(
        '/plant-id/search',
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => _parseIdentificationResponse(json)).toList();
    } catch (e) {
      throw Exception('Failed to search plants: $e');
    }
  }

  Future<void> updateIdentification(
    String identificationId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _apiClient.put('/plant-id/$identificationId', data: updateData);
    } catch (e) {
      throw Exception('Failed to update identification: $e');
    }
  }

  Future<void> deleteIdentification(String identificationId) async {
    try {
      await _apiClient.delete('/plant-id/$identificationId');
    } catch (e) {
      throw Exception('Failed to delete identification: $e');
    }
  }

  Future<Map<String, dynamic>> getIdentificationStats() async {
    try {
      final response = await _apiClient.get('/plant-id/stats');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get identification statistics: $e');
    }
  }

  /// Save an identified plant to the user's collection
  Future<void> saveIdentificationToCollection(String identificationId) async {
    try {
      await _apiClient.post(
        '/plant-id/$identificationId/save-to-collection',
        data: {'add_to_collection': true},
      );
    } catch (e) {
      throw Exception('Failed to save plant to collection: $e');
    }
  }

  /// Helper method to parse identification response and handle data format differences
  PlantIdentification _parseIdentificationResponse(Map<String, dynamic> data) {
    // Convert backend response format to frontend model format
    return PlantIdentification(
      id: data['id'].toString(),
      scientificName:
          data['species']?['scientific_name'] ??
          data['identified_name'] ??
          'Unknown',
      commonName:
          data['species']?['common_name'] ??
          data['identified_name'] ??
          'Unknown Plant',
      confidence: (data['confidence_score'] ?? 0.0).toDouble(),
      alternativeNames: _extractAlternativeNames(data),
      imageUrl: data['image_path'] ?? '',
      careInfo: _extractCareInfo(data),
      identifiedAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      description: data['species']?['description'],
      tags: _extractTags(data),
    );
  }

  List<String> _extractAlternativeNames(Map<String, dynamic> data) {
    final List<String> names = [];

    // Add scientific name if different from common name
    final scientificName = data['species']?['scientific_name'];
    if (scientificName != null && scientificName != data['identified_name']) {
      names.add(scientificName);
    }

    // Add common names from species data
    final commonNames = data['species']?['common_names'];
    if (commonNames is List) {
      names.addAll(commonNames.cast<String>());
    }

    return names;
  }

  PlantCareInfo _extractCareInfo(Map<String, dynamic> data) {
    final species = data['species'];

    return PlantCareInfo(
      lightRequirement: species?['light_requirements'] ?? 'Unknown',
      waterFrequency: species?['water_frequency_days'] != null
          ? 'Every ${species['water_frequency_days']} days'
          : 'Unknown',
      careLevel: species?['care_level'] ?? 'Unknown',
      humidity: species?['humidity_preference'],
      temperature: species?['temperature_range'],
      toxicity: species?['toxicity_info'],
      careNotes: species?['care_notes'] != null
          ? [species['care_notes']]
          : null,
    );
  }

  List<String>? _extractTags(Map<String, dynamic> data) {
    final species = data['species'];
    final List<String> tags = [];

    // Add plant type/category as tags
    if (species?['plant_type'] != null) {
      tags.add(species['plant_type']);
    }

    // Add care difficulty as tag
    if (species?['care_difficulty'] != null) {
      tags.add(species['care_difficulty']);
    }

    return tags.isNotEmpty ? tags : null;
  }

  /// Helper method to convert backend plant species format to frontend model
  plant_care.PlantSpecies _parsePlantSpeciesResponse(
    Map<String, dynamic> data,
  ) {
    return plant_care.PlantSpecies(
      id: data['id'].toString(),
      commonName: data['common_names']?.isNotEmpty == true
          ? data['common_names'][0]
          : data['scientific_name'] ?? 'Unknown Plant',
      scientificName: data['scientific_name'] ?? 'Unknown',
      family: data['family'],
      description: data['description'],
      imageUrl: data['image_url'],
      alternativeNames: data['common_names']?.cast<String>(),
      nativeRegions: null, // Not provided by backend
      maxHeight: null, // Not provided by backend
      bloomTime: null, // Not provided by backend
      plantType: null, // Not provided by backend
      careInfo: plant_care.PlantCareInfo(
        lightRequirement: data['light_requirements'] ?? 'Unknown',
        waterFrequency: data['water_frequency_days'] != null
            ? 'Every ${data['water_frequency_days']} days'
            : 'Unknown',
        careLevel: data['care_level'] ?? 'Unknown',
        humidity: data['humidity_preference'],
        temperature: data['temperature_range'],
        toxicity: data['toxicity_info'],
        additionalCare: data['care_notes'] != null
            ? {'notes': data['care_notes']}
            : null,
      ),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }
}
