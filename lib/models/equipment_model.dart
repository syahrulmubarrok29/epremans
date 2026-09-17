/// Represents medical/clinical equipment.
///
/// When a technician scans the equipment QR/barcode, the matching
/// [EquipmentModel] is retrieved from the local repository and its fields
/// are auto-filled into the Service Report Equipment Information screen:
///   - [customerName]
///   - [customerAddress]
///   - [brand]
///   - [typeModel]
///   - [serialNumber]
///   - [location]
class EquipmentModel {
  const EquipmentModel({
    required this.id,
    required this.brand,
    required this.typeModel,
    required this.serialNumber,
    required this.location,
    required this.customerId,
    this.customerName,
    this.customerAddress,
    this.qrCode,
  });

  final int id;
  final String brand;

  /// Type / Model — as labelled on the official Polaris service report form.
  final String typeModel;

  final String serialNumber;

  /// Location of Equipment — Division / Room.
  final String location;

  final int customerId;

  /// Denormalised customer name for display without a JOIN.
  final String? customerName;

  /// Denormalised customer address for auto-fill in service reports.
  final String? customerAddress;

  /// QR code or barcode value used for equipment lookup via scanner.
  final String? qrCode;

  EquipmentModel copyWith({
    int? id,
    String? brand,
    String? typeModel,
    String? serialNumber,
    String? location,
    int? customerId,
    String? customerName,
    String? customerAddress,
    String? qrCode,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      typeModel: typeModel ?? this.typeModel,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as int,
      brand: json['brand'] as String,
      typeModel: json['type_model'] as String,
      serialNumber: json['serial_number'] as String,
      location: json['location'] as String,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String?,
      customerAddress: json['customer_address'] as String?,
      qrCode: json['qr_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'type_model': typeModel,
        'serial_number': serialNumber,
        'location': location,
        'customer_id': customerId,
        if (customerName != null) 'customer_name': customerName,
        if (customerAddress != null) 'customer_address': customerAddress,
        if (qrCode != null) 'qr_code': qrCode,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'brand': brand,
        'type_model': typeModel,
        'serial_number': serialNumber,
        'location': location,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'qr_code': qrCode,
      };

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      id: map['id'] as int,
      brand: map['brand'] as String,
      typeModel: map['type_model'] as String,
      serialNumber: map['serial_number'] as String,
      location: map['location'] as String,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String?,
      customerAddress: map['customer_address'] as String?,
      qrCode: map['qr_code'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EquipmentModel(id: $id, brand: $brand, sn: $serialNumber)';
}
