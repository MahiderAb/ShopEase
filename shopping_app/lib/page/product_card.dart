import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import 'cart_provider.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final double price;
  final double oldPrice;
  final String image;
  final Color background;
  final VoidCallback? onTap;
  final String? productId; // Needed for favorites and delete
  final bool isAdmin;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.background,
    this.onTap,
    this.productId,
    required this.isAdmin,
    this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isOrdering = false;

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Adds the current product to the shopping cart.
  Future<void> _addToCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (widget.productId == null) return;

    cartProvider.addproduct({
      'title': widget.title,
      'price': widget.price,
      'imageUrl': widget.image,
      'productId': widget.productId,
    });

    _showMsg('Added to cart!', Colors.blueGrey);
  }

  /// Handles the "Buy Now" action for immediate purchase.
  Future<void> _placeOrder(BuildContext context) async {
    // Your existing buy now logic
    _showMsg('Order placed!', Colors.green);
  }

  /// Builds the product image widget, supporting both base64 and network URLs.
  Widget _buildProductImage(String imageStr) {
    if (imageStr.isEmpty) return const Icon(Icons.image_not_supported, color: Colors.grey);
    if (imageStr.startsWith('data:image')) {
      try {
        final base64String = imageStr.split(',').last.trim();
        return Image.memory(base64Decode(base64String), fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image, color: Colors.grey);
      }
    }
    return Image.network(
      imageStr,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    double safeOldPrice = widget.oldPrice > widget.price ? widget.oldPrice : widget.price;
    int discountPercent = 0;
    if (safeOldPrice > widget.price && safeOldPrice > 0) {
      discountPercent = (((safeOldPrice - widget.price) / safeOldPrice) * 100).round();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: Container(
                        color: const Color(0xFFF7F7F7),
                        child: Hero(
                          tag: widget.image.isEmpty ? widget.title : widget.image,
                          child: _buildProductImage(widget.image),
                        ),
                      ),
                    ),
                    if (discountPercent > 10)
                      Positioned(
                        top: 5,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Choice",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                // DETAILS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Color(0xFFFF9500), size: 10),
                          Text(" 4.8", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${widget.price.toStringAsFixed(0)} ETB", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red)),
                      if (discountPercent > 0)
                        Row(
                          children: [
                            Text(safeOldPrice.toStringAsFixed(0), style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 4),
                            Text("-$discountPercent%", style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // ACTIONS: Add to Cart + Buy Now
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _addToCart,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _isOrdering
                                ? const Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
                                : SizedBox(
                                    height: 28,
                                    child: ElevatedButton(
                                      onPressed: () => _placeOrder(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        elevation: 0,
                                      ),
                                      child: const Text("Buy Now", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ADMIN DELETE BUTTON
          if (widget.isAdmin && widget.onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.delete, size: 20, color: Colors.white),
                ),
              ),
            ),
          // FAVORITE BUTTON
          Positioned(
            top: 6,
            left: 6,
            child: Consumer<FavoritesProvider>(
              builder: (context, favProvider, _) {
                final isFav = favProvider.isFavorite(widget.title);
                return GestureDetector(
                  onTap: () => favProvider.toggleFavorite({
                    'title': widget.title,
                    'price': widget.price,
                    'imageUrl': widget.image,
                  }),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
