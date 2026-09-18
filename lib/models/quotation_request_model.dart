import '../core/utils/date_time_utils.dart';

class QuotationRequestModel {
  const QuotationRequestModel({
    required this.id,
    required this.technicianId,
    required this.relatedTaskId,
    required this.title,
    required this.description,
    required this.estimatedCost,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int technicianId;
  final int relatedTaskId;
  final String title;
  final String description;
  final double estimatedCost;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuotationRequestModel copyWith({
    int? id,
    int? technicianId,
    int? relatedTaskId,
    String? title,
    String? description,
    double? estimatedCost,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuotationRequestModel(
      id: id ?? this.id,
      technicianId: technicianId ?? this.technicianId,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory QuotationRequestModel.fromMap(Map<String, dynamic> map) {
    return QuotationRequestModel(
      id: map['id'] as int? ?? 0,
      technicianId: map['technician_id'] as int? ?? 0,
      relatedTaskId: map['related_task_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      estimatedCost: (map['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Draft',
      createdAt: DateTimeUtils.tryParseIso(map['created_at'] as String?) ?? DateTime.now(),
      updatedAt: DateTimeUtils.tryParseIso(map['updated_at'] as String?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'technician_id': technicianId,
      'related_task_id': relatedTaskId,
      'title': title,
      'description': description,
      'estimated_cost': estimatedCost,
      'status': status,
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
      other is QuotationRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
