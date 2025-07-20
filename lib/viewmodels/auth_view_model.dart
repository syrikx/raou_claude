import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Temporarily disabled
// import 'package:cloud_firestore/cloud_firestore.dart'; // Temporarily disabled
import '../models/user.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  // Temporarily disabled Firebase dependencies
  // final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthViewModel() {
    // Temporarily disabled Firebase auth state checking
    // _checkAuthState();
  }

  // Temporarily disabled Firebase methods
  /*
  void _checkAuthState() {
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        _loadUserData(user);
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(firebase_auth.User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc.data()!, firebaseUser.uid);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to load user data: $e');
    }
  }
  */

  Future<bool> signInWithGoogle(BuildContext context) async {
    // Temporarily disabled - Firebase not available
    setError('Authentication features are temporarily disabled.');
    return false;
  }

  /*
  Future<void> _createOrUpdateUser(firebase_auth.User firebaseUser, bool isNewUser, BuildContext context) async {
    final userData = {
      'email': firebaseUser.email ?? '',
      'name': firebaseUser.displayName ?? '',
      'profileImageUrl': firebaseUser.photoURL,
      'joinedAt': isNewUser ? DateTime.now() : null,
    };

    if (isNewUser) {
      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome! Your account has been created.')),
        );
      }
    } else {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'email': userData['email'],
        'name': userData['name'],
        'profileImageUrl': userData['profileImageUrl'],
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome back!')),
        );
      }
    }

    await _loadUserData(firebaseUser);
  }
  */

  Future<void> signOut() async {
    await handleAsyncOperation(() async {
      // Temporarily disabled Firebase sign out
      // await _firebaseAuth.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    });
  }

  Future<void> deleteAccount() async {
    await handleAsyncOperation(() async {
      // Temporarily disabled Firebase account deletion
      /*
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
      */
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    });
  }
}