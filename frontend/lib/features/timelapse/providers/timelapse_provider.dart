import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/core/services/api_service.dart';
import 'package:plant_social/features/timelapse/models/timelapse_models.dart';
import 'package:plant_social/features/timelapse/models/timelapse_models_extended.dart';
import 'package:plant_social/features/timelapse/models/timelapse_state.dart';
import 'package:plant_social/features/timelapse/services/timelapse_service.dart';

// Service provider
final timelapseServiceProvider = Provider<TimelapseService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TimelapseService(apiService);
});

// Main state provider
final timelapseProvider = StateNotifierProvider<TimelapseNotifier, TimelapseState>((ref) {
  final service = ref.watch(timelapseServiceProvider);
  return TimelapseNotifier(service);
});

// Individual providers for specific use cases
final timelapseSessions = Provider<List<TimelapseSession>>((ref) {
  return ref.watch(timelapseProvider).sessions;
});

final activeSessionProvider = Provider<TimelapseSession?>((ref) {
  return ref.watch(timelapseProvider).activeSession;
});

final growthAnalyticsProvider = Provider<GrowthAnalytics?>((ref) {
  return ref.watch(timelapseProvider).growthAnalytics;
});

final growthMilestonesProvider = Provider<List<GrowthMilestone>>((ref) {
  return ref.watch(timelapseProvider).growthMilestones;
});

// Individual session provider
final timelapseSessionProvider = FutureProvider.family<TimelapseSession, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getSession(sessionId);
});

// Sessions for specific plant
final plantTimelapseSessionsProvider = FutureProvider.family<List<TimelapseSession>, String>((ref, plantId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getSessions(plantId: plantId);
});

// Photos for session
final sessionPhotosProvider = FutureProvider.family<List<Map<String, dynamic>>, SessionPhotosParams>((ref, params) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getPhotos(
    sessionId: params.sessionId,
    startDate: params.startDate,
    endDate: params.endDate,
    limit: params.limit,
  );
});

// Growth analysis for session
final sessionGrowthAnalysisProvider = FutureProvider.family<GrowthAnalysis, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getGrowthAnalysis(sessionId);
});

// Growth analytics for session
final sessionGrowthAnalyticsProvider = FutureProvider.family<GrowthAnalytics, GrowthAnalyticsParams>((ref, params) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getGrowthAnalytics(
    sessionId: params.sessionId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Milestones for session
final sessionMilestonesProvider = FutureProvider.family<List<GrowthMilestone>, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getMilestones(sessionId);
});

// Video for session
final sessionVideoProvider = FutureProvider.family<TimelapseVideo?, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getVideo(sessionId);
});

// Video status for session
final sessionVideoStatusProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getVideoStatus(sessionId);
});

// Photo schedule for session
final sessionPhotoScheduleProvider = FutureProvider.family<PhotoSchedule?, String>((ref, sessionId) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getPhotoSchedule(sessionId);
});

// Growth comparison provider
final growthComparisonProvider = FutureProvider.family<List<GrowthComparison>, GrowthComparisonParams>((ref, params) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.compareGrowth(
    sessionIds: params.sessionIds,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Recent sessions provider
final recentSessionsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.watch(timelapseServiceProvider);
  return service.getRecentSessions(limit: limit);
});

class TimelapseNotifier extends StateNotifier<TimelapseState> {
  final TimelapseService _service;

  TimelapseNotifier(this._service) : super(const TimelapseState());

  // Session Management
  Future<void> loadSessions({
    String? plantId,
    String? status,
    int? limit,
  }) async {
    state = state.copyWith(isLoadingSessions: true, error: null);
    try {
      final sessions = await _service.getSessions(
        plantId: plantId,
        status: status,
        limit: limit,
      );
      state = state.copyWith(
        sessions: sessions,
        isLoadingSessions: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSessions: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSession({
    required String plantId,
    required String name,
    required TrackingConfig config,
    String? description,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final session = await _service.createSession(
        plantId: plantId,
        name: name,
        config: config,
        description: description,
      );
      state = state.copyWith(
        sessions: [...state.sessions, session],
        activeSession: session,
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoadingSession: true, error: null);
    try {
      final session = await _service.getSession(sessionId);
      state = state.copyWith(
        activeSession: session,
        isLoadingSession: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSession: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedSession = await _service.updateSession(sessionId, updates);
      final updatedSessions = state.sessions.map((session) {
        return session.sessionId == sessionId ? updatedSession : session;
      }).toList();
      
      state = state.copyWith(
        sessions: updatedSessions,
        activeSession: state.activeSession?.sessionId == sessionId ? updatedSession : state.activeSession,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _service.deleteSession(sessionId);
      final updatedSessions = state.sessions.where((session) => session.sessionId != sessionId).toList();
      
      state = state.copyWith(
        sessions: updatedSessions,
        activeSession: state.activeSession?.sessionId == sessionId ? null : state.activeSession,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Photo Management
  Future<void> uploadPhoto({
    required String sessionId,
    required String filePath,
    DateTime? capturedAt,
    PlantMeasurements? measurements,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isUploadingPhoto: true, error: null);
    try {
      final photoData = await _service.uploadPhoto(
        sessionId: sessionId,
        filePath: filePath,
        capturedAt: capturedAt,
        measurements: measurements,
        metadata: metadata,
      );
      
      // Add photo to session photos list if we have it loaded
      final updatedPhotos = [...state.sessionPhotos, photoData];
      state = state.copyWith(
        sessionPhotos: updatedPhotos,
        isUploadingPhoto: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingPhoto: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadSessionPhotos({
    required String sessionId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    state = state.copyWith(isLoadingPhotos: true, error: null);
    try {
      final photos = await _service.getPhotos(
        sessionId: sessionId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      state = state.copyWith(
        sessionPhotos: photos,
        isLoadingPhotos: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPhotos: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePhoto(String sessionId, String photoId) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _service.deletePhoto(sessionId, photoId);
      final updatedPhotos = state.sessionPhotos.where((photo) => photo['id'] != photoId).toList();
      
      state = state.copyWith(
        sessionPhotos: updatedPhotos,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Video Generation
  Future<void> generateVideo({
    required String sessionId,
    required VideoOptions options,
  }) async {
    state = state.copyWith(isGeneratingVideo: true, error: null);
    try {
      final videoData = await _service.generateVideo(
        sessionId: sessionId,
        options: options,
      );
      state = state.copyWith(
        videoGenerationStatus: videoData,
        isGeneratingVideo: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingVideo: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> checkVideoStatus(String sessionId) async {
    try {
      final status = await _service.getVideoStatus(sessionId);
      state = state.copyWith(videoGenerationStatus: status);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadSessionVideo(String sessionId) async {
    state = state.copyWith(isLoadingVideo: true, error: null);
    try {
      final video = await _service.getVideo(sessionId);
      state = state.copyWith(
        sessionVideo: video,
        isLoadingVideo: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingVideo: false,
        error: e.toString(),
      );
    }
  }

  // Growth Analysis
  Future<void> loadGrowthAnalysis(String sessionId) async {
    state = state.copyWith(isLoadingAnalysis: true, error: null);
    try {
      final analysis = await _service.getGrowthAnalysis(sessionId);
      state = state.copyWith(
        growthAnalysis: analysis,
        isLoadingAnalysis: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAnalysis: false,
        error: e.toString(),
      );
    }
  }

  Future<void> triggerGrowthAnalysis(String sessionId) async {
    state = state.copyWith(isAnalyzing: true, error: null);
    try {
      final analysis = await _service.triggerGrowthAnalysis(sessionId);
      state = state.copyWith(
        growthAnalysis: analysis,
        isAnalyzing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Growth Analytics
  Future<void> loadGrowthAnalytics({
    required String sessionId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoadingAnalytics: true, error: null);
    try {
      final analytics = await _service.getGrowthAnalytics(
        sessionId: sessionId,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        growthAnalytics: analytics,
        isLoadingAnalytics: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAnalytics: false,
        error: e.toString(),
      );
    }
  }

  // Growth Milestones
  Future<void> loadGrowthMilestones(String sessionId) async {
    state = state.copyWith(isLoadingMilestones: true, error: null);
    try {
      final milestones = await _service.getMilestones(sessionId);
      state = state.copyWith(
        growthMilestones: milestones,
        isLoadingMilestones: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMilestones: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createMilestone({
    required String sessionId,
    required String name,
    required String description,
    required DateTime targetDate,
    Map<String, dynamic>? criteria,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final milestone = await _service.createMilestone(
        sessionId: sessionId,
        name: name,
        description: description,
        targetDate: targetDate,
        criteria: criteria,
      );
      state = state.copyWith(
        growthMilestones: [...state.growthMilestones, milestone],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateMilestone(
    String sessionId,
    String milestoneId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedMilestone = await _service.updateMilestone(
        sessionId,
        milestoneId,
        updates,
      );
      final updatedMilestones = state.growthMilestones.map((milestone) {
        return milestone.milestoneId == milestoneId ? updatedMilestone : milestone;
      }).toList();
      
      state = state.copyWith(
        growthMilestones: updatedMilestones,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Photo Schedule Management
  Future<void> createPhotoSchedule({
    required String sessionId,
    required String frequency,
    required DateTime startTime,
    DateTime? endTime,
    Map<String, dynamic>? settings,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final schedule = await _service.createPhotoSchedule(
        sessionId: sessionId,
        frequency: frequency,
        startTime: startTime,
        endTime: endTime,
        settings: settings,
      );
      state = state.copyWith(
        photoSchedule: schedule,
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadPhotoSchedule(String sessionId) async {
    state = state.copyWith(isLoadingSchedule: true, error: null);
    try {
      final schedule = await _service.getPhotoSchedule(sessionId);
      state = state.copyWith(
        photoSchedule: schedule,
        isLoadingSchedule: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSchedule: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updatePhotoSchedule(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedSchedule = await _service.updatePhotoSchedule(
        sessionId,
        updates,
      );
      state = state.copyWith(
        photoSchedule: updatedSchedule,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deletePhotoSchedule(String sessionId) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _service.deletePhotoSchedule(sessionId);
      state = state.copyWith(
        photoSchedule: null,
        isDeleting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Utility methods
  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const TimelapseState();
  }

  void setActiveSession(TimelapseSession? session) {
    state = state.copyWith(activeSession: session);
  }

  // Auto-refresh functionality
  Future<void> refreshSessionData(String sessionId) async {
    await Future.wait([
      loadSession(sessionId),
      loadSessionPhotos(sessionId: sessionId),
      loadGrowthMilestones(sessionId),
      loadPhotoSchedule(sessionId),
    ]);
  }
}

// Helper classes for provider parameters
class SessionPhotosParams {
  final String sessionId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const SessionPhotosParams({
    required this.sessionId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionPhotosParams &&
        other.sessionId == sessionId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(sessionId, startDate, endDate, limit);
}

class GrowthAnalyticsParams {
  final String sessionId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GrowthAnalyticsParams({
    required this.sessionId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthAnalyticsParams &&
        other.sessionId == sessionId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(sessionId, startDate, endDate);
}

class GrowthComparisonParams {
  final List<String> sessionIds;
  final DateTime? startDate;
  final DateTime? endDate;

  const GrowthComparisonParams({
    required this.sessionIds,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthComparisonParams &&
        other.sessionIds == sessionIds &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(sessionIds, startDate, endDate);
}