import 'package:json_annotation/json_annotation.dart';
import 'delivery.dart';

part 'route.g.dart';

@JsonSerializable()
class Route {
  final String id;
  final String driverId;
  final String name;
  final String description;
  final DateTime date;
  final String status; // pending, in_progress, completed, cancelled
  final List<Delivery> deliveries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final int totalDeliveries;
  final int completedDeliveries;

  const Route({
    required this.id,
    required this.driverId,
    required this.name,
    required this.description,
    required this.date,
    required this.status,
    required this.deliveries,
    required this.createdAt,
    required this.updatedAt,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    required this.totalDeliveries,
    required this.completedDeliveries,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);

  Route copyWith({
    String? id,
    String? driverId,
    String? name,
    String? description,
    DateTime? date,
    String? status,
    List<Delivery>? deliveries,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    int? totalDeliveries,
    int? completedDeliveries,
  }) {
    return Route(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      deliveries: deliveries ?? this.deliveries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
    );
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  double get progressPercentage =>
      totalDeliveries > 0 ? (completedDeliveries / totalDeliveries) * 100 : 0;

  bool get isToday => DateTime.now().difference(date).inDays == 0;
}
