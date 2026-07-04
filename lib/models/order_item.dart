import 'package:flutter/material.dart';

/// طلب شراء ضمن قائمة "طلباتي" الخاصة بالمشتري.
class OrderItem {
  final String id;
  final String name;
  final String status;
  final String price;
  final Color statusColor;

  const OrderItem({
    required this.id,
    required this.name,
    required this.status,
    required this.price,
    required this.statusColor,
  });
}
