import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/static.dart';
import 'package:appbeebuzz/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ShowMsg extends StatefulWidget {
  const ShowMsg(
      {super.key, required this.messageModel, required this.listMessage, required this.filterTexts});

  final MessageModel messageModel;
  final List<MessageModel> listMessage;
  final List<dynamic>? filterTexts;

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

  void onPressback() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            child: Allsms(
              listMessage: widget.listMessage,
              filterTexts: widget.filterTexts,
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
        backgroundColor: bgYellow,
        appBar: AppBar(
          centerTitle: false,
          title: Text(widget.messageModel.name, style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                onPressback();
              }),
        ),
        body: Container(child: message(context)),
      ),
    );
  }

  Widget message(BuildContext context) {
    // if (state == true) {
    return Container(
        margin: const EdgeInsets.only(left: 30, top: 30),
        child: ListView.builder(
            // reverse: true,
            itemCount: widget.messageModel.messages.length,
            itemBuilder: (context, index) {
              final reversed = widget.messageModel.messages.reversed.toList();
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
                                // print("List: ${widget.listMessage.length}");
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => Showstatic(
                                              messages:
                                                  widget.messageModel.messages,
                                              info: item,
                                              messageModel: widget.messageModel,
                                              listMessage: widget.listMessage,
                                              filterTexts: widget.filterTexts,''
                                            )));
                              },
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 5, bottom: 10),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "${item.date.hour}:${item.date.minute}",
                                style: texterroEN,
                              ),
                            )
                          ],
                        ),
                        item.state != 0
                            ? Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(children: [
                                  item.state == 1
                                      ? const Icon(Icons.error,
                                          size: 17, color: Color(0xFFFCE205))
                                      : const Icon(Icons.error,
                                          size: 17, color: Color(0xFFFF2F00)),
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: item.state == 1
                                          ? Text('Risk level : Medium',
                                              style: texterroEN)
                                          : Text('Risk level : High',
                                              style: texterroEN))
                                ]))
                            : Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(children: [
                                  Icon(Icons.error,
                                          size: 17, color: greenState),
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('Risk level : Low',
                                              style: texterroEN))
                                ]))
                      ]));
            }));
  }
}
