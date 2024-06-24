import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class FogetPass extends StatefulWidget {
  const FogetPass({super.key});

  @override
  State<FogetPass> createState() => _FogetPassState();
}

class _FogetPassState extends State<FogetPass> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("Reset Password", style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ),
        body: Scaffold(backgroundColor: bgYellow, body: body()));
  }

  Widget body() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0)),
                hintText: "Email",
                filled: true,
                fillColor: const Color(0xFFF7F7F9),
                prefixIcon: const Icon(Icons.email, color: Colors.black45)),
            validator: (email) {
              email != null ? 'Enter email' : null;
              return null;
            },
          ),
          Container(
              margin: const EdgeInsets.only(top: 12),
              constraints: const BoxConstraints.expand(height: 50),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: mainScreen),
              child: TextButton(
                  onPressed: () async {
                    resetPassword();
                  },
                  child: const Center(
                      child: Text("Reset Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFF7F7F9),
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              height: 0.17))))),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: const Text(
              "Didn't receive any email?",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Text(
              "Click reset password again",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: mainScreen,
              ),
            ),
          )
        ]
      )
    );
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      errrorText("A password reset email has been sent. Please check your inbox.",
          Colors.green[100]);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message.toString());
      errrorText("Failed to send a password reset email.", Colors.red[100]);
    }
  }

  errrorText(String errortext, Color? color) {
    showToast(errortext,
        // ignore: use_build_context_synchronously
        context: context,
        textStyle: const TextStyle(color: Colors.black),
        backgroundColor: color,
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        curve: Curves.linear,
        reverseCurve: Curves.linear);
  }
}
