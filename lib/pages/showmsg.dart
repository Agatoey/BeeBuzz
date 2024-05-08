import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/static.dart';
import 'package:appbeebuzz/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowMsg extends StatefulWidget {
  const ShowMsg({
    super.key,
    required this.messages,
    required this.name,
  });

  final List<Messages> messages;
  final String name;

  @override
  State<ShowMsg> createState() => _ShowMsgState();
}

class _ShowMsgState extends State<ShowMsg> {
  List<dynamic>? filterTexts;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool state = false;

  @override
  void initState() {
    super.initState();
    state = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgYellow,
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.name, style: textHead),
        backgroundColor: mainScreen,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Allsms()));
            }),
      ),
      body: Container(child: message(context)),
    );
  }

  Widget message(BuildContext context) {
    // if (state == true) {
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 30),
      child: ListView.builder(
          // reverse: true,
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            final reversed = widget.messages.reversed.toList();
            final item = reversed[index];
            return Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white.withOpacity(0),
                                padding: EdgeInsets.zero),
                            child: Container(
                                alignment: Alignment.topLeft,
                                width: 290,
                                constraints:
                                    const BoxConstraints(minHeight: 60),
                                decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(item.body.toString(),
                                        style: textmsg))),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Showstatic(
                                          messages: widget.messages,
                                          name: widget.name,
                                          info: item)));
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5, bottom: 10),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "${item.date.hour}:${item.date.minute}",
                              style: texterroEN,
                            ),
                          )
                        ],
                      ),
                      // Container(
                      //   padding: const EdgeInsets.only(top: 10),
                      //   child: Row(
                      //     children: [
                      //       const Icon(Icons.error,
                      //           size: 17, color: Color(0xFFFF2F00)),
                      //       Container(
                      //           padding: const EdgeInsets.only(left: 10),
                      //           child: Text('ระดับความเสี่ยง : สูง',
                      //               style: texterroTH))
                      //     ],
                      //   ),
                      // ),

                      item.state != 0
                          ? Container(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  item.state == 1
                                      ? const Icon(Icons.error,
                                          size: 17, color: Color(0xFFFCE205))
                                      : const Icon(Icons.error,
                                          size: 17, color: Color(0xFFFF2F00)),
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: item.state == 1
                                          ? Text('ระดับความเสี่ยง : ปานกลาง',
                                              style: texterroEN)
                                          : Text('ระดับความเสี่ยง : สูง',
                                              style: texterroEN))
                                ],
                              ),
                            )
                          : Container(height: 10)
                    ]));
          }),
    );
    // }
    // return Container(
    //     alignment: Alignment.center,
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const Text(
    //           "loading...",
    //           style: TextStyle(fontFamily: "Kanit", fontSize: 15),
    //         ),
    //         Container(
    //           padding: const EdgeInsets.all(10),
    //           child: CircularProgressIndicator(
    //             valueColor: AlwaysStoppedAnimation(mainScreen),
    //           ),
    //         ),
    //       ],
    //     ));
  }
}
