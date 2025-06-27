import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/core/services/api_service.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';
import 'package:plant_social/features/plant_care/services/plant_care_service.dart';

// Service provider
final plantCareServiceProvider = Provider<PlantCareService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PlantCareService(apiService);
});

// Main state provider
final plantCareProvider = StateNotifierProvider<PlantCareNotifier, PlantCareState>((ref) {
  final service = ref.watch(plantCareServiceProvider);
  return PlantCareNotifier(service);
});

// Individual providers for specific use cases
final userPlantsProvider = Provider<List<UserPlant>>((ref) {
  return ref.watch(plantCareProvider).userPlants;
});

final careLogsProvider = Provider<List<PlantCareLog>>((ref) {
  return ref.watch(plantCareProvider).careLogs;
});

final remindersProvider = Provider<List<PlantCareReminder>>((ref) {
  return ref.watch(plantCareProvider).reminders;
});

final upcomingRemindersProvider = Provider<List<PlantCareReminder>>((ref) {
  return ref.watch(plantCareProvider).upcomingReminders;
});

// Individual user plant provider
final userPlantProvider = FutureProvider.family<UserPlant, String>((ref, plantId) async {
  final service = ref.watch(plantCareServiceProvider);
  return service.getUserPlant(plantId);
});

// Plant species provider for selection
final plantSpeciesSearchProvider = FutureProvider.family<List<PlantSpecies>, String>((ref, query) async {
  final service = ref.watch(plantCareServiceProvider);
  return service.getPlantSpecies(search: query, limit: 20);
});

// Care statistics provider
final careStatisticsProvider = FutureProvider.family<Map<String, dynamic>, CareStatisticsParams>((ref, params) async {
  final service = ref.watch(plantCareServiceProvider);
  return service.getCareStatistics(
    userPlantId: params.userPlantId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

class PlantCareNotifier extends StateNotifier<PlantCareState> {
  final PlantCareService _service;

  PlantCareNotifier(this._service) : super(const PlantCareState());

  // User Plants
  Future<void> loadUserPlants() async {
    state = state.copyWith(isLoadingPlants: true, error: null);
    try {
      final plants = await _service.getUserPlants();
      state = state.copyWith(
        userPlants: plants,
        isLoadingPlants: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPlants: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createUserPlant(UserPlantRequest request) async {
    state = state.copyWith(isCreating: true, createError: null);
    try {
      final plant = await _service.createUserPlant(request);
      state = state.copyWith(
        userPlants: [...state.userPlants, plant],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        createError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateUserPlant(String plantId, UserPlantRequest request) async {
    state = state.copyWith(isUpdating: true, updateError: null);
    try {
      final updatedPlant = await _service.updateUserPlant(plantId, request);
      final updatedPlants = state.userPlants.map((plant) {
        return plant.id == plantId ? updatedPlant : plant;
      }).toList();
      
      state = state.copyWith(
        userPlants: updatedPlants,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteUserPlant(String plantId) async {
    state = state.copyWith(isDeleting: true, deleteError: null);
    try {
      await _service.deleteUserPlant(plantId);
      final updatedPlants = state.userPlants.where((plant) => plant.id != plantId).toList();
      
      state = state.copyWith(
        userPlants: updatedPlants,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        deleteError: e.toString(),
      );
      rethrow;
    }
  }

  // Care Logs
  Future<void> loadCareLogs({
    String? userPlantId,
    String? careType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoadingLogs: true, error: null);
    try {
      final logs = await _service.getCareLogs(
        userPlantId: userPlantId,
        careType: careType,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        careLogs: logs,
        isLoadingLogs: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLogs: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createCareLog(PlantCareRequest request) async {
    state = state.copyWith(isCreating: true, createError: null);
    try {
      final log = await _service.createCareLog(request);
      state = state.copyWith(
        careLogs: [log, ...state.careLogs],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        createError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateCareLog(String logId, PlantCareRequest request) async {
    state = state.copyWith(isUpdating: true, updateError: null);
    try {
      final updatedLog = await _service.updateCareLog(logId, request);
      final updatedLogs = state.careLogs.map((log) {
        return log.id == logId ? updatedLog : log;
      }).toList();
      
      state = state.copyWith(
        careLogs: updatedLogs,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteCareLog(String logId) async {
    state = state.copyWith(isDeleting: true, deleteError: null);
    try {
      await _service.deleteCareLog(logId);
      final updatedLogs = state.careLogs.where((log) => log.id != logId).toList();
      
      state = state.copyWith(
        careLogs: updatedLogs,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        deleteError: e.toString(),
      );
      rethrow;
    }
  }

  // Care Reminders
  Future<void> loadReminders({
    String? userPlantId,
    String? careType,
    bool? isActive,
  }) async {
    state = state.copyWith(isLoadingReminders: true, error: null);
    try {
      final reminders = await _service.getReminders(
        userPlantId: userPlantId,
        careType: careType,
        isActive: isActive,
      );
      state = state.copyWith(
        reminders: reminders,
        isLoadingReminders: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingReminders: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUpcomingReminders({int days = 7}) async {
    state = state.copyWith(isLoadingReminders: true, error: null);
    try {
      final reminders = await _service.getUpcomingReminders(days: days);
      state = state.copyWith(
        upcomingReminders: reminders,
        isLoadingReminders: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingReminders: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createReminder(PlantCareReminderRequest request) async {
    state = state.copyWith(isCreating: true, createError: null);
    try {
      final reminder = await _service.createReminder(request);
      state = state.copyWith(
        reminders: [...state.reminders, reminder],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        createError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateReminder(String reminderId, PlantCareReminderRequest request) async {
    state = state.copyWith(isUpdating: true, updateError: null);
    try {
      final updatedReminder = await _service.updateReminder(reminderId, request);
      final updatedReminders = state.reminders.map((reminder) {
        return reminder.id == reminderId ? updatedReminder : reminder;
      }).toList();
      
      state = state.copyWith(
        reminders: updatedReminders,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    state = state.copyWith(isDeleting: true, deleteError: null);
    try {
      await _service.deleteReminder(reminderId);
      final updatedReminders = state.reminders.where((reminder) => reminder.id != reminderId).toList();
      final updatedUpcoming = state.upcomingReminders.where((reminder) => reminder.id != reminderId).toList();
      
      state = state.copyWith(
        reminders: updatedReminders,
        upcomingReminders: updatedUpcoming,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        deleteError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> completeReminder(String reminderId) async {
    state = state.copyWith(isUpdating: true, updateError: null);
    try {
      final updatedReminder = await _service.completeReminder(reminderId);
      final updatedReminders = state.reminders.map((reminder) {
        return reminder.id == reminderId ? updatedReminder : reminder;
      }).toList();
      final updatedUpcoming = state.upcomingReminders.where((reminder) => reminder.id != reminderId).toList();
      
      state = state.copyWith(
        reminders: updatedReminders,
        upcomingReminders: updatedUpcoming,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> snoozeReminder(String reminderId, int days) async {
    state = state.copyWith(isUpdating: true, updateError: null);
    try {
      final updatedReminder = await _service.snoozeReminder(reminderId, days);
      final updatedReminders = state.reminders.map((reminder) {
        return reminder.id == reminderId ? updatedReminder : reminder;
      }).toList();
      final updatedUpcoming = state.upcomingReminders.map((reminder) {
        return reminder.id == reminderId ? updatedReminder : reminder;
      }).toList();
      
      state = state.copyWith(
        reminders: updatedReminders,
        upcomingReminders: updatedUpcoming,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      );
      rethrow;
    }
  }

  // Utility methods
  void clearErrors() {
    state = state.copyWith(
      error: null,
      createError: null,
      updateError: null,
      deleteError: null,
    );
  }

  void reset() {
    state = const PlantCareState();
  }
}

// Helper class for care statistics parameters
class CareStatisticsParams {
  final String? userPlantId;
  final DateTime? startDate;
  final DateTime? endDate;

  const CareStatisticsParams({
    this.userPlantId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CareStatisticsParams &&
        other.userPlantId == userPlantId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(userPlantId, startDate, endDate);
}