import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/page/product_card.dart';
import 'product_detail_page.dart'; // Import the detail page

class ProductList extends StatefulWidget {
  final bool isAdmin;
  const ProductList({super.key, this.isAdmin = false});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final List<String> categoryFilters = [
    'All',
    'Shoes',
    'Clothes',
    'Bags',
    'Accessories'
  ];
  String selectedCategory = 'All';
  String searchQuery = '';

  void confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('products').doc(productId).delete();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Product deleted"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    int crossAxisCount = size.width < 600 ? 2 : (size.width < 1000 ? 4 : 6);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- SEARCH BAR ----------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // ---------------- CATEGORY FILTER ----------------
            Container(
              color: Colors.white,
              height: 50,
              child: ListView.builder(
                itemCount: categoryFilters.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final filter = categoryFilters[index];
                  final isSelected = selectedCategory == filter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = filter),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: isSelected ? Colors.red : Colors.transparent,
                              width: 2),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.red : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---------------- PRODUCT GRID ----------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final allProducts = snapshot.data!.docs;

                  // ---------------- FILTER PRODUCTS ----------------
                  final products = allProducts.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final category = (data['category']?.toString() ?? '').trim().toLowerCase();
                    final title = (data['title']?.toString().toLowerCase() ?? '').trim();

                    // Filter by search query
                    if (searchQuery.isNotEmpty && !title.contains(searchQuery)) return false;

                    // Filter by category
                    if (selectedCategory.toLowerCase() != 'all') {
                      if (category != selectedCategory.toLowerCase()) return false;
                    }

                    return true;
                  }).toList();

                  if (products.isEmpty) return const Center(child: Text('No products found'));

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.58),
                    itemBuilder: (context, index) {
                      final doc = products[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final productId = doc.id;

                      return ProductCard(
                        title: data['title'] ?? '',
                        price: (data['price'] as num?)?.toDouble() ?? 0,
                        oldPrice: (data['oldPrice'] as num?)?.toDouble() ?? 0,
                        image: data['imageUrl'] ?? '',
                        background: const Color(0xFFF7F7F7),
                        isAdmin: widget.isAdmin,
                        onDelete: () => confirmDelete(context, productId),
                        onTap: () {
                          // Navigate to ProductDetailPage with full data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(
                                product: {
                                  'id': productId,
                                  'title': data['title'],
                                  'price': data['price'],
                                  'oldPrice': data['oldPrice'],
                                  'imageUrl': data['imageUrl'],
                                  'description': data['description'] ?? '',
                                  'sizes': data['sizes'] ?? [38, 39, 40, 41, 42],
                                },
                              ),
                            ),
                          );
                        },
                        productId: productId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
