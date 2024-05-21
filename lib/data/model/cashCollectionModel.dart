import 'package:intl/intl.dart';

class CashCollectionModel {
  CashCollectionModel(
      {this.id, this.message, this.commissionAmount, this.status, this.date, this.orderID,});

  factory CashCollectionModel.fromJson(Map<String, dynamic> json) {
    return CashCollectionModel(
      id: json['id'],
      message: json['message'],
      commissionAmount: json['commison'],
      status: json['status'] == 'admin_cash_recevied' ? 'paid' : 'received',
      orderID: json['order_id'] ?? '',
      date: json['date'] != null
          ? json['date']
          : '',
    );
  }

  final String? id;
  final String? message;
  final String? commissionAmount;
  final String? status;
  final String? date;
  final String? orderID;
}
