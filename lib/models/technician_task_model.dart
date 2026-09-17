import '../core/utils/date_time_utils.dart';

/// Represents a task assigned to a technician.
class TechnicianTaskModel {
  const TechnicianTaskModel({
    required this.id,
    required this.serviceRequestId,
    required this.technicianId,
    required this.assignedAt,
    required this.status,
    this.completedAt,
    this.serviceReportId,
    this.customerName,
    this.customerAddress,
    this.equipmentBrand,
    this.equipmentModel,
    this.problemDescription,
  });

  final int id;
  final int serviceRequestId;
  final int technicianId;
  final DateTime assignedAt;
  
  /// Status values: "Assigned", "In Progress", "Completed", "Cancelled"
  final String status;
  
  final DateTime? completedAt;
  final int? serviceReportId;

  // Denormalized fields for Technician Dashboard/Task List
  final String? customerName;
  final String? customerAddress;
  final String? equipmentBrand;
  final String? equipmentModel;
  final String? problemDescription;

  TechnicianTaskModel copyWith({
    int? id,
    int? serviceRequestId,
    int? technicianId,
    DateTime? assignedAt,
    String? status,
    DateTime? completedAt,
    int? serviceReportId,
    String? customerName,
    String? customerAddress,
    String? equipmentBrand,
    String? equipmentModel,
    String? problemDescription,
  }) {
    return TechnicianTaskModel(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      technicianId: technicianId ?? this.technicianId,
      assignedAt: assignedAt ?? this.assignedAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      serviceReportId: serviceReportId ?? this.serviceReportId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      equipmentBrand: equipmentBrand ?? this.equipmentBrand,
      equipmentModel: equipmentModel ?? this.equipmentModel,
      problemDescription: problemDescription ?? this.problemDescription,
    );
  }

  factory TechnicianTaskModel.fromJson(Map<String, dynamic> json) {
    return TechnicianTaskModel(
      id: json['id'] as int,
      serviceRequestId: json['service_request_id'] as int,
      technicianId: json['technician_id'] as int,
      assignedAt: DateTimeUtils.parseIso(json['assigned_at'] as String),
      status: json['status'] as String,
      completedAt: DateTimeUtils.tryParseIso(json['completed_at'] as String?),
      serviceReportId: json['service_report_id'] as int?,
      customerName: json['customer_name'] as String?,
      customerAddress: json['customer_address'] as String?,
      equipmentBrand: json['equipment_brand'] as String?,
      equipmentModel: json['equipment_model'] as String?,
      problemDescription: json['problem_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_request_id': serviceRequestId,
        'technician_id': technicianId,
        'assigned_at': DateTimeUtils.toIso(assignedAt),
        'status': status,
        if (completedAt != null) 'completed_at': DateTimeUtils.toIso(completedAt!),
        if (serviceReportId != null) 'service_report_id': serviceReportId,
        if (customerName != null) 'customer_name': customerName,
        if (customerAddress != null) 'customer_address': customerAddress,
        if (equipmentBrand != null) 'equipment_brand': equipmentBrand,
        if (equipmentModel != null) 'equipment_model': equipmentModel,
        if (problemDescription != null) 'problem_description': problemDescription,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'service_request_id': serviceRequestId,
        'technician_id': technicianId,
        'assigned_at': DateTimeUtils.toIso(assignedAt),
        'status': status,
        'completed_at': completedAt != null ? DateTimeUtils.toIso(completedAt!) : null,
        'service_report_id': serviceReportId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'equipment_brand': equipmentBrand,
        'equipment_model': equipmentModel,
        'problem_description': problemDescription,
      };

  factory TechnicianTaskModel.fromMap(Map<String, dynamic> map) {
    return TechnicianTaskModel(
      id: map['id'] as int,
      serviceRequestId: map['service_request_id'] as int,
      technicianId: map['technician_id'] as int,
      assignedAt: DateTimeUtils.parseIso(map['assigned_at'] as String),
      status: map['status'] as String,
      completedAt: DateTimeUtils.tryParseIso(map['completed_at'] as String?),
      serviceReportId: map['service_report_id'] as int?,
      customerName: map['customer_name'] as String?,
      customerAddress: map['customer_address'] as String?,
      equipmentBrand: map['equipment_brand'] as String?,
      equipmentModel: map['equipment_model'] as String?,
      problemDescription: map['problem_description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechnicianTaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
