/// Represents a part used during a service report.
class ServiceReportPartModel {
  const ServiceReportPartModel({
    required this.id,
    required this.serviceReportId,
    required this.partNumber,
    required this.partDescription,
    required this.quantity,
    required this.unitPrice,
  });

  final int id;
  final int serviceReportId;
  final String partNumber;
  final String partDescription;
  final int quantity;
  final double unitPrice;

  /// Derived field: Qty × Unit Price
  double get total => quantity * unitPrice;

  ServiceReportPartModel copyWith({
    int? id,
    int? serviceReportId,
    String? partNumber,
    String? partDescription,
    int? quantity,
    double? unitPrice,
  }) {
    return ServiceReportPartModel(
      id: id ?? this.id,
      serviceReportId: serviceReportId ?? this.serviceReportId,
      partNumber: partNumber ?? this.partNumber,
      partDescription: partDescription ?? this.partDescription,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  factory ServiceReportPartModel.fromJson(Map<String, dynamic> json) {
    return ServiceReportPartModel(
      id: json['id'] as int,
      serviceReportId: json['service_report_id'] as int,
      partNumber: json['part_number'] as String,
      partDescription: json['part_description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_report_id': serviceReportId,
        'part_number': partNumber,
        'part_description': partDescription,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
      };

  Map<String, dynamic> toMap() => {
        if (id > 0) 'id': id,
        'service_report_id': serviceReportId,
        'part_number': partNumber,
        'part_description': partDescription,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  factory ServiceReportPartModel.fromMap(Map<String, dynamic> map) {
    return ServiceReportPartModel(
      id: map['id'] as int,
      serviceReportId: map['service_report_id'] as int,
      partNumber: map['part_number'] as String,
      partDescription: map['part_description'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceReportPartModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
