import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Stream<User?> get authChange => _auth.authStateChanges();
  String? username;
  String? photoURL;
  String? email;
  String? phoneNumber;

  Future<bool> signInWithGoogle() async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuth =
          await googleSignInAccount?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuth?.accessToken,
        idToken: googleSignInAuth?.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName,
          'uid': user.uid,
          'profilePhoto': user.photoURL,
          'email': user.email,
          'providers': user.providerData[0].providerId,
          'filter': []
        });
        debugPrint(
            "User signed in with UID: ${user.displayName!} && ${user.providerData}");
        res = true;
      }
    } catch (e) {
      debugPrint("Error during sign-in: $e"); // Log error message for debugging
      res = false;
    }
    return res;
  }

  

  Future<void> signOut(var providers) async {
    if (providers == 'google.com') {
      try {
        await googleSignIn.disconnect();
        _auth.signOut();
        debugPrint("ออกจากระบบสำเร็จ by google");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      try {
        await _auth.signOut();
        debugPrint("ออกจากระบบสำเร็จ by password");
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}