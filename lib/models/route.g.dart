// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      deliveries: (json['deliveries'] as List<dynamic>)
          .map((e) => Delivery.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startLat: (json['startLat'] as num?)?.toDouble(),
      startLng: (json['startLng'] as num?)?.toDouble(),
      endLat: (json['endLat'] as num?)?.toDouble(),
      endLng: (json['endLng'] as num?)?.toDouble(),
      totalDeliveries: (json['totalDeliveries'] as num).toInt(),
      completedDeliveries: (json['completedDeliveries'] as num).toInt(),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'name': instance.name,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'deliveries': instance.deliveries,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'startLat': instance.startLat,
      'startLng': instance.startLng,
      'endLat': instance.endLat,
      'endLng': instance.endLng,
      'totalDeliveries': instance.totalDeliveries,
      'completedDeliveries': instance.completedDeliveries,
    };
