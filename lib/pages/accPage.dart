import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class AccPage extends StatefulWidget {
  const AccPage({super.key, required this.listMessage});
  final List<MessageModel> listMessage;

  @override
  State<AccPage> createState() => _AccPageState();
}

class _AccPageState extends State<AccPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final user = FirebaseAuth.instance.currentUser;
  AuthMethods userAuth = AuthMethods();
  String? username;
  String? photoURL;
  String? email;
  String? phoneNumber;
  String? userid;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    if (user != null) {
      username = user?.displayName;
      photoURL = user?.photoURL;
      email = user?.email;
      userid = user?.uid;
      phoneNumber = user?.phoneNumber;
      print("AccPage: $photoURL");
    }
  }

  void onPressback() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Allsms(
              listMessage: widget.listMessage,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onPressback();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("Account", style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              onPressback();
            },
          ),
        ),
        body: Scaffold(
            backgroundColor: bgYellow,
            body: Container(
                margin: const EdgeInsets.only(top: 120),
                alignment: Alignment.topCenter,
                child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        // width: 350,
                        height: 320,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFDF9ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 12,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 100),
                          height: 300,
                          width: 300,
                          child: Column(children: [
                            Text(
                              username!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF36383C),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                height: 0,
                              ),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                child: Text(
                                    phoneNumber == null
                                        ? ""
                                        : phoneNumber!.trim(),
                                    style: textAcc)),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(email == null ? "" : email!,
                                    style: textAcc)),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                    width: 150,
                                    height: 37,
                                    decoration: ShapeDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          mainScreen,
                                          const Color(0xFFFFA031)
                                        ],
                                      ),
                                      // color: const Color(0xFFFFA031),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                    child: TextButton(
                                        onPressed: _showAlertDialog,
                                        child: const Center(
                                            child: Text("Delete Account",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 0))))))
                          ])),
                      Positioned(
                          top: -90,
                          child: Container(
                            width: 180,
                            height: 180,
                            clipBehavior: Clip.antiAlias,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: Image.network(photoURL!, fit: BoxFit.cover),
                          ))
                    ]))),
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFECECEC),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //     padding: EdgeInsets.all(5),
                //     child: SizedBox(
                //         width: 20,
                //         height: 20,
                //         child: Icon(Icons.close, size: 20))),
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text('ยืนยันการลบบัญชีหรือไม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF7A7A7A),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0.11)),
                    )),
              ],
            ),
            content: SizedBox(
                height: 80,
                width: 250,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          width: 115,
                          height: 35,
                          decoration: ShapeDecoration(
                              color: const Color(0xFFBABABA),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: const Text('Yes',
                                  style: TextStyle(
                                      color: Color(0xFF7A7A7A),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0.12)),
                              onPressed: () async {
                                await FirebaseAuth.instance.currentUser!
                                    .delete();
                                await _firestore
                                    .collection('users')
                                    .doc(userid)
                                    .delete();
                                var provider;
                                _auth.signOut();
                                // AuthMethods().signOut(provider);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()));
                                showToast("Deleted.",
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    animation: StyledToastAnimation.fade,
                                    reverseAnimation: StyledToastAnimation.fade,
                                    curve: Curves.linear,
                                    reverseCurve: Curves.linear);
                              })),
                      Container(
                        width: 115,
                        height: 35,
                        decoration: ShapeDecoration(
                            color: const Color(0xFFBABABA),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: TextButton(
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text('No',
                                style: TextStyle(
                                  color: Color(0xFF7A7A7A),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0.12,
                                )),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      )
                    ])),
            actionsAlignment: MainAxisAlignment.center);
      },
    );
  }
}
