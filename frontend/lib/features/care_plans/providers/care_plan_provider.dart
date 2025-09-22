import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:leafwise/features/care_plans/services/care_plan_api_service.dart';
import 'package:leafwise/core/services/api_service.dart';
// Logger removed - using print for debugging if needed

// Service provider
final carePlanApiServiceProvider = Provider<CarePlanApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CarePlanApiService(apiService);
});

// Main state provider
final carePlanProvider = StateNotifierProvider<CarePlanNotifier, CarePlanState>(
  (ref) {
    final service = ref.watch(carePlanApiServiceProvider);
    return CarePlanNotifier(service);
  },
);

// Individual providers for specific use cases
final activeCarePlansProvider = Provider<List<CarePlan>>((ref) {
  return ref.watch(carePlanProvider).activePlans;
});

final carePlanHistoryProvider = Provider<List<CarePlanHistory>>((ref) {
  return ref.watch(carePlanProvider).planHistory;
});

final pendingNotificationsProvider = Provider<List<CarePlanNotification>>((
  ref,
) {
  return ref.watch(carePlanProvider).pendingNotifications;
});

// Individual care plan provider
final carePlanByIdProvider = FutureProvider.family<CarePlan?, String>((
  ref,
  planId,
) async {
  final service = ref.watch(carePlanApiServiceProvider);
  try {
    return await service.getCarePlan(planId);
  } catch (e) {
    return null;
  }
});

// Care plan generation provider
final generateCarePlanProvider =
    FutureProvider.family<CarePlanGenerationResponse, CarePlanGenerationRequest>((
      ref,
      request,
    ) async {
      final service = ref.watch(carePlanApiServiceProvider);
      return await service.generateCarePlan(
        request.userPlantId,
      );
    });

// Care plan history provider with pagination
final carePlanHistoryPaginatedProvider =
    FutureProvider.family<CarePlanHistoryResponse, CarePlanHistoryParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(carePlanApiServiceProvider);
      return service.getCarePlanHistory(
        params.userPlantId,
        limit: params.limit,
        offset: (params.page - 1) * params.limit, // Convert page to offset
      );
    });

class CarePlanNotifier extends StateNotifier<CarePlanState> {
  final CarePlanApiService _service;

  CarePlanNotifier(this._service) : super(const CarePlanState());

  /// Fetches the current active care plan for a given user plant.
  ///
  /// This method retrieves the most recent active care plan from the API service
  /// and updates the state accordingly. It handles loading, success, and error
  /// states.
  Future<void> getCurrentCarePlan({required String userPlantId}) async {
    state = state.copyWith(isLoadingPlans: true, error: null);
    try {
      final plan = await _service.getCurrentCarePlan(userPlantId);
      final plans = plan != null ? [plan] : <CarePlan>[];
      state = state.copyWith(activePlans: plans, isLoadingPlans: false);
    } catch (e) {
      state = state.copyWith(isLoadingPlans: false, error: e.toString());
      // Error getting current care plan: $e
    }
  }

  /// Acknowledges a care plan, marking it as reviewed by the user.
  ///
  /// This method sends an acknowledgment request to the API service for a
  /// specific care plan. It updates the state to reflect the acknowledgment
  /// process and handles any errors that may occur.
  Future<void> acknowledgeCarePlan({required String planId}) async {
    state = state.copyWith(acknowledgeError: null);
    try {
      await _service.acknowledgeCarePlan(planId);
      // Optionally, refresh the active plans after acknowledgment
      // This depends on whether acknowledgment changes the 'active' status
      // For now, assuming it might, so we refresh.
      final currentPlans = List<CarePlan>.from(state.activePlans);
      final acknowledgedPlanIndex =
          currentPlans.indexWhere((plan) => plan.id == planId);
      if (acknowledgedPlanIndex != -1) {
        final acknowledgedPlan =
            currentPlans[acknowledgedPlanIndex].copyWith(acknowledgedAt: DateTime.now());
        currentPlans[acknowledgedPlanIndex] = acknowledgedPlan;
        state = state.copyWith(activePlans: currentPlans);
      }
    } catch (e) {
      state = state.copyWith(acknowledgeError: e.toString());
      // Error acknowledging care plan: $e
    }
  }

  /// Generates a new care plan based on the provided request.
  ///
  /// This method sends a care plan generation request to the API service.
  /// It updates the state to indicate the generation process and stores
  /// the ID of the newly generated plan upon success.
  Future<CarePlanGenerationResponse?> generateCarePlan(
      {required CarePlanGenerationRequest request}) async {
    state = state.copyWith(isGenerating: true, generateError: null);
    try {
      final response = await _service.generateCarePlan(
        request.userPlantId,
      );
      state = state.copyWith(
          isGenerating: false, lastGeneratedPlanId: response.carePlan.id);
      return response;
    } catch (e) {
      state = state.copyWith(isGenerating: false, generateError: e.toString());
      // Error generating care plan: $e
      return null;
    }
  }
  // Load care plan history
  Future<void> loadPlanHistory({
    String? userPlantId,
    int page = 1,
    int limit = 20,
  }) async {
    if (page == 1) {
      state = state.copyWith(isLoadingHistory: true, historyError: null);
    }

    try {
      final response = await _service.getCarePlanHistory(
        userPlantId ?? '',
        limit: limit,
        offset: (page - 1) * limit,
      );

      List<CarePlanHistory> updatedHistory;
      if (page == 1) {
        updatedHistory = response.plans;
      } else {
        updatedHistory = [...state.planHistory, ...response.plans];
      }

      state = state.copyWith(
        planHistory: updatedHistory,
        isLoadingHistory: false,
        hasMoreHistory: response.hasMore,
        currentHistoryPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: e.toString(),
      );
    }
  }

  // Load more history (pagination)
  Future<void> loadMoreHistory({String? userPlantId}) async {
    if (state.isLoadingHistory || !state.hasMoreHistory) return;

    await loadPlanHistory(
      userPlantId: userPlantId,
      page: state.currentHistoryPage + 1,
    );
  }

  // Get specific care plan
  Future<CarePlan?> getCarePlan(String planId) async {
    try {
      // First check if it's in our active plans
      final existingPlan = state.activePlans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => throw StateError('Plan not found in active plans'),
      );
      return existingPlan;
    } catch (_) {
      // If not found in active plans, fetch from API
      // Note: planHistory contains CarePlanHistory objects, not full CarePlan objects
      try {
        return await _service.getCarePlan(planId);
      } catch (e) {
        state = state.copyWith(error: e.toString());
        return null;
      }
    }
  }

  // Load notifications
  // TODO: Implement notification API endpoints
  Future<void> loadNotifications() async {
    state = state.copyWith(
      isLoadingNotifications: true,
      notificationError: null,
    );
    try {
      // final notifications = await _service.getNotifications();
      final notifications = <CarePlanNotification>[];
      state = state.copyWith(
        pendingNotifications: notifications,
        isLoadingNotifications: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingNotifications: false,
        notificationError: e.toString(),
      );
    }
  }

  // Mark notification as read
  // TODO: Implement notification API endpoints
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // await _service.markNotificationAsRead(notificationId);

      // Remove from pending notifications
      final updatedNotifications = state.pendingNotifications
          .where((notification) => notification.id != notificationId)
          .toList();

      state = state.copyWith(pendingNotifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(notificationError: e.toString());
    }
  }

  // Clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clears any existing error messages related to care plan generation.
  void clearGenerateError() {
    state = state.copyWith(generateError: null);
  }

  /// Clears any existing error messages related to care plan acknowledgment.
  void clearAcknowledgeError() {
    state = state.copyWith(acknowledgeError: null);
  }
}
