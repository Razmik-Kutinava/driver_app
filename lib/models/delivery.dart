import 'package:json_annotation/json_annotation.dart';

part 'delivery.g.dart';

@JsonSerializable()
class Delivery {
  final String id;
  final String routeId;
  final String address;
  final String? recipientName;
  final String? recipientPhone;
  final String? notes;
  final String status; // pending, in_progress, completed, failed
  final DateTime scheduledTime;
  final DateTime? completedAt;
  final double lat;
  final double lng;
  final String? photoUrl;
  final String? signatureUrl;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sequenceNumber;

  const Delivery({
    required this.id,
    required this.routeId,
    required this.address,
    this.recipientName,
    this.recipientPhone,
    this.notes,
    required this.status,
    required this.scheduledTime,
    this.completedAt,
    required this.lat,
    required this.lng,
    this.photoUrl,
    this.signatureUrl,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    required this.sequenceNumber,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryToJson(this);

  Delivery copyWith({
    String? id,
    String? routeId,
    String? address,
    String? recipientName,
    String? recipientPhone,
    String? notes,
    String? status,
    DateTime? scheduledTime,
    DateTime? completedAt,
    double? lat,
    double? lng,
    String? photoUrl,
    String? signatureUrl,
    String? failureReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sequenceNumber,
  }) {
    return Delivery(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      address: address ?? this.address,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedAt: completedAt ?? this.completedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoUrl: photoUrl ?? this.photoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  bool get isOverdue => DateTime.now().isAfter(scheduledTime) && !isCompleted;

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершено';
      case 'failed':
        return 'Не удалось';
      default:
        return 'Неизвестно';
    }
  }
}
