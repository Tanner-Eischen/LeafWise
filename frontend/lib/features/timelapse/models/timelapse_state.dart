library timelapse_state;

import 'timelapse_models.dart';
import 'timelapse_models_extended.dart';

/// State management for time-lapse features
/// 
/// This file contains the TimelapseState class that manages the overall state
/// of the time-lapse feature including sessions, analytics, and UI states.

class TimelapseState {
  final List<TimelapseSession> sessions;
  final TimelapseSession? activeSession;
  final GrowthAnalytics? growthAnalytics;
  final List<GrowthMilestone> growthMilestones;
  final PhotoSchedule? photoSchedule;
  final bool isLoadingSessions;
  final bool isCreating;
  final bool isLoadingSession;
  final bool isUpdating;
  final bool isDeleting;
  final bool isUploadingPhoto;
  final bool isGeneratingVideo;
  final bool isAnalyzingGrowth;
  final bool isLoadingMilestones;
  final bool isLoadingAnalytics;
  final bool isLoadingSchedule;
  final bool isLoadingPhotos;
  final bool isLoadingVideo;
  final bool isLoadingAnalysis;
  final bool isAnalyzing;
  final List<Map<String, dynamic>> sessionPhotos;
  final Map<String, dynamic>? videoGenerationStatus;
  final TimelapseVideo? sessionVideo;
  final GrowthAnalysis? growthAnalysis;
  final String? error;
  final bool isLoading;
  final bool isProcessingPhoto;
  final List<GrowthAnalysis> recentAnalyses;
  final List<GrowthMilestone> achievements;
  final TimelapseVideo? currentVideo;
  final DateTime? lastPhotoCapture;

  const TimelapseState({
    this.sessions = const [],
    this.activeSession,
    this.growthAnalytics,
    this.growthMilestones = const [],
    this.photoSchedule,
    this.isLoadingSessions = false,
    this.isCreating = false,
    this.isLoadingSession = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isUploadingPhoto = false,
    this.isGeneratingVideo = false,
    this.isAnalyzingGrowth = false,
    this.isLoadingMilestones = false,
    this.isLoadingAnalytics = false,
    this.isLoadingSchedule = false,
    this.isLoadingPhotos = false,
    this.isLoadingVideo = false,
    this.isLoadingAnalysis = false,
    this.isAnalyzing = false,
    this.sessionPhotos = const [],
    this.videoGenerationStatus,
    this.sessionVideo,
    this.growthAnalysis,
    this.error,
    this.isLoading = false,
    this.isProcessingPhoto = false,
    this.recentAnalyses = const [],
    this.achievements = const [],
    this.currentVideo,
    this.lastPhotoCapture,
  });

  factory TimelapseState.fromJson(Map<String, dynamic> json) {
    return TimelapseState(
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => TimelapseSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeSession: json['activeSession'] != null
          ? TimelapseSession.fromJson(json['activeSession'] as Map<String, dynamic>)
          : null,
      growthAnalytics: json['growthAnalytics'] != null
          ? GrowthAnalytics.fromJson(json['growthAnalytics'] as Map<String, dynamic>)
          : null,
      growthMilestones: (json['growthMilestones'] as List? ?? [])
          .map((e) => GrowthMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoSchedule: json['photoSchedule'] != null
          ? PhotoSchedule.fromJson(json['photoSchedule'] as Map<String, dynamic>)
          : null,
      isLoadingSessions: json['isLoadingSessions'] as bool? ?? false,
      isCreating: json['isCreating'] as bool? ?? false,
      isLoadingSession: json['isLoadingSession'] as bool? ?? false,
      isUpdating: json['isUpdating'] as bool? ?? false,
      isDeleting: json['isDeleting'] as bool? ?? false,
      isUploadingPhoto: json['isUploadingPhoto'] as bool? ?? false,
      isGeneratingVideo: json['isGeneratingVideo'] as bool? ?? false,
      isAnalyzingGrowth: json['isAnalyzingGrowth'] as bool? ?? false,
      isLoadingMilestones: json['isLoadingMilestones'] as bool? ?? false,
      isLoadingAnalytics: json['isLoadingAnalytics'] as bool? ?? false,
      isLoadingSchedule: json['isLoadingSchedule'] as bool? ?? false,
      isLoadingPhotos: json['isLoadingPhotos'] as bool? ?? false,
      isLoadingVideo: json['isLoadingVideo'] as bool? ?? false,
      isLoadingAnalysis: json['isLoadingAnalysis'] as bool? ?? false,
      isAnalyzing: json['isAnalyzing'] as bool? ?? false,
      sessionPhotos: (json['sessionPhotos'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      videoGenerationStatus: json['videoGenerationStatus'] as Map<String, dynamic>?,
      sessionVideo: json['sessionVideo'] != null
          ? TimelapseVideo.fromJson(json['sessionVideo'] as Map<String, dynamic>)
          : null,
      growthAnalysis: json['growthAnalysis'] != null
          ? GrowthAnalysis.fromJson(json['growthAnalysis'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      isProcessingPhoto: json['isProcessingPhoto'] as bool? ?? false,
      recentAnalyses: (json['recentAnalyses'] as List? ?? [])
          .map((e) => GrowthAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List? ?? [])
          .map((e) => GrowthMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentVideo: json['currentVideo'] != null
          ? TimelapseVideo.fromJson(json['currentVideo'] as Map<String, dynamic>)
          : null,
      lastPhotoCapture: json['lastPhotoCapture'] != null
          ? DateTime.parse(json['lastPhotoCapture'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'activeSession': activeSession?.toJson(),
      'growthAnalytics': growthAnalytics?.toJson(),
      'growthMilestones': growthMilestones.map((e) => e.toJson()).toList(),
      'photoSchedule': photoSchedule?.toJson(),
      'isLoadingSessions': isLoadingSessions,
      'isCreating': isCreating,
      'isLoadingSession': isLoadingSession,
      'isUpdating': isUpdating,
      'isDeleting': isDeleting,
      'isUploadingPhoto': isUploadingPhoto,
      'isGeneratingVideo': isGeneratingVideo,
      'isAnalyzingGrowth': isAnalyzingGrowth,
      'isLoadingMilestones': isLoadingMilestones,
      'isLoadingAnalytics': isLoadingAnalytics,
      'isLoadingSchedule': isLoadingSchedule,
      'isLoadingPhotos': isLoadingPhotos,
      'isLoadingVideo': isLoadingVideo,
      'isLoadingAnalysis': isLoadingAnalysis,
      'isAnalyzing': isAnalyzing,
      'sessionPhotos': sessionPhotos,
      'videoGenerationStatus': videoGenerationStatus,
      'sessionVideo': sessionVideo?.toJson(),
      'growthAnalysis': growthAnalysis?.toJson(),
      'error': error,
      'isLoading': isLoading,
      'isProcessingPhoto': isProcessingPhoto,
      'recentAnalyses': recentAnalyses.map((e) => e.toJson()).toList(),
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'currentVideo': currentVideo?.toJson(),
      'lastPhotoCapture': lastPhotoCapture?.toIso8601String(),
    };
  }

  TimelapseState copyWith({
    List<TimelapseSession>? sessions,
    TimelapseSession? activeSession,
    GrowthAnalytics? growthAnalytics,
    List<GrowthMilestone>? growthMilestones,
    PhotoSchedule? photoSchedule,
    bool? isLoadingSessions,
    bool? isCreating,
    bool? isLoadingSession,
    bool? isUpdating,
    bool? isDeleting,
    bool? isUploadingPhoto,
    bool? isGeneratingVideo,
    bool? isAnalyzingGrowth,
    bool? isLoadingMilestones,
    bool? isLoadingAnalytics,
    bool? isLoadingSchedule,
    bool? isLoadingPhotos,
    bool? isLoadingVideo,
    bool? isLoadingAnalysis,
    bool? isAnalyzing,
    List<Map<String, dynamic>>? sessionPhotos,
    Map<String, dynamic>? videoGenerationStatus,
    TimelapseVideo? sessionVideo,
    GrowthAnalysis? growthAnalysis,
    String? error,
    bool? isLoading,
    bool? isProcessingPhoto,
    List<GrowthAnalysis>? recentAnalyses,
    List<GrowthMilestone>? achievements,
    TimelapseVideo? currentVideo,
    DateTime? lastPhotoCapture,
  }) {
    return TimelapseState(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      growthAnalytics: growthAnalytics ?? this.growthAnalytics,
      growthMilestones: growthMilestones ?? this.growthMilestones,
      photoSchedule: photoSchedule ?? this.photoSchedule,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      isCreating: isCreating ?? this.isCreating,
      isLoadingSession: isLoadingSession ?? this.isLoadingSession,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isGeneratingVideo: isGeneratingVideo ?? this.isGeneratingVideo,
      isAnalyzingGrowth: isAnalyzingGrowth ?? this.isAnalyzingGrowth,
      isLoadingMilestones: isLoadingMilestones ?? this.isLoadingMilestones,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      isLoadingPhotos: isLoadingPhotos ?? this.isLoadingPhotos,
      isLoadingVideo: isLoadingVideo ?? this.isLoadingVideo,
      isLoadingAnalysis: isLoadingAnalysis ?? this.isLoadingAnalysis,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      sessionPhotos: sessionPhotos ?? this.sessionPhotos,
      videoGenerationStatus: videoGenerationStatus ?? this.videoGenerationStatus,
      sessionVideo: sessionVideo ?? this.sessionVideo,
      growthAnalysis: growthAnalysis ?? this.growthAnalysis,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isProcessingPhoto: isProcessingPhoto ?? this.isProcessingPhoto,
      recentAnalyses: recentAnalyses ?? this.recentAnalyses,
      achievements: achievements ?? this.achievements,
      currentVideo: currentVideo ?? this.currentVideo,
      lastPhotoCapture: lastPhotoCapture ?? this.lastPhotoCapture,
    );
  }
}