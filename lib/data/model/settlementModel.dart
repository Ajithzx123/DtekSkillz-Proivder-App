import 'package:intl/intl.dart';

class SettlementModel {
  SettlementModel({
    this.id,
    this.providerId,
    this.message,
    this.date,
    this.amount,
    this.status,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) => SettlementModel(
        id: json['id'],
        providerId: json['provider_id'],
        message: json['message'],
        date: json['date'] != null
            ? json['date']
            : '',
        amount: json['amount'],
        status: json['status'],
      );

  final String? id;
  final String? providerId;
  final String? message;
  final String? date;
  final String? amount;
  final String? status;
}
