// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TimeSlotModel {
  final String time;
  final int isAvailable;
  TimeSlotModel({
    required this.time,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time,
      'is_available': isAvailable,
    };
  }

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) {
    return TimeSlotModel(
      time: map['time'] as String,
      isAvailable: map['is_available'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeSlotModel.fromJson(String source) =>
      TimeSlotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TimeSlotModel(time: $time, isAvailable: $isAvailable)';

  @override
  bool operator ==(covariant TimeSlotModel other) {
    if (identical(this, other)) return true;

    return other.time == time && other.isAvailable == isAvailable;
  }

  @override
  int get hashCode => time.hashCode ^ isAvailable.hashCode;
}
