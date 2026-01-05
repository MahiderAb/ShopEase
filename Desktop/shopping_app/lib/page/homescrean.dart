import 'package:flutter/material.dart';
import 'package:shopping_app/page/cart_page.dart';
import 'package:shopping_app/page/order_page.dart';
import 'package:shopping_app/page/product_list.dart';
import 'package:shopping_app/page/favorites_page.dart';
import 'package:shopping_app/page/profile_page.dart';
import 'package:shopping_app/service/auth_service.dart';
import 'package:shopping_app/page/add_product_screen.dart';

class Homescrean extends StatefulWidget {
  const Homescrean({super.key});

  @override
  State<Homescrean> createState() => _HomescreanState();
}

class _HomescreanState extends State<Homescrean> {
  final AuthService _authService = AuthService();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isAdmin(), // Fetch admin status
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Still loading admin status
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = snapshot.data!;

        // Pages list, now safe to initialize
        final pages = [
          ProductList(isAdmin: isAdmin),
          const FavoritesPage(),
          const OrderPage(),
          const CartPage(),
          const ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(index: currentPage, children: pages),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  backgroundColor: const Color.fromRGBO(254, 206, 1, 1),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.black, size: 30),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentPage,
            onDestinationSelected: (index) =>
                setState(() => currentPage = index),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite_rounded, color: Colors.red),
                  label: 'Favorites'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_rounded),
                  label: 'Cart'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
