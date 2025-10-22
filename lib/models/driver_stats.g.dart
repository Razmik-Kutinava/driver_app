// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverStats _$DriverStatsFromJson(Map<String, dynamic> json) => DriverStats(
      driverId: json['driver_id'] as String,
      totalOrders: (json['total_orders'] as num).toInt(),
      completedOrders: (json['completed_orders'] as num).toInt(),
      totalDistance: (json['total_distance'] as num).toDouble(),
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      currentOrders: (json['current_orders'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DriverStatsToJson(DriverStats instance) =>
    <String, dynamic>{
      'driver_id': instance.driverId,
      'total_orders': instance.totalOrders,
      'completed_orders': instance.completedOrders,
      'total_distance': instance.totalDistance,
      'total_earnings': instance.totalEarnings,
      'current_orders': instance.currentOrders,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
