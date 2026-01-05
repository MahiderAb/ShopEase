import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/page/chat_screen.dart';

class NotificationsPage extends StatelessWidget {
  final bool isAdmin;
  final String currentUid;

  const NotificationsPage({
    super.key,
    required this.isAdmin,
    required this.currentUid,
  });

  /// ✅ SAFELY get product title (single OR bulk order)
  String _getProductTitle(Map<String, dynamic> data) {
    if (data['productTitle'] != null) {
      return data['productTitle'].toString();
    }

    if (data['items'] is List && data['items'].isNotEmpty) {
      return data['items'][0]['title']?.toString() ?? 'Order';
    }

    return 'Order';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: isAdmin
            ? FirebaseFirestore.instance
                .collection('orders')
                .where('hasUnreadMessage', isEqualTo: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('orders')
                .where('buyerId', isEqualTo: currentUid)
                .where('hasUnreadMessage', isEqualTo: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❗ Filter out notifications triggered by own messages
          final unreadOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['lastMessageSenderId'] != currentUid;
          }).toList();

          if (unreadOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No new messages",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: unreadOrders.length,
            itemBuilder: (context, index) {
              final doc = unreadOrders[index];
              final data = doc.data() as Map<String, dynamic>;

              final productTitle = _getProductTitle(data);
              final lastMessage =
                  data['lastMessage']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Color.fromRGBO(254, 206, 1, 1),
                    child: Icon(Icons.mail_outline, color: Colors.black),
                  ),
                  title: Text(
                    productTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New message: $lastMessage",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isAdmin && data['buyerEmail'] != null)
                        Text(
                          "From: ${data['buyerEmail']}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () async {
                    // 1️⃣ Mark as read
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(doc.id)
                        .update({'hasUnreadMessage': false});

                    if (!context.mounted) return;

                    // 2️⃣ Open chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          orderId: doc.id,
                          productTitle: productTitle,
                          isAdmin: isAdmin,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
