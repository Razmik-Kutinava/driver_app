import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final String id;
  @JsonKey(name: 'driver_id')
  final String driverId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  final String address;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_price')
  final double productPrice;
  @JsonKey(name: 'pin_code')
  final String? pinCode;
  final String status; // 'pending', 'in_progress', 'completed', 'returned'
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'qr_code')
  final String? qrCode;

  const Order({
    required this.id,
    required this.driverId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.productName,
    required this.productPrice,
    this.pinCode,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.qrCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? id,
    String? driverId,
    String? customerName,
    String? customerPhone,
    String? address,
    String? productName,
    double? productPrice,
    String? pinCode,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? qrCode,
  }) {
    return Order(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      pinCode: pinCode ?? this.pinCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isReturned => status == 'returned';
}

