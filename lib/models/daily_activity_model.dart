import '../core/utils/date_time_utils.dart';

class DailyActivityModel {
  const DailyActivityModel({
    required this.id,
    required this.technicianId,
    required this.activityType,
    required this.method,
    required this.activityDate,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  static const List<String> activityTypes = [
    'Maintenance',
    'Repair',
    'Installation & Function Test',
    'Training',
    'Factory Visit',
    'To Do List',
  ];

  static const List<String> methods = [
    'Onsite',
    'Online',
  ];

  final int id;
  final int technicianId;
  final String activityType;
  final String method;
  final DateTime activityDate;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyActivityModel copyWith({
    int? id,
    int? technicianId,
    String? activityType,
    String? method,
    DateTime? activityDate,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyActivityModel(
      id: id ?? this.id,
      technicianId: technicianId ?? this.technicianId,
      activityType: activityType ?? this.activityType,
      method: method ?? this.method,
      activityDate: activityDate ?? this.activityDate,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DailyActivityModel.fromMap(Map<String, dynamic> map) {
    return DailyActivityModel(
      id: map['id'] as int? ?? 0,
      technicianId: map['technician_id'] as int? ?? 0,
      activityType: map['activity_type'] as String? ?? '',
      method: map['method'] as String? ?? '',
      activityDate: DateTimeUtils.tryParseIso(map['activity_date'] as String?) ?? DateTime.now(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTimeUtils.tryParseIso(map['created_at'] as String?) ?? DateTime.now(),
      updatedAt: DateTimeUtils.tryParseIso(map['updated_at'] as String?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'technician_id': technicianId,
      'activity_type': activityType,
      'method': method,
      'activity_date': DateTimeUtils.toIso(activityDate),
      'title': title,
      'description': description,
      'created_at': DateTimeUtils.toIso(createdAt),
      'updated_at': DateTimeUtils.toIso(updatedAt),
    };

    if (id > 0) {
      map['id'] = id;
    }

    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivityModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
