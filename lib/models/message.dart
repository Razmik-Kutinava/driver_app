import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String senderId;
  final String? receiverId; // null для сообщений всем водителям
  final String content;
  final String type; // text, image, location, system
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? senderName;
  final String? senderAvatar;

  const Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.type,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.senderName,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? type,
    String? attachmentUrl,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderName,
    String? senderAvatar,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isLocation => type == 'location';
  bool get isSystem => type == 'system';
  bool get isBroadcast => receiverId == null;

  bool get isFromAdmin => senderId == 'admin' || senderId == 'dispatcher';

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'Только что';
    }
  }
}
