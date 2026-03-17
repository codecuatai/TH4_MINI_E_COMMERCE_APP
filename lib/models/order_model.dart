import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final List<dynamic> items;
  final String address;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final double totalPrice;

  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.totalPrice,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      items: json['items'] ?? [],
      address: json['address'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
      'totalPrice': totalPrice,
    };
  }
}
