// Care Plan Status Enum
// This file contains the enum for care plan status used throughout the care plans feature


/// Represents the status of a care plan
enum CarePlanStatus {
  pending,
  acknowledged,
  active,
  completed,
  expired,
}

/// Extension to provide JSON serialization for CarePlanStatus
extension CarePlanStatusExtension on CarePlanStatus {
  String toJson() => name;
  
  static CarePlanStatus fromJson(String json) => 
      CarePlanStatus.values.firstWhere((e) => e.name == json);
}