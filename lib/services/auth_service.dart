import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String name, 
    String role
  ) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user role locally
      await _saveUserRole(role);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      
      // First sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('User signed in. UID: ${userCredential.user?.uid}');

      // Get user role from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc['role'] ?? 'user'; // Default to 'user' if role is not set
        debugPrint('User role from Firestore: $role');
        await _saveUserRole(role);
      } else {
        debugPrint('User document does not exist in Firestore');
        // Create a default user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'user', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _saveUserRole('user');
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('Signing out user...');
      await _auth.signOut();
      await _clearUserRole();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      debugPrint('Checking if user is logged in...');
      final prefs = await SharedPreferences.getInstance();
      final hasRole = prefs.getString('userRole') != null;
      final isUserSignedIn = currentUser != null;
      
      debugPrint('User has role: $hasRole, User signed in: $isUserSignedIn');
      
      // Clear the role if the user is not signed in
      if (hasRole && !isUserSignedIn) {
        debugPrint('User has role but is not signed in. Clearing role...');
        await _clearUserRole();
        return false;
      }
      
      return hasRole && isUserSignedIn;
    } catch (e) {
      debugPrint('Error in isLoggedIn: $e');
      return false;
    }
  }

  // Get current user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    debugPrint('Retrieved user role: $role');
    return role;
  }

  // Save user role locally
  Future<void> _saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Saving user role: $role');
    await prefs.setString('userRole', role);
  }

  // Clear user role from local storage
  Future<void> _clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
  }

  // Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
