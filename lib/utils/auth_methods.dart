import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          'providers': user.providerData[0].providerId
        });
        print(
            "User signed in with UID: ${user.displayName!} && ${user.providerData}");
        res = true;
      }
    } catch (e) {
      print("Error during sign-in: $e"); // Log error message for debugging
      res = false;
    }
    return res;
  }

  Future<void> signOut(var providers) async {
    if (providers == 'google.com') {
      try {
        await googleSignIn.disconnect();
        _auth.signOut();
        print("ออกจากระบบสำเร็จ by google");
      } catch (e) {
        print("ออกจากระบบไม่สำเร็จ");
        print(e);
      }
    } else if (providers == 'password') {
      try {
        await _auth.signOut();
        print("ออกจากระบบสำเร็จ by password");
      } catch (e) {
        print("ออกจากระบบไม่สำเร็จ");
        print(e);
      }
    } else if (providers == 'phone'){
      await _auth.signOut();
    }
  }

}
