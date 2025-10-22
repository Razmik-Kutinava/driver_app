// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Delivery _$DeliveryFromJson(Map<String, dynamic> json) => Delivery(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      address: json['address'] as String,
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      failureReason: json['failureReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sequenceNumber: (json['sequenceNumber'] as num).toInt(),
    );

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
      'id': instance.id,
      'routeId': instance.routeId,
      'address': instance.address,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'notes': instance.notes,
      'status': instance.status,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lat': instance.lat,
      'lng': instance.lng,
      'photoUrl': instance.photoUrl,
      'signatureUrl': instance.signatureUrl,
      'failureReason': instance.failureReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sequenceNumber': instance.sequenceNumber,
    };
