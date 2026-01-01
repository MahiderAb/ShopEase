import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailPage({super.key, required this.orderData, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Handling nulls safely
    final String title = orderData['productTitle']?.toString() ?? 'No Title';
    final double price = (orderData['price'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = orderData['imageUrl']?.toString() ?? '';
    final String status = orderData['status']?.toString() ?? 'Pending';
    final Timestamp? orderDate = orderData['orderDate'] as Timestamp?;
    final String buyerEmail = orderData['buyerEmail']?.toString() ?? 'Unknown';

    final String formattedDate = orderDate != null
        ? DateFormat('MMMM dd, yyyy - hh:mm a').format(orderDate.toDate())
        : 'Unknown Date';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header with Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.blue.withOpacity(0.1),
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                   ),
                   const SizedBox(width: 15),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("Order #$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 5),
                         Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                       ],
                     ),
                   ),
                   _buildStatusChip(status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Item Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(height: 30),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                           ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image)))
                           : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text("$price ETB", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shipping Info (Placeholder logic for now as we don't store address yet)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Shipping Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(height: 30),
                  _buildInfoRow(Icons.person_outline, "Buyer", buyerEmail),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.local_shipping_outlined, "Method", "Standard Delivery"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase() == 'delivered') color = Colors.green;
    if (status.toLowerCase() == 'pending') color = Colors.orange;
    if (status.toLowerCase() == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
