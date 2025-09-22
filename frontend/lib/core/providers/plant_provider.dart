/// Plant Provider
///
/// Riverpod providers for managing plant data state across the application.
/// Provides access to plant information, care logs, reminders, and identification results.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant_models.dart';
import '../services/api_service.dart';

/// Plant service provider
final plantServiceProvider = Provider<PlantService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PlantService(apiService);
});

/// Plant state notifier
class PlantNotifier extends StateNotifier<PlantState> {
  final PlantService _service;

  PlantNotifier(this._service) : super(const PlantState.initial());

  /// Load plant by ID
  Future<void> loadPlant(String plantId) async {
    state = const PlantState.loading();
    try {
      final plant = await _service.getPlant(plantId);
      state = PlantState.loaded(plant);
    } catch (error) {
      state = PlantState.error(error.toString());
    }
  }

  /// Load all plants
  Future<void> loadPlants() async {
    state = const PlantState.loading();
    try {
      final plants = await _service.getPlants();
      state = PlantState.loadedList(plants);
    } catch (error) {
      state = PlantState.error(error.toString());
    }
  }

  /// Add new plant
  Future<void> addPlant(Plant plant) async {
    try {
      final newPlant = await _service.createPlant(plant);
      if (state is PlantStateLoadedList) {
        final currentPlants = (state as PlantStateLoadedList).plants;
        state = PlantState.loadedList([...currentPlants, newPlant]);
      }
    } catch (error) {
      state = PlantState.error(error.toString());
    }
  }

  /// Update plant
  Future<void> updatePlant(Plant plant) async {
    try {
      final updatedPlant = await _service.updatePlant(plant);
      if (state is PlantStateLoaded) {
        state = PlantState.loaded(updatedPlant);
      } else if (state is PlantStateLoadedList) {
        final currentPlants = (state as PlantStateLoadedList).plants;
        final updatedPlants = currentPlants.map((p) => p.id == plant.id ? updatedPlant : p).toList();
        state = PlantState.loadedList(updatedPlants);
      }
    } catch (error) {
      state = PlantState.error(error.toString());
    }
  }

  /// Delete plant
  Future<void> deletePlant(String plantId) async {
    try {
      await _service.deletePlant(plantId);
      if (state is PlantStateLoadedList) {
        final currentPlants = (state as PlantStateLoadedList).plants;
        final updatedPlants = currentPlants.where((p) => p.id != plantId).toList();
        state = PlantState.loadedList(updatedPlants);
      }
    } catch (error) {
      state = PlantState.error(error.toString());
    }
  }
}

/// Plant state
sealed class PlantState {
  const PlantState();

  const factory PlantState.initial() = PlantStateInitial;
  const factory PlantState.loading() = PlantStateLoading;
  const factory PlantState.loaded(Plant plant) = PlantStateLoaded;
  const factory PlantState.loadedList(List<Plant> plants) = PlantStateLoadedList;
  const factory PlantState.error(String message) = PlantStateError;
}

class PlantStateInitial extends PlantState {
  const PlantStateInitial();
}

class PlantStateLoading extends PlantState {
  const PlantStateLoading();
}

class PlantStateLoaded extends PlantState {
  final Plant plant;
  const PlantStateLoaded(this.plant);
}

class PlantStateLoadedList extends PlantState {
  final List<Plant> plants;
  const PlantStateLoadedList(this.plants);
}

class PlantStateError extends PlantState {
  final String message;
  const PlantStateError(this.message);
}

/// Main plant provider
final plantProvider = StateNotifierProvider<PlantNotifier, PlantState>((ref) {
  final service = ref.watch(plantServiceProvider);
  return PlantNotifier(service);
});

/// Individual plant provider
final plantByIdProvider = FutureProvider.family<Plant, String>((ref, plantId) async {
  final service = ref.watch(plantServiceProvider);
  return service.getPlant(plantId);
});

/// Plant service class
class PlantService {
  final ApiService _apiService;

  PlantService(this._apiService);

  Future<Plant> getPlant(String plantId) async {
    final response = await _apiService.get('/plants/$plantId');
    return Plant.fromJson(response.data);
  }

  Future<List<Plant>> getPlants() async {
    final response = await _apiService.get('/plants');
    return (response.data as List).map((json) => Plant.fromJson(json)).toList();
  }

  Future<Plant> createPlant(Plant plant) async {
    final response = await _apiService.post('/plants', data: plant.toJson());
    return Plant.fromJson(response.data);
  }

  Future<Plant> updatePlant(Plant plant) async {
    final response = await _apiService.put('/plants/${plant.id}', data: plant.toJson());
    return Plant.fromJson(response.data);
  }

  Future<void> deletePlant(String plantId) async {
    await _apiService.delete('/plants/$plantId');
  }
}