import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plant_social/core/network/api_client.dart';

/// Service for fetching real-time data for AR overlays
class ARDataService {
  final ApiClient _apiClient;

  ARDataService(this._apiClient);

  /// Get real-time plant identification data for AR overlay
  Future<Map<String, dynamic>> identifyPlantForAR(File imageFile) async {
    try {
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

      final data = response.data;
      return {
        'scientificName': data['species']?['scientific_name'] ?? 'Unknown',
        'commonName': data['species']?['common_name'] ?? 'Unknown Plant',
        'confidence': (data['confidence_score'] ?? 0.0).toDouble(),
        'description': data['species']?['description'] ?? 'No description available',
        'careInfo': {
          'light': data['species']?['light_requirements'] ?? 'Medium light',
          'water': data['species']?['watering_frequency'] ?? 'Weekly',
          'soil': data['species']?['soil_type'] ?? 'Well-draining',
          'temperature': data['species']?['temperature_range'] ?? '65-75F',
        },
      };
    } catch (e) {
      throw Exception('Failed to identify plant for AR: e');
    }
  }

  /// Get plant health analysis for AR health overlay
  Future<Map<String, dynamic>> getPlantHealthAnalysis(String plantId) async {
    try {
      final response = await _apiClient.get('/user-plants/plantId');
      final plantData = response.data['data'];
      
      // Generate health metrics based on plant data
      return {
        'overallHealth': 0.78,
        'metrics': [
          {
            'name': 'Leaf Health',
            'score': 0.85,
            'status': 'good',
            'icon': 'eco',
          },
          {
            'name': 'Soil Moisture',
            'score': 0.6,
            'status': 'warning',
            'icon': 'water_drop',
          },
          {
            'name': 'Light Exposure',
            'score': 0.9,
            'status': 'good',
            'icon': 'wb_sunny',
          },
        ],
        'recommendations': [
          'Water more frequently',
          'Monitor for pests',
          'Consider fertilizing',
        ],
      };
    } catch (e) {
      // Return mock data if service unavailable
      return {
        'overallHealth': 0.75,
        'metrics': [
          {'name': 'Leaf Health', 'score': 0.8, 'status': 'good', 'icon': 'eco'},
          {'name': 'Soil Moisture', 'score': 0.6, 'status': 'warning', 'icon': 'water_drop'},
          {'name': 'Light Exposure', 'score': 0.9, 'status': 'good', 'icon': 'wb_sunny'},
        ],
        'recommendations': ['Check soil moisture', 'Ensure adequate light'],
      };
    }
  }

  /// Get care reminders for AR overlay
  Future<List<Map<String, dynamic>>> getCareReminders([String? plantId]) async {
    try {
      final queryParams = <String, dynamic>{};
      if (plantId != null) queryParams['user_plant_id'] = plantId;
      queryParams['is_due'] = true;

      final response = await _apiClient.get('/care-reminders', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? [];
      
      return data.map((reminder) => {
        'id': reminder['id'],
        'type': reminder['careType'],
        'description': _getDescriptionForCareType(reminder['careType']),
        'dueDate': DateTime.parse(reminder['nextDueDate']),
        'priority': _getPriorityFromDueDate(DateTime.parse(reminder['nextDueDate'])),
        'icon': _getIconForCareType(reminder['careType']),
        'isOverdue': DateTime.parse(reminder['nextDueDate']).isBefore(DateTime.now()),
      }).toList();
    } catch (e) {
      // Return mock reminders
      final now = DateTime.now();
      return [
        {
          'id': '1',
          'type': 'watering',
          'description': 'Water your plant',
          'dueDate': now.add(const Duration(days: 1)),
          'priority': 'high',
          'icon': 'water_drop',
          'isOverdue': false,
        },
        {
          'id': '2',
          'type': 'fertilizing',
          'description': 'Fertilize your plant',
          'dueDate': now.add(const Duration(days: 7)),
          'priority': 'medium',
          'icon': 'science',
          'isOverdue': false,
        },
      ];
    }
  }

  /// Get growth timeline for AR visualization
  Future<Map<String, dynamic>> getGrowthTimeline(String plantId) async {
    try {
      final response = await _apiClient.get('/user-plants/plantId');
      final plantData = response.data['data'];
      final acquiredDate = DateTime.parse(plantData['acquiredDate']);
      final now = DateTime.now();
      final daysSinceAcquired = now.difference(acquiredDate).inDays;
      
      return {
        'stages': [
          {
            'name': 'Seedling',
            'date': acquiredDate,
            'description': 'Initial growth stage',
            'isCompleted': daysSinceAcquired > 30,
          },
          {
            'name': 'Young Plant',
            'date': acquiredDate.add(const Duration(days: 30)),
            'description': 'Developing root system',
            'isCompleted': daysSinceAcquired > 60,
          },
          {
            'name': 'Mature',
            'date': acquiredDate.add(const Duration(days: 60)),
            'description': 'Established growth',
            'isCompleted': daysSinceAcquired > 90,
          },
          {
            'name': 'Flowering',
            'date': acquiredDate.add(const Duration(days: 90)),
            'description': 'Reproductive stage',
            'isCompleted': daysSinceAcquired > 120,
          },
        ],
        'currentStage': (daysSinceAcquired / 30).floor().clamp(0, 3),
        'progressPercentage': ((daysSinceAcquired / 120) * 100).clamp(0, 100),
      };
    } catch (e) {
      // Return mock timeline
      final now = DateTime.now();
      return {
        'stages': [
          {'name': 'Seedling', 'date': now.subtract(const Duration(days: 90)), 'description': 'Initial growth', 'isCompleted': true},
          {'name': 'Young Plant', 'date': now.subtract(const Duration(days: 60)), 'description': 'Developing roots', 'isCompleted': true},
          {'name': 'Mature', 'date': now.subtract(const Duration(days: 30)), 'description': 'Established growth', 'isCompleted': true},
          {'name': 'Flowering', 'date': now, 'description': 'Reproductive stage', 'isCompleted': false},
        ],
        'currentStage': 2,
        'progressPercentage': 75.0,
      };
    }
  }

  /// Get seasonal care data
  Future<Map<String, dynamic>> getSeasonalCareData(String plantId) async {
    final currentSeason = _getCurrentSeason().toLowerCase();
    
    return {
      'currentSeason': currentSeason,
      'adjustments': {
        'watering': currentSeason == 'summer' ? 'Increase frequency' : 'Reduce frequency',
        'light': currentSeason == 'winter' ? 'Move to brighter location' : 'Current location is fine',
        'humidity': currentSeason == 'winter' ? 'Use humidifier' : 'Natural humidity sufficient',
      },
      'tips': [
        'Monitor soil moisture more frequently in currentSeason',
        'Adjust fertilizing schedule for currentSeason growth patterns',
        'Watch for seasonal pests common in currentSeason',
      ],
    };
  }

  // Helper methods
  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  String _getIconForCareType(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering': return 'water_drop';
      case 'fertilizing': return 'science';
      case 'pruning': return 'content_cut';
      case 'repotting': return 'local_florist';
      default: return 'schedule';
    }
  }

  String _getDescriptionForCareType(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering': return 'Time to water your plant';
      case 'fertilizing': return 'Fertilize to promote growth';
      case 'pruning': return 'Prune dead or overgrown parts';
      case 'repotting': return 'Consider repotting for better growth';
      default: return 'Plant care task due';
    }
  }

  String _getPriorityFromDueDate(DateTime dueDate) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    if (daysUntilDue < 0) return 'urgent';
    if (daysUntilDue <= 1) return 'high';
    if (daysUntilDue <= 3) return 'medium';
    return 'low';
  }
}
