library timelapse_models_extended;

/// Extended time-lapse models for video generation, analytics, and state management
/// 
/// This file contains additional data models for video options, analytics,
/// and state management that complement the core timelapse models.

/// Time-lapse video generation options
class VideoOptions {
  final String quality; // 'low', 'medium', 'high', 'ultra'
  final double frameRate; // fps
  final String format; // 'mp4', 'webm'
  final bool includeMetricOverlays;
  final bool includeMilestoneMarkers;
  final bool includeAudio;
  final String? musicTrack;
  final Map<String, dynamic>? customSettings;

  const VideoOptions({
    required this.quality,
    required this.frameRate,
    required this.format,
    this.includeMetricOverlays = true,
    this.includeMilestoneMarkers = true,
    this.includeAudio = false,
    this.musicTrack,
    this.customSettings,
  });

  factory VideoOptions.fromJson(Map<String, dynamic> json) {
    return VideoOptions(
      quality: json['quality'] as String,
      frameRate: (json['frameRate'] as num).toDouble(),
      format: json['format'] as String,
      includeMetricOverlays: json['includeMetricOverlays'] as bool? ?? true,
      includeMilestoneMarkers: json['includeMilestoneMarkers'] as bool? ?? true,
      includeAudio: json['includeAudio'] as bool? ?? false,
      musicTrack: json['musicTrack'] as String?,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'frameRate': frameRate,
      'format': format,
      'includeMetricOverlays': includeMetricOverlays,
      'includeMilestoneMarkers': includeMilestoneMarkers,
      'includeAudio': includeAudio,
      'musicTrack': musicTrack,
      'customSettings': customSettings,
    };
  }

  VideoOptions copyWith({
    String? quality,
    double? frameRate,
    String? format,
    bool? includeMetricOverlays,
    bool? includeMilestoneMarkers,
    bool? includeAudio,
    String? musicTrack,
    Map<String, dynamic>? customSettings,
  }) {
    return VideoOptions(
      quality: quality ?? this.quality,
      frameRate: frameRate ?? this.frameRate,
      format: format ?? this.format,
      includeMetricOverlays: includeMetricOverlays ?? this.includeMetricOverlays,
      includeMilestoneMarkers: includeMilestoneMarkers ?? this.includeMilestoneMarkers,
      includeAudio: includeAudio ?? this.includeAudio,
      musicTrack: musicTrack ?? this.musicTrack,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Generated time-lapse video
class TimelapseVideo {
  final String videoId;
  final String sessionId;
  final String videoUrl;
  final String thumbnailUrl;
  final Duration duration;
  final VideoOptions options;
  final DateTime createdAt;
  final String status; // 'processing', 'completed', 'failed'
  final String? title;
  final String? description;

  const TimelapseVideo({
    required this.videoId,
    required this.sessionId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.options,
    required this.createdAt,
    required this.status,
    this.title,
    this.description,
  });

  factory TimelapseVideo.fromJson(Map<String, dynamic> json) {
    return TimelapseVideo(
      videoId: json['videoId'] as String,
      sessionId: json['sessionId'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      duration: Duration(microseconds: json['duration'] as int),
      options: VideoOptions.fromJson(json['options'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'sessionId': sessionId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.inMicroseconds,
      'options': options.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'title': title,
      'description': description,
    };
  }

  TimelapseVideo copyWith({
    String? videoId,
    String? sessionId,
    String? videoUrl,
    String? thumbnailUrl,
    Duration? duration,
    VideoOptions? options,
    DateTime? createdAt,
    String? status,
    String? title,
    String? description,
  }) {
    return TimelapseVideo(
      videoId: videoId ?? this.videoId,
      sessionId: sessionId ?? this.sessionId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

/// Date range for analytics
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Data point for trend analysis
class TrendDataPoint {
  final DateTime date;
  final double value;
  final String? annotation;

  const TrendDataPoint({
    required this.date,
    required this.value,
    this.annotation,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      annotation: json['annotation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'annotation': annotation,
    };
  }

  TrendDataPoint copyWith({
    DateTime? date,
    double? value,
    String? annotation,
  }) {
    return TrendDataPoint(
      date: date ?? this.date,
      value: value ?? this.value,
      annotation: annotation ?? this.annotation,
    );
  }
}

/// Growth trend analysis
class GrowthTrend {
  final String metric; // 'height', 'width', 'leaf_count'
  final List<TrendDataPoint> dataPoints;
  final double trendDirection; // -1 to 1
  final String trendDescription;

  const GrowthTrend({
    required this.metric,
    required this.dataPoints,
    required this.trendDirection,
    required this.trendDescription,
  });

  factory GrowthTrend.fromJson(Map<String, dynamic> json) {
    return GrowthTrend(
      metric: json['metric'] as String,
      dataPoints: (json['dataPoints'] as List)
          .map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendDirection: (json['trendDirection'] as num).toDouble(),
      trendDescription: json['trendDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'dataPoints': dataPoints.map((e) => e.toJson()).toList(),
      'trendDirection': trendDirection,
      'trendDescription': trendDescription,
    };
  }

  GrowthTrend copyWith({
    String? metric,
    List<TrendDataPoint>? dataPoints,
    double? trendDirection,
    String? trendDescription,
  }) {
    return GrowthTrend(
      metric: metric ?? this.metric,
      dataPoints: dataPoints ?? this.dataPoints,
      trendDirection: trendDirection ?? this.trendDirection,
      trendDescription: trendDescription ?? this.trendDescription,
    );
  }
}

/// Seasonal growth patterns
class SeasonalPattern {
  final String season;
  final double averageGrowthRate;
  final List<String> characteristics;
  final Map<String, double> seasonalMetrics;

  const SeasonalPattern({
    required this.season,
    required this.averageGrowthRate,
    required this.characteristics,
    required this.seasonalMetrics,
  });

  factory SeasonalPattern.fromJson(Map<String, dynamic> json) {
    return SeasonalPattern(
      season: json['season'] as String,
      averageGrowthRate: (json['averageGrowthRate'] as num).toDouble(),
      characteristics: List<String>.from(json['characteristics'] as List),
      seasonalMetrics: Map<String, double>.from(json['seasonalMetrics'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'averageGrowthRate': averageGrowthRate,
      'characteristics': characteristics,
      'seasonalMetrics': seasonalMetrics,
    };
  }

  SeasonalPattern copyWith({
    String? season,
    double? averageGrowthRate,
    List<String>? characteristics,
    Map<String, double>? seasonalMetrics,
  }) {
    return SeasonalPattern(
      season: season ?? this.season,
      averageGrowthRate: averageGrowthRate ?? this.averageGrowthRate,
      characteristics: characteristics ?? this.characteristics,
      seasonalMetrics: seasonalMetrics ?? this.seasonalMetrics,
    );
  }
}

/// Growth comparison with other plants
class GrowthComparison {
  final String comparisonType; // 'species', 'age', 'location'
  final String comparisonGroup;
  final double relativePerformance; // -1 to 1
  final String performanceDescription;
  final Map<String, double>? detailedComparison;

  const GrowthComparison({
    required this.comparisonType,
    required this.comparisonGroup,
    required this.relativePerformance,
    required this.performanceDescription,
    this.detailedComparison,
  });

  factory GrowthComparison.fromJson(Map<String, dynamic> json) {
    return GrowthComparison(
      comparisonType: json['comparisonType'] as String,
      comparisonGroup: json['comparisonGroup'] as String,
      relativePerformance: (json['relativePerformance'] as num).toDouble(),
      performanceDescription: json['performanceDescription'] as String,
      detailedComparison: json['detailedComparison'] != null
          ? Map<String, double>.from(json['detailedComparison'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparisonType': comparisonType,
      'comparisonGroup': comparisonGroup,
      'relativePerformance': relativePerformance,
      'performanceDescription': performanceDescription,
      'detailedComparison': detailedComparison,
    };
  }

  GrowthComparison copyWith({
    String? comparisonType,
    String? comparisonGroup,
    double? relativePerformance,
    String? performanceDescription,
    Map<String, double>? detailedComparison,
  }) {
    return GrowthComparison(
      comparisonType: comparisonType ?? this.comparisonType,
      comparisonGroup: comparisonGroup ?? this.comparisonGroup,
      relativePerformance: relativePerformance ?? this.relativePerformance,
      performanceDescription: performanceDescription ?? this.performanceDescription,
      detailedComparison: detailedComparison ?? this.detailedComparison,
    );
  }
}

/// Growth analytics for pattern analysis
class GrowthAnalytics {
  final String plantId;
  final DateRange analysisRange;
  final List<GrowthTrend> trends;
  final List<SeasonalPattern> seasonalPatterns;
  final List<GrowthComparison> comparisons;
  final Map<String, double> summaryMetrics;

  const GrowthAnalytics({
    required this.plantId,
    required this.analysisRange,
    required this.trends,
    required this.seasonalPatterns,
    required this.comparisons,
    required this.summaryMetrics,
  });

  factory GrowthAnalytics.fromJson(Map<String, dynamic> json) {
    return GrowthAnalytics(
      plantId: json['plantId'] as String,
      analysisRange: DateRange.fromJson(json['analysisRange'] as Map<String, dynamic>),
      trends: (json['trends'] as List)
          .map((e) => GrowthTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      seasonalPatterns: (json['seasonalPatterns'] as List)
          .map((e) => SeasonalPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      comparisons: (json['comparisons'] as List)
          .map((e) => GrowthComparison.fromJson(e as Map<String, dynamic>))
          .toList(),
      summaryMetrics: Map<String, double>.from(json['summaryMetrics'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantId': plantId,
      'analysisRange': analysisRange.toJson(),
      'trends': trends.map((e) => e.toJson()).toList(),
      'seasonalPatterns': seasonalPatterns.map((e) => e.toJson()).toList(),
      'comparisons': comparisons.map((e) => e.toJson()).toList(),
      'summaryMetrics': summaryMetrics,
    };
  }

  GrowthAnalytics copyWith({
    String? plantId,
    DateRange? analysisRange,
    List<GrowthTrend>? trends,
    List<SeasonalPattern>? seasonalPatterns,
    List<GrowthComparison>? comparisons,
    Map<String, double>? summaryMetrics,
  }) {
    return GrowthAnalytics(
      plantId: plantId ?? this.plantId,
      analysisRange: analysisRange ?? this.analysisRange,
      trends: trends ?? this.trends,
      seasonalPatterns: seasonalPatterns ?? this.seasonalPatterns,
      comparisons: comparisons ?? this.comparisons,
      summaryMetrics: summaryMetrics ?? this.summaryMetrics,
    );
  }
}