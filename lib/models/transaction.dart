import 'package:flutter/foundation.dart';

class TransactionModel {
  final int id;
  final String title;
  final double price;
  final DateTime date;

  TransactionModel({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.date,
  });
}
