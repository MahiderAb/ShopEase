import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  /// Loads the user's favorite items from Firestore.
  /// Returns early if no user is logged in.
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .get();

      _favorites = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  /// Toggles the favorite status of a product.
  /// If already favorited, removes it; otherwise, adds it.
  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String productId = product['title'].toString();
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    final bool alreadyExists = isFavorite(
      product['title'],
    ); // ✅ Use the new method

    try {
      if (alreadyExists) {
        _favorites.removeWhere((item) => item['title'] == product['title']);
        notifyListeners();
        await docRef.delete();
      } else {
        _favorites.add(product);
        notifyListeners();
        await docRef.set(product);
      }
    } catch (e) {
      await loadFavorites();
      debugPrint("Error toggling favorite: $e");
    }
  }

  /// Checks if a product is in the user's favorites list.
  bool isFavorite(String title) {
    return _favorites.any((item) => item['title'] == title);
  }
}
