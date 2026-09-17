import '../core/utils/date_time_utils.dart';
import 'service_report_part_model.dart';

/// Represents a finalized service report filled out by a technician.
class ServiceReportModel {
  const ServiceReportModel({
    required this.id,
    required this.taskId,
    required this.technicianId,
    // Equipment
    required this.customerName,
    required this.customerAddress,
    required this.brand,
    required this.typeModel,
    required this.serialNumber,
    required this.location,
    required this.serviceType,
    // Service
    this.serviceBegin,
    this.serviceEnd,
    // Problem & Solution
    this.problem,
    this.solutions,
    this.remarks,
    this.workStatus,
    // Parts
    this.parts = const [],
    // Cost
    this.laborTimeHours,
    this.laborRate,
    this.travelTimeHours,
    this.travelRate,
    this.travelCost,
    this.othersCost,
    // Signatures (Base64 strings)
    this.technicianSignatureData,
    this.customerSignatureData,
  });

  final int id;
  final int taskId;
  final int technicianId;

  // ---------------------------------------------------------------------------
  // Equipment Info
  // ---------------------------------------------------------------------------
  final String customerName;
  final String customerAddress;
  final String brand;
  final String typeModel;
  final String serialNumber;
  final String location;
  final String serviceType; // Preventive, Corrective, Others

  // ---------------------------------------------------------------------------
  // Service times
  // ---------------------------------------------------------------------------
  final DateTime? serviceBegin;
  final DateTime? serviceEnd;

  // ---------------------------------------------------------------------------
  // Problem / Solution
  // ---------------------------------------------------------------------------
  final String? problem;
  final String? solutions;
  final String? remarks;
  final String? workStatus;

  // ---------------------------------------------------------------------------
  // Parts
  // ---------------------------------------------------------------------------
  final List<ServiceReportPartModel> parts;

  double get partsTotal {
    return parts.fold(0.0, (sum, part) => sum + part.total);
  }

  // ---------------------------------------------------------------------------
  // Cost
  // ---------------------------------------------------------------------------
  final double? laborTimeHours;
  final double? laborRate;
  
  double get laborSubtotal => (laborTimeHours ?? 0.0) * (laborRate ?? 0.0);

  final double? travelTimeHours;
  final double? travelRate;
  
  double get travelSubtotal => (travelTimeHours ?? 0.0) * (travelRate ?? 0.0);

  final double? travelCost;
  final double? othersCost;

  double get totalCost =>
      laborSubtotal +
      travelSubtotal +
      partsTotal +
      (travelCost ?? 0.0) +
      (othersCost ?? 0.0);

  // ---------------------------------------------------------------------------
  // Signatures
  // ---------------------------------------------------------------------------
  final String? technicianSignatureData;
  final String? customerSignatureData;

  ServiceReportModel copyWith({
    int? id,
    int? taskId,
    int? technicianId,
    String? customerName,
    String? customerAddress,
    String? brand,
    String? typeModel,
    String? serialNumber,
    String? location,
    String? serviceType,
    DateTime? serviceBegin,
    DateTime? serviceEnd,
    String? problem,
    String? solutions,
    String? remarks,
    String? workStatus,
    List<ServiceReportPartModel>? parts,
    double? laborTimeHours,
    double? laborRate,
    double? travelTimeHours,
    double? travelRate,
    double? travelCost,
    double? othersCost,
    String? technicianSignatureData,
    String? customerSignatureData,
  }) {
    return ServiceReportModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      technicianId: technicianId ?? this.technicianId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      brand: brand ?? this.brand,
      typeModel: typeModel ?? this.typeModel,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      serviceBegin: serviceBegin ?? this.serviceBegin,
      serviceEnd: serviceEnd ?? this.serviceEnd,
      problem: problem ?? this.problem,
      solutions: solutions ?? this.solutions,
      remarks: remarks ?? this.remarks,
      workStatus: workStatus ?? this.workStatus,
      parts: parts ?? this.parts,
      laborTimeHours: laborTimeHours ?? this.laborTimeHours,
      laborRate: laborRate ?? this.laborRate,
      travelTimeHours: travelTimeHours ?? this.travelTimeHours,
      travelRate: travelRate ?? this.travelRate,
      travelCost: travelCost ?? this.travelCost,
      othersCost: othersCost ?? this.othersCost,
      technicianSignatureData: technicianSignatureData ?? this.technicianSignatureData,
      customerSignatureData: customerSignatureData ?? this.customerSignatureData,
    );
  }

  factory ServiceReportModel.fromJson(Map<String, dynamic> json) {
    return ServiceReportModel(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      technicianId: json['technician_id'] as int,
      customerName: json['customer_name'] as String,
      customerAddress: json['customer_address'] as String,
      brand: json['brand'] as String,
      typeModel: json['type_model'] as String,
      serialNumber: json['serial_number'] as String,
      location: json['location'] as String,
      serviceType: json['service_type'] as String,
      serviceBegin: DateTimeUtils.tryParseIso(json['service_begin'] as String?),
      serviceEnd: DateTimeUtils.tryParseIso(json['service_end'] as String?),
      problem: json['problem'] as String?,
      solutions: json['solutions'] as String?,
      remarks: json['remarks'] as String?,
      workStatus: json['work_status'] as String?,
      parts: (json['parts'] as List<dynamic>?)
              ?.map((e) => ServiceReportPartModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      laborTimeHours: (json['labor_time_hours'] as num?)?.toDouble(),
      laborRate: (json['labor_rate'] as num?)?.toDouble(),
      travelTimeHours: (json['travel_time_hours'] as num?)?.toDouble(),
      travelRate: (json['travel_rate'] as num?)?.toDouble(),
      travelCost: (json['travel_cost'] as num?)?.toDouble(),
      othersCost: (json['others_cost'] as num?)?.toDouble(),
      technicianSignatureData: json['technician_signature'] as String?,
      customerSignatureData: json['customer_signature'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'technician_id': technicianId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'brand': brand,
        'type_model': typeModel,
        'serial_number': serialNumber,
        'location': location,
        'service_type': serviceType,
        if (serviceBegin != null) 'service_begin': DateTimeUtils.toIso(serviceBegin!),
        if (serviceEnd != null) 'service_end': DateTimeUtils.toIso(serviceEnd!),
        if (problem != null) 'problem': problem,
        if (solutions != null) 'solutions': solutions,
        if (remarks != null) 'remarks': remarks,
        if (workStatus != null) 'work_status': workStatus,
        'parts': parts.map((e) => e.toJson()).toList(),
        if (laborTimeHours != null) 'labor_time_hours': laborTimeHours,
        if (laborRate != null) 'labor_rate': laborRate,
        if (travelTimeHours != null) 'travel_time_hours': travelTimeHours,
        if (travelRate != null) 'travel_rate': travelRate,
        if (travelCost != null) 'travel_cost': travelCost,
        if (othersCost != null) 'others_cost': othersCost,
        if (technicianSignatureData != null) 'technician_signature': technicianSignatureData,
        if (customerSignatureData != null) 'customer_signature': customerSignatureData,
        'parts_total': partsTotal,
        'labor_subtotal': laborSubtotal,
        'travel_subtotal': travelSubtotal,
        'total_cost': totalCost,
      };
      
  Map<String, dynamic> toMap() => {
        if (id > 0) 'id': id,
        'task_id': taskId,
        'technician_id': technicianId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'brand': brand,
        'type_model': typeModel,
        'serial_number': serialNumber,
        'location': location,
        'service_type': serviceType,
        'service_begin': serviceBegin != null ? DateTimeUtils.toIso(serviceBegin!) : null,
        'service_end': serviceEnd != null ? DateTimeUtils.toIso(serviceEnd!) : null,
        'problem': problem,
        'solutions': solutions,
        'remarks': remarks,
        'work_status': workStatus,
        // Parts are handled via foreign keys in DB.
        'labor_time_hours': laborTimeHours,
        'labor_rate': laborRate,
        'travel_time_hours': travelTimeHours,
        'travel_rate': travelRate,
        'travel_cost': travelCost,
        'others_cost': othersCost,
        'technician_signature': technicianSignatureData,
        'customer_signature': customerSignatureData,
      };

  factory ServiceReportModel.fromMap(Map<String, dynamic> map, {List<ServiceReportPartModel> parts = const []}) {
    return ServiceReportModel(
      id: map['id'] as int,
      taskId: map['task_id'] as int,
      technicianId: map['technician_id'] as int,
      customerName: map['customer_name'] as String,
      customerAddress: map['customer_address'] as String,
      brand: map['brand'] as String,
      typeModel: map['type_model'] as String,
      serialNumber: map['serial_number'] as String,
      location: map['location'] as String,
      serviceType: map['service_type'] as String,
      serviceBegin: DateTimeUtils.tryParseIso(map['service_begin'] as String?),
      serviceEnd: DateTimeUtils.tryParseIso(map['service_end'] as String?),
      problem: map['problem'] as String?,
      solutions: map['solutions'] as String?,
      remarks: map['remarks'] as String?,
      workStatus: map['work_status'] as String?,
      parts: parts,
      laborTimeHours: (map['labor_time_hours'] as num?)?.toDouble(),
      laborRate: (map['labor_rate'] as num?)?.toDouble(),
      travelTimeHours: (map['travel_time_hours'] as num?)?.toDouble(),
      travelRate: (map['travel_rate'] as num?)?.toDouble(),
      travelCost: (map['travel_cost'] as num?)?.toDouble(),
      othersCost: (map['others_cost'] as num?)?.toDouble(),
      technicianSignatureData: map['technician_signature'] as String?,
      customerSignatureData: map['customer_signature'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceReportModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
