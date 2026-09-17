import '../core/utils/date_time_utils.dart';

/// Represents a damage report / service request created by a customer.
class ServiceRequestModel {
  const ServiceRequestModel({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.equipmentId,
    required this.problemDescription,
    required this.status,
    required this.createdAt,
    this.customerName,
    this.equipmentBrand,
    this.equipmentModel,
    this.technicianId,
    this.technicianName,
  });

  final int id;
  final String ticketNumber;
  final int customerId;
  final int equipmentId;
  final String problemDescription;
  
  /// Status values: "Pending", "In Progress", "Completed", "Cancelled"
  final String status;
  final DateTime createdAt;

  // Denormalized fields for UI convenience
  final String? customerName;
  final String? equipmentBrand;
  final String? equipmentModel;
  final int? technicianId;
  final String? technicianName;

  ServiceRequestModel copyWith({
    int? id,
    String? ticketNumber,
    int? customerId,
    int? equipmentId,
    String? problemDescription,
    String? status,
    DateTime? createdAt,
    String? customerName,
    String? equipmentBrand,
    String? equipmentModel,
    int? technicianId,
    String? technicianName,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerId: customerId ?? this.customerId,
      equipmentId: equipmentId ?? this.equipmentId,
      problemDescription: problemDescription ?? this.problemDescription,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      equipmentBrand: equipmentBrand ?? this.equipmentBrand,
      equipmentModel: equipmentModel ?? this.equipmentModel,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
    );
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] as String,
      customerId: json['customer_id'] as int,
      equipmentId: json['equipment_id'] as int,
      problemDescription: json['problem_description'] as String,
      status: json['status'] as String,
      createdAt: DateTimeUtils.parseIso(json['created_at'] as String),
      customerName: json['customer_name'] as String?,
      equipmentBrand: json['equipment_brand'] as String?,
      equipmentModel: json['equipment_model'] as String?,
      technicianId: json['technician_id'] as int?,
      technicianName: json['technician_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_number': ticketNumber,
        'customer_id': customerId,
        'equipment_id': equipmentId,
        'problem_description': problemDescription,
        'status': status,
        'created_at': DateTimeUtils.toIso(createdAt),
        if (customerName != null) 'customer_name': customerName,
        if (equipmentBrand != null) 'equipment_brand': equipmentBrand,
        if (equipmentModel != null) 'equipment_model': equipmentModel,
        if (technicianId != null) 'technician_id': technicianId,
        if (technicianName != null) 'technician_name': technicianName,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'ticket_number': ticketNumber,
        'customer_id': customerId,
        'equipment_id': equipmentId,
        'problem_description': problemDescription,
        'status': status,
        'created_at': DateTimeUtils.toIso(createdAt),
        'customer_name': customerName,
        'equipment_brand': equipmentBrand,
        'equipment_model': equipmentModel,
        'technician_id': technicianId,
        'technician_name': technicianName,
      };

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: map['id'] as int,
      ticketNumber: map['ticket_number'] as String,
      customerId: map['customer_id'] as int,
      equipmentId: map['equipment_id'] as int,
      problemDescription: map['problem_description'] as String,
      status: map['status'] as String,
      createdAt: DateTimeUtils.parseIso(map['created_at'] as String),
      customerName: map['customer_name'] as String?,
      equipmentBrand: map['equipment_brand'] as String?,
      equipmentModel: map['equipment_model'] as String?,
      technicianId: map['technician_id'] as int?,
      technicianName: map['technician_name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
