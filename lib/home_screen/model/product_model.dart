import 'package:flutter/material.dart';
class Product {
  String name;
  double price;
  int quantity;
  IconData? icon; // New field for product-specific icon

  Product({
    required this.name,
    required this.price,
    this.quantity = 0,
    this.icon,
  });
}