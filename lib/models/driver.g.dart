// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLng: (json['current_lng'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] == null
          ? null
          : DateTime.parse(json['last_location_update'] as String),
      fcmToken: json['fcm_token'] as String?,
      hubId: json['hub_id'] as String?,
      region: json['region'] as String?,
      districtId: json['district_id'] as String?,
    );

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'email': instance.email,
      'avatar': instance.avatar,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'current_lat': instance.currentLat,
      'current_lng': instance.currentLng,
      'last_location_update': instance.lastLocationUpdate?.toIso8601String(),
      'fcm_token': instance.fcmToken,
      'hub_id': instance.hubId,
      'region': instance.region,
      'district_id': instance.districtId,
    };
