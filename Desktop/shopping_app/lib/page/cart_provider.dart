import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> cart = [];

  void addproduct(Map<String, dynamic> product) {
    cart.add(product);
    notifyListeners();
  }

  void removeproduct(Map<String, dynamic> product) {
    cart.remove(product);
    notifyListeners();
  }

  // ✅ Add this to clear cart after checkout
  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ✅ Helper to get total price
  double get totalPrice {
    double total = 0.0;
    for (var item in cart) {
      total += (item['price'] as num).toDouble();
    }
    return total;
  }
}
