import 'package:json_annotation/json_annotation.dart';

part 'driver_stats.g.dart';

@JsonSerializable()
class DriverStats {
  @JsonKey(name: 'driver_id')
  final String driverId;
  @JsonKey(name: 'total_orders')
  final int totalOrders;
  @JsonKey(name: 'completed_orders')
  final int completedOrders;
  @JsonKey(name: 'total_distance')
  final double totalDistance;
  @JsonKey(name: 'total_earnings')
  final double totalEarnings;
  @JsonKey(name: 'current_orders')
  final int currentOrders;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const DriverStats({
    required this.driverId,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalDistance,
    required this.totalEarnings,
    required this.currentOrders,
    required this.updatedAt,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DriverStatsToJson(this);

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;
  double get averageEarningsPerOrder =>
      completedOrders > 0 ? totalEarnings / completedOrders : 0;
}


