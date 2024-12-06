import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore

  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      // Create user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user was successfully created
      if (credential.user != null) {
        // Store the username and email in Firestore
        await _firestore.collection('users').doc(username).set({
          'username': username,
          'email': email,
          // Add any additional user-specific information you want to store
        });
      }

      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }
}
