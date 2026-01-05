import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/service/auth_service.dart';
import 'package:shopping_app/page/login_screen.dart';
import 'package:intl/intl.dart'; // Add this to pubspec.yaml for date formatting

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService _authService = AuthService();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 249, 1),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Error loading profile"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          bool isAdmin = userData['isAdmin'] ?? false;
          Timestamp? createdAt = userData['createdAt'] as Timestamp?;
          String joinedDate =
              createdAt != null
                  ? DateFormat('MMMM yyyy').format(createdAt.toDate())
                  : "Recently";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromRGBO(254, 206, 1, 1),
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 15),
                Text(
                  userData['email'] ?? "User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isAdmin
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? "ADMIN ACCOUNT" : "STUDENT ACCOUNT",
                    style: TextStyle(
                      color: isAdmin ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Info Section
                _buildProfileItem(
                  Icons.email_outlined,
                  "Email",
                  userData['email'],
                ),
                _buildProfileItem(
                  Icons.calendar_month_outlined,
                  "Joined",
                  joinedDate,
                ),
                _buildProfileItem(
                  Icons.verified_user_outlined,
                  "Status",
                  "Verified Student",
                ),

                const SizedBox(height: 40),

                // Logout Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _authService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
