import '../core/utils/date_time_utils.dart';

/// Represents a local/in-app notification for a customer.
class CustomerNotificationModel {
  const CustomerNotificationModel({
    required this.id,
    required this.customerId,
    required this.title,
    required this.message,
    this.serviceRequestId,
    this.ticketNumber,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final int customerId;
  final String title;
  final String message;
  final int? serviceRequestId;
  final String? ticketNumber;
  final DateTime createdAt;
  final bool isRead;

  CustomerNotificationModel copyWith({
    int? id,
    int? customerId,
    String? title,
    String? message,
    int? serviceRequestId,
    String? ticketNumber,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CustomerNotificationModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      message: message ?? this.message,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory CustomerNotificationModel.fromJson(Map<String, dynamic> json) {
    return CustomerNotificationModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      serviceRequestId: json['service_request_id'] as int?,
      ticketNumber: json['ticket_number'] as String?,
      createdAt: DateTimeUtils.parseIso(json['created_at'] as String),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'title': title,
        'message': message,
        if (serviceRequestId != null) 'service_request_id': serviceRequestId,
        if (ticketNumber != null) 'ticket_number': ticketNumber,
        'created_at': DateTimeUtils.toIso(createdAt),
        'is_read': isRead,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'customer_id': customerId,
        'title': title,
        'message': message,
        'service_request_id': serviceRequestId,
        'ticket_number': ticketNumber,
        'created_at': DateTimeUtils.toIso(createdAt),
        'is_read': isRead ? 1 : 0,
      };

  factory CustomerNotificationModel.fromMap(Map<String, dynamic> map) {
    return CustomerNotificationModel(
      id: map['id'] as int,
      customerId: map['customer_id'] as int,
      title: map['title'] as String,
      message: map['message'] as String,
      serviceRequestId: map['service_request_id'] as int?,
      ticketNumber: map['ticket_number'] as String?,
      createdAt: DateTimeUtils.parseIso(map['created_at'] as String),
      isRead: map['is_read'] == 1 || map['is_read'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerNotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomerNotificationModel(id: $id, title: $title, isRead: $isRead)';
}
