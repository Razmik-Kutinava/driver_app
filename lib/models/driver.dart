import 'package:json_annotation/json_annotation.dart';

part 'driver.g.dart';

@JsonSerializable()
class Driver {
  final String id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String phone;
  final String? email;
  final String? avatar;
  final String status; // active, inactive, busy
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'current_lat')
  final double? currentLat;
  @JsonKey(name: 'current_lng')
  final double? currentLng;
  @JsonKey(name: 'last_location_update')
  final DateTime? lastLocationUpdate;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  @JsonKey(name: 'hub_id')
  final String? hubId;
  final String? region;
  @JsonKey(name: 'district_id')
  final String? districtId;

  const Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.avatar,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.currentLat,
    this.currentLng,
    this.lastLocationUpdate,
    this.fcmToken,
    this.hubId,
    this.region,
    this.districtId,
  });

  String get name => '$firstName $lastName';

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  Driver copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatar,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    String? fcmToken,
    String? hubId,
    String? region,
    String? districtId,
  }) {
    return Driver(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      fcmToken: fcmToken ?? this.fcmToken,
      hubId: hubId ?? this.hubId,
      region: region ?? this.region,
      districtId: districtId ?? this.districtId,
    );
  }

  bool get isActive => status == 'active';
  bool get isBusy => status == 'busy';
  bool get isOnline =>
      lastLocationUpdate != null &&
      DateTime.now().difference(lastLocationUpdate!).inMinutes < 10;
}
