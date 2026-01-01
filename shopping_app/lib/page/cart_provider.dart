import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  void addproduct(Map<String, dynamic> product) {
    // Check if product already exists (optional logic, for now allow duplicates or just add)
    _cart.add(product);
    notifyListeners();
  }

  void removeProduct(Map<String, dynamic> product) {
    _cart.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _cart) {
      if (item['price'] != null) {
        total += (item['price'] as num).toDouble();
      }
    }
    return total;
  }
}
