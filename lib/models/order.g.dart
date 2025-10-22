// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      address: json['address'] as String,
      productName: json['product_name'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
      pinCode: json['pin_code'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      qrCode: json['qr_code'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'driver_id': instance.driverId,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'address': instance.address,
      'product_name': instance.productName,
      'product_price': instance.productPrice,
      'pin_code': instance.pinCode,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'qr_code': instance.qrCode,
    };
