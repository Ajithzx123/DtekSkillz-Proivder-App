// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationDataModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? typeId;
  final String image;
  final String orderId;
  final String isRead;
  final String dateSent;
  final String duration;

  NotificationDataModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.typeId,
    required this.image,
    required this.orderId,
    required this.isRead,
    required this.dateSent,
    required this.duration,
  });

  NotificationDataModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? typeId,
    String? image,
    String? orderId,
    String? isRead,
    String? dateSent,
    String? duration,
  }) {
    return NotificationDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      typeId: typeId ?? typeId,
      image: image ?? this.image,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      dateSent: dateSent ?? this.dateSent,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'type_id': typeId,
      'image': image,
      'order_id': orderId,
      'is_readed': isRead,
      'date_sent': dateSent,
      'duration': duration,
    };
  }

  factory NotificationDataModel.fromMap(Map<String, dynamic> map) {
    return NotificationDataModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      typeId: map['type_id'] as String,
      image: map['image'] as String,
      orderId: map['order_id'] as String,
      isRead: map['is_readed'] as String,
      dateSent: map['date_sent'] as String,
      duration: map['duration'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationDataModel.fromJson(String source) =>
      NotificationDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationDataModel(id: $id, title: $title, message: $message, type: $type, type_id: $typeId, image: $image, order_id: $orderId, is_readed: $isRead, date_sent: $dateSent, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationDataModel &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.typeId == typeId &&
        other.image == image &&
        other.orderId == orderId &&
        other.isRead == isRead &&
        other.dateSent == dateSent &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        message.hashCode ^
        type.hashCode ^
        typeId.hashCode ^
        image.hashCode ^
        orderId.hashCode ^
        isRead.hashCode ^
        dateSent.hashCode ^
        duration.hashCode;
  }
}
