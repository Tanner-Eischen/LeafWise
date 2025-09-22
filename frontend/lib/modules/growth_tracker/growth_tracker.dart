// Growth tracker module for tracking plant growth over time
// This module provides functionality to capture, analyze, and track plant growth

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'photo_capture.dart';
import 'metrics.dart';
import 'types.dart';

/// Class representing a growth record with photo and metrics
class GrowthRecord {
  final String id;
  final DateTime timestamp;
  final String photoPath;
  final String? notes;
  final GrowthMetrics? metrics;
  
  GrowthRecord({
    String? id,
    required this.timestamp,
    required this.photoPath,
    this.notes,
    this.metrics,
  }) : id = id ?? const Uuid().v4();
  
  /// Create a copy of this record with updated fields
  GrowthRecord copyWith({
    String? id,
    DateTime? timestamp,
    String? photoPath,
    String? notes,
    GrowthMetrics? metrics,
  }) {
    return GrowthRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      metrics: metrics ?? this.metrics,
    );
  }
}

/// Class for tracking plant growth over time
class GrowthTracker {
  static final GrowthTracker _instance = GrowthTracker._internal();
  
  /// Factory constructor to return the singleton instance
  factory GrowthTracker() {
    return _instance;
  }
  
  GrowthTracker._internal();
  
  final PhotoCapture _photoCapture = PhotoCapture();
  final MetricsAnalyzer _metricsAnalyzer = MetricsAnalyzer();
  
  /// Capture a new growth photo
  /// 
  /// [useCamera] Whether to use the camera or pick from gallery
  /// [notes] Optional notes about the growth record
  /// 
  /// Returns a GrowthRecord with the captured photo
  Future<GrowthRecord?> captureGrowthPhoto({
    required bool useCamera,
    String? notes,
  }) async {
    try {
      final photoPath = await _photoCapture.capturePhoto(useCamera: useCamera);
      
      if (photoPath == null) {
        return null; // User cancelled
      }
      
      final record = GrowthRecord(
        timestamp: DateTime.now(),
        photoPath: photoPath,
        notes: notes,
      );
      
      return record;
    } catch (e) {
      debugPrint('Error capturing growth photo: $e');
      rethrow;
    }
  }
  
  /// Analyze a growth record to extract metrics
  /// 
  /// [record] The growth record to analyze
  /// 
  /// Returns an updated growth record with metrics
  Future<GrowthRecord> analyzeGrowthRecord(GrowthRecord record) async {
    try {
      if (!File(record.photoPath).existsSync()) {
        throw Exception('Photo file not found: ${record.photoPath}');
      }
      
      final metrics = await _metricsAnalyzer.analyzePhoto(record.photoPath);
      
      return record.copyWith(metrics: metrics);
    } catch (e) {
      debugPrint('Error analyzing growth record: $e');
      rethrow;
    }
  }
  
  /// Compare two growth records to calculate growth rate
  /// 
  /// [oldRecord] The older growth record
  /// [newRecord] The newer growth record
  /// 
  /// Returns a map of growth rates for different metrics
  Map<String, double> compareGrowthRecords(
    GrowthRecord oldRecord,
    GrowthRecord newRecord,
  ) {
    if (oldRecord.metrics == null || newRecord.metrics == null) {
      throw Exception('Both records must have metrics for comparison');
    }
    
    final daysDifference = newRecord.timestamp.difference(oldRecord.timestamp).inDays;
    
    if (daysDifference <= 0) {
      throw Exception('New record must be more recent than old record');
    }
    
    final oldMetrics = oldRecord.metrics!;
    final newMetrics = newRecord.metrics!;
    
    final heightGrowth = ((newMetrics.height ?? 0) - (oldMetrics.height ?? 0)) / daysDifference;
    final widthGrowth = ((newMetrics.width ?? 0) - (oldMetrics.width ?? 0)) / daysDifference;
    final leafCountGrowth = ((newMetrics.leafCount ?? 0) - (oldMetrics.leafCount ?? 0)) / daysDifference;
    
    return {
      'height': heightGrowth, // cm per day
      'width': widthGrowth, // cm per day
      'leafCount': leafCountGrowth, // leaves per day
    };
  }
  
  /// Get growth stage based on metrics and plant type
  /// 
  /// [metrics] The growth metrics
  /// [plantType] The type of plant
  /// 
  /// Returns the estimated growth stage
  String getGrowthStage(GrowthMetrics metrics, String plantType) {
    // This is a simplified implementation
    // In a real app, this would use a database of plant growth patterns
    
    // Default stages for generic plants
    if ((metrics.height ?? 0) < 5) {
      return 'Seedling';
    } else if ((metrics.height ?? 0) < 15) {
      return 'Juvenile';
    } else if ((metrics.height ?? 0) < 30) {
      return 'Mature';
    } else {
      return 'Fully Grown';
    }
  }
  
  /// Dispose resources used by the growth tracker
  Future<void> dispose() async {
    await _photoCapture.dispose();
  }
}