import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/network/api_client.dart';
import 'package:leafwise/features/plant_identification/models/plant_identification_models.dart';
import 'package:leafwise/features/plant_care/models/plant_care_models.dart';
import 'package:leafwise/features/plant_identification/services/plant_identification_service.dart';
import 'dart:io';

// Service provider
final plantIdentificationServiceProvider = Provider<PlantIdentificationService>(
  (ref) => PlantIdentificationService(ref.read(apiClientProvider)),
);

// State notifier for plant identification
class PlantIdentificationNotifier
    extends StateNotifier<PlantIdentificationState> {
  final PlantIdentificationService _service;

  PlantIdentificationNotifier(this._service)
    : super(const PlantIdentificationState());

  Future<void> identifyPlant(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final identification = await _service.identifyPlant(imageFile);
      state = state.copyWith(
        isLoading: false,
        currentIdentification: identification,
        identifications: [identification, ...state.identifications],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadIdentificationHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await _service.getIdentificationHistory();
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchPlants(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(identifications: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _service.searchPlants(query);
      state = state.copyWith(isLoading: false, identifications: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveToCollection(String identificationId) async {
    try {
      await _service.saveIdentificationToCollection(identificationId);
      // Show success message or update UI as needed
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentIdentification() {
    state = state.copyWith(currentIdentification: null);
  }

  void clearSearch() {
    state = state.copyWith(identifications: [], error: null);
  }
}

// State notifier provider
final plantIdentificationProvider =
    StateNotifierProvider<
      PlantIdentificationNotifier,
      PlantIdentificationState
    >(
      (ref) => PlantIdentificationNotifier(
        ref.read(plantIdentificationServiceProvider),
      ),
    );

// Individual providers for specific use cases
final plantIdentificationHistoryProvider =
    FutureProvider<List<PlantIdentification>>(
      (ref) => ref
          .read(plantIdentificationServiceProvider)
          .getIdentificationHistory(),
    );

final plantSpeciesProvider = FutureProvider.family<PlantSpecies, String>(
  (ref, speciesId) =>
      ref.read(plantIdentificationServiceProvider).getPlantSpecies(speciesId),
);
