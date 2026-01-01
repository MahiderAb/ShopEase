import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:cloud_firestore/cloud_firestore.dart"; // ✅ ADDED
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initialize GoogleSignIn
  Future<void> googleSignInInitialize() async {
    await _googleSignIn.initialize(
      serverClientId:
          '728287730824-n7jikp3ae42vqmimiprfakfbvdohk2vp.apps.googleusercontent.com',
    );
  }

  /// Checks if the currently logged-in user has admin privileges.
  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['isAdmin'] ?? false;
    }
    return false;
  }

  /// ------------------- EMAIL / PASSWORD -------------------

  Future<String?> registerUser(String email, String password) async {
    try {
      // 1. Create user in Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isAdmin': false, // Default is false
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// ------------------- GOOGLE SIGN-IN -------------------

  Future<String?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
        if (googleUser == null) return "Sign in aborted";
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Create Firestore document for Google users if it doesn't exist
      final userDoc =
          await _db.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// ------------------- SIGN OUT -------------------

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  /// ------------------- HELPER -------------------

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is badly formatted.";
      case 'user-disabled':
        return "This user has been disabled.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "Email is already in use.";
      case 'weak-password':
        return "Password is too weak.";
      default:
        return e.message ?? "An undefined error occurred.";
    }
  }
}
