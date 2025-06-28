import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plant_social/core/network/api_client.dart';
import 'package:plant_social/features/plant_identification/models/plant_identification_models.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';

class PlantIdentificationService {
  final ApiClient _apiClient;

  PlantIdentificationService(this._apiClient);

  Future<PlantIdentification> identifyPlant(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = PlantIdentificationRequest(
        imageBase64: base64Image,
        timestamp: DateTime.now(),
      );

      final response = await _apiClient.post(
        '/plants/identify',
        data: request.toJson(),
      );

      return PlantIdentification.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to identify plant: $e');
    }
  }

  Future<List<PlantIdentification>> getIdentificationHistory() async {
    try {
      final response = await _apiClient.get('/plants/identification-history');
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PlantIdentification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get identification history: $e');
    }
  }

  Future<PlantSpecies> getPlantSpecies(String speciesId) async {
    try {
      final response = await _apiClient.get('/plants/species/$speciesId');
      return PlantSpecies.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get plant species: $e');
    }
  }

  Future<List<PlantIdentification>> searchPlants(String query) async {
    try {
      final response = await _apiClient.get(
        '/plants/search',
        queryParameters: {'q': query},
      );
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PlantIdentification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search plants: $e');
    }
  }

  Future<void> saveIdentificationToCollection(String identificationId) async {
    try {
      await _apiClient.post(
        '/plants/collection/add',
        data: {'identification_id': identificationId},
      );
    } catch (e) {
      throw Exception('Failed to save plant to collection: $e');
    }
  }
}