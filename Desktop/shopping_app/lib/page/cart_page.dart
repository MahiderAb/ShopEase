import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/page/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCheckingOut = false;

  // ✅ CHECKOUT LOGIC: Save the whole cart to Firestore
  Future<void> _handleCheckout(CartProvider provider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (provider.cart.isEmpty) return;

    setState(() => _isCheckingOut = true);

    try {
      // 1. Prepare Order Data
      final orderData = {
        'buyerId': user.uid,
        'buyerEmail': user.email,
        'items': provider.cart, // Saves the list of all shoes
        'totalPrice': provider.totalPrice,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'isBulkOrder': true,
      };

      // 2. Save to Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // 3. Success! Clear local cart
      provider.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Checkout Successful! ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty 🛒"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Image.network(
                              item['imageUrl'],
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("${item['price']} ETB"),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => cartProvider.removeproduct(item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --- CHECKOUT SUMMARY BAR ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${cartProvider.totalPrice.toStringAsFixed(0)} ETB",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _isCheckingOut
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                            : ElevatedButton(
                              onPressed: () => _handleCheckout(cartProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  254,
                                  206,
                                  1,
                                  1,
                                ),
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "PROCEED TO CHECKOUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
