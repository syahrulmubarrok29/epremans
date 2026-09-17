/// Represents a customer hospital or clinic outlet.
class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.contactPerson,
  });

  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? contactPerson;

  CustomerModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? contactPerson,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      contactPerson: json['contact_person'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        if (phone != null) 'phone': phone,
        if (contactPerson != null) 'contact_person': contactPerson,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'contact_person': contactPerson,
      };

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String?,
      contactPerson: map['contact_person'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CustomerModel(id: $id, name: $name)';
}
