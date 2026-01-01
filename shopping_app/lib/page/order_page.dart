import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/page/notifications_page.dart';
import 'package:shopping_app/service/auth_service.dart';
import 'package:shopping_app/page/order_detail_page.dart'; // Import detail page

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    bool adminStatus = await _authService.isAdmin();
    if (mounted) setState(() => _isAdmin = adminStatus);
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'adminNote': 'Your order is now $newStatus',
    });
  }

  Future<void> _deleteOrder(String orderId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      appBar: AppBar(
        title: Text(_isAdmin ? "Admin: Manage Orders" : "My Orders"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _isAdmin
            ? FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots()
            : FirebaseFirestore.instance.collection('orders').where('buyerId', isEqualTo: _currentUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var orders = snapshot.data!.docs;

          if (_isAdmin && _searchQuery.isNotEmpty) {
            orders = orders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final email = (data['buyerEmail'] ?? '').toString().toLowerCase();
              return email.contains(_searchQuery);
            }).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final order = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;

              final String imageUrl = order['imageUrl']?.toString() ?? '';
              final String productTitle = order['productTitle']?.toString() ?? '';
              final String status = order['status']?.toString() ?? 'pending';
              final String lastSenderId = order['lastMessageSenderId']?.toString() ?? '';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      leading: isMobile || imageUrl.isEmpty
                          ? null
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (order['hasUnreadMessage'] == true && lastSenderId != _currentUid)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                      title: Text(productTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: _buildStatusChip(status),
                      onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (_) => OrderDetailPage(orderData: order, orderId: orderId),
                           ),
                         );
                      },
                    ),
                    if (order['adminNote'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "🔔 ${order['adminNote']}",
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
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
    Color color = status == 'pending'
        ? Colors.grey
        : (status == 'delivered' ? Colors.green : Colors.red);

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
    );
  }
}

// ---------------- CHAT SCREEN ----------------

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

    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'lastMessage': text,
      'lastMessageSenderId': _uid,
      'hasUnreadMessage': true,
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
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final data = msgs[index].data() as Map<String, dynamic>;
                    final senderId = data['senderId']?.toString() ?? '';
                    bool isMe = senderId == _uid;

                    String senderLabel = isMe ? "You" : (widget.isAdmin ? "Buyer" : "Admin");

                    return Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(senderLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color.fromRGBO(254, 206, 1, 1) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(data['text']?.toString() ?? ''),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
