import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/service/auth_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final admin = await _authService.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  // 🔴 ADMIN DELETE → REMOVE ORDER AND ALL MESSAGES
  Future<void> _deleteOrderAndMessages(String orderId) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);

    // 1️⃣ Delete all messages
    final messages = await orderRef.collection('messages').get();
    for (final msg in messages.docs) {
      await msg.reference.delete();
    }

    // 2️⃣ Delete the order itself
    await orderRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      appBar: AppBar(
        title: Text(_isAdmin ? "Admin: Orders" : "My Orders"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _isAdmin
            ? FirebaseFirestore.instance
                .collection('orders')
                .orderBy('orderDate', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('orders')
                .where('buyerId', isEqualTo: _currentUid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final order = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;

              // ✅ SAFE PRODUCT TITLE
              String productTitle;
              if (order['productTitle'] != null) {
                productTitle = order['productTitle'].toString();
              } else if (order['items'] is List &&
                  (order['items'] as List).isNotEmpty) {
                productTitle =
                    order['items'][0]['title']?.toString() ?? 'Order';
              } else {
                productTitle = 'Order';
              }

              final String imageUrl =
                  order['imageUrl']?.toString() ?? '';
              final String status =
                  order['status']?.toString() ?? 'pending';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: imageUrl.isEmpty
                          ? null
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(
                        productTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: _buildStatusChip(status),
                    ),

                    if (order['adminNote'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "🔔 ${order['adminNote']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text("Chat"),
                            onPressed: status == 'cancelled'
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          orderId: orderId,
                                          productTitle: productTitle,
                                          isAdmin: _isAdmin,
                                        ),
                                      ),
                                    );
                                  },
                          ),

                          if (_isAdmin)
                            TextButton.icon(
                              onPressed: () =>
                                  _deleteOrderAndMessages(orderId),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: const Text("Delete"),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color =
        status == 'cancelled' ? Colors.red : Colors.grey;

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}

// ---------------- CHAT SCREEN (UNCHANGED) ----------------

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String productTitle;
  final bool isAdmin;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.productTitle,
    required this.isAdmin,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  void _send() async {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();
    _msgController.clear();

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat: ${widget.productTitle}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(widget.orderId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final data =
                        msgs[index].data() as Map<String, dynamic>;
                    final isMe =
                        data['senderId'] == _uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color.fromRGBO(254, 206, 1, 1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(data['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Write your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
