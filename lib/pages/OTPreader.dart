import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/pages/register.dart';
import 'package:appbeebuzz/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pinput/pinput.dart';

class OTPreader extends StatefulWidget {
  const OTPreader(
      {super.key, required this.verificationId, required this.phoneNumber});

  final String verificationId;
  final String phoneNumber;

  @override
  State<OTPreader> createState() => _OTPreaderState();
}

class _OTPreaderState extends State<OTPreader> {
  TextEditingController otpController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("Register", style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Register()));
            },
          ),
        ),
        body: Scaffold(backgroundColor: bgYellow, body: test()));
  }

  Widget test() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pinput(
          //   length: 6,
          //   showCursor: true,
          //   defaultPinTheme: PinTheme(
          //       constraints: BoxConstraints.expand(height: 60, width: 60),
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(10),
          //           color: Colors.white),
          //       textStyle:
          //           const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
          //   onSubmitted: (val) {
          //     setState(() {
          //       otpCode = val;
          //     });
          //   },
          // ),
          TextFormField(
              controller: otpController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0)),
                  hintText: "OTP Code",
                  filled: true,
                  fillColor: const Color(0xFFF7F7F9),
                  prefixIcon:
                      const Icon(Icons.phone_android, color: Colors.black45))),
          Container(
              margin: const EdgeInsets.only(top: 12),
              constraints: const BoxConstraints.expand(height: 50),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: mainScreen),
              child: TextButton(
                  onPressed: () async {
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: otpController.text);
                      _auth
                          .signInWithCredential(credential)
                          .then((value) async {
                        await firestore
                            .collection('users')
                            .doc(value.user?.uid)
                            .set({
                          'username': widget.phoneNumber,
                          'uid': value.user?.uid,
                          'profilePhoto':
                              "https://cdn-icons-png.freepik.com/512/4945/4945750.png",
                          'email': "-",
                          'providers': "phone",
                          'filter': []
                        });
                        value.user?.updateDisplayName(widget.phoneNumber);
                        value.user?.verifyBeforeUpdateEmail("-");
                        value.user!.updatePhotoURL(
                            'https://cdn-icons-png.freepik.com/512/4945/4945750.png');

                        errrorText(
                            "Registration complete.", Colors.green[100]!);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Allsms(listMessage: const [],filterTexts: const [],)));
                      }).catchError((error) {
                        if (error.message ==
                            "The verification code from SMS/TOTP is invalid. Please check and enter the correct verification code again.") {
                          errrorText(
                              "Please check and enter the correct verification code again",
                              Colors.red[100]!);
                        } else {
                          errrorText(error.message, Colors.red[100]!);
                        }

                        debugPrint(error.message.toString());
                      });
                    } catch (e) {
                      errrorText(e.toString(), Colors.red[100]!);
                    }
                  },
                  child: const Center(
                      child: Text("Verify Code",
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
              "Didn't receive any code?",
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
              "Resend New Code",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: mainScreen,
              ),
            ),
          )
        ],
      ),
    );
  }

  errrorText(String errortext, Color color) {
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
