import 'dart:convert';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/models/virus.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/service/getAPI.dart';
import 'package:appbeebuzz/style.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';

class Showstatic extends StatefulWidget {
  const Showstatic(
      {super.key,
      required this.messages,
      required this.name,
      required this.info});

  final List<Messages> messages;
  final String name;
  final Messages info;

  @override
  State<Showstatic> createState() => _ShowstaticState();
}

class _ShowstaticState extends State<Showstatic> {
  // late var state = 2;
  late double real;
  late double realNew;

  late Color colorhandle;
  // bool link = false;

  String? type;
  late bool state;

  Body? res;

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    calculateState();
    linkstate();
    state = false;
  }

  calculateState() {
    if (widget.info.state == 0) {
      setState(() {
        real = widget.info.score * 3.34;
        realNew = widget.info.score * 0.83;
        colorhandle = greenState;
      });
    }
    if (widget.info.state == 1) {
      setState(() {
        real = (widget.info.score - 30) * 2.5;
        realNew = (widget.info.score + 10) * 0.83;
        colorhandle = yelloState;
      });
    }
    if (widget.info.state == 2) {
      setState(() {
        real = (widget.info.score - 70) * 3.34;
        realNew = (widget.info.score + 20) * 0.83;
        colorhandle = redState;
      });
    }
  }

  int? count;

  countDoc() async {
    var myRef = db.collection('sms');
    var snapshot = await myRef.count().get();
    setState(() {
      count = snapshot.count;
    });
    print('collection Sum ${snapshot.count}');
  }

  String? textstate;

  linkstate() {
    if (widget.info.state == 1) {
      textstate = "suspicious";
    }
    if (widget.info.state == 2) {
      textstate = "malicious";
    }
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowMsg(
                          messages: widget.messages, name: widget.name)));
            },
          )),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                    width: 240,
                    child: Stack(alignment: Alignment.topCenter, children: [
                      // ส่วนที่ 1
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: DashedCircularProgressBar.square(
                          dimensions: 226,
                          startAngle: 270,
                          sweepAngle: 42,
                          // corners: StrokeCap.butt,
                          circleCenterAlignment: Alignment.center,
                          foregroundColor: greenState,
                          backgroundColor: greenState,
                          foregroundStrokeWidth: 15,
                          backgroundStrokeWidth: 15,
                          animation: true,
                        ),
                      ),
                      // ส่วนที่ 2
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: DashedCircularProgressBar.square(
                          dimensions: 226,
                          startAngle: 332,
                          sweepAngle: 56,
                          // corners: StrokeCap.butt,
                          circleCenterAlignment: Alignment.center,
                          foregroundColor: yelloState,
                          backgroundColor: yelloState,
                          foregroundStrokeWidth: 15,
                          backgroundStrokeWidth: 15,
                          animation: true,
                        ),
                      ),
                      // ส่วนที่ 3
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: DashedCircularProgressBar.square(
                          dimensions: 226,
                          startAngle: 48,
                          sweepAngle: 42,
                          // corners: StrokeCap.butt,
                          circleCenterAlignment: Alignment.center,
                          foregroundColor: redState,
                          backgroundColor: redState,
                          foregroundStrokeWidth: 15,
                          backgroundStrokeWidth: 15,
                          animation: true,
                        ),
                      ),
                      Container(
                          // color: Colors.white.withOpacity(0.5),
                          // padding: const EdgeInsets.only(top: 20),
                          child: ArcProgressBar(
                              percentage: realNew,
                              arcThickness: 15,
                              strokeCap: StrokeCap.round,
                              innerPadding: 15,
                              handleSize: 30,
                              animationDuration: Duration.zero,
                              foregroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              // handleColor: Colorhandle,
                              handleWidget: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: colorhandle,
                                        width: 6,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100)))))),
                      Positioned(bottom: 80, child: circleState()),
                      Positioned(
                          bottom: 30,
                          child: Text('Risk level : ${widget.info.score}',
                              style: const TextStyle(
                                color: Color(0xFF83868E),
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                              )))
                    ])),
                Container(
                  width: 400,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(widget.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 10, left: 25, right: 25),
                        alignment: Alignment.center,
                        width: 300,
                        constraints: const BoxConstraints(minHeight: 60),
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 25,
                                offset: Offset(0, 5),
                                spreadRadius: 0,
                              )
                            ]),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              widget.info.body,
                              style: textmsg,
                              textAlign: TextAlign.center,
                            )),
                      ),
                      Visibility(
                          visible: widget.info.state != 0, child: _linkInfo()),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text("Do you think this message is fraud")),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                            color: const Color(0xFFECECEC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadows: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 1,
                                offset: Offset(0, 2),
                              )
                            ]),
                        child: TextButton(
                          onPressed: () async {
                            await countDoc();
                            db.collection("sms").doc("${count! + 1}").set({
                              "respone": "yes",
                              "all_score": widget.info.score,
                              "score link": widget.info.scorelink,
                              "score sms": widget.info.scoresms,
                              "sms": widget.info.body
                            });
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: Colors.white.withOpacity(0)),
                          child: const Text("Yes",
                              style: TextStyle(color: Color(0xFF7A7A7A))),
                        )),
                    Container(
                        alignment: Alignment.center,
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                            color: const Color(0xFFECECEC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadows: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 1,
                                offset: Offset(0, 2),
                              )
                            ]),
                        child: TextButton(
                          onPressed: () async {
                            await countDoc();
                            db.collection("sms").doc("${count! + 1}").set({
                              "respone": "no",
                              "all_score": widget.info.score,
                              "score link": widget.info.scorelink,
                              "score sms": widget.info.scoresms,
                              "sms": widget.info.body
                            });
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: Colors.white.withOpacity(0)),
                          child: const Text("No",
                              style: TextStyle(color: Color(0xFF7A7A7A))),
                        )),
                  ],
                )
              ],
            )));
  }

  Widget _linkInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: redState,
                  shape: BoxShape.circle,
                ),
                child: LayoutBuilder(builder: (context, constraint) {
                  return Icon(Icons.priority_high,
                      color: Colors.white, size: constraint.biggest.height);
                })),
            Text("Potentially $textstate link detected",
                style: const TextStyle(
                    fontFamily: "Inter",
                    fontSize: 13,
                    color: Color(0xFF7A7A7A)),
                textAlign: TextAlign.center)
          ],
        ),
        Text("Type : ${widget.info.linktype}",
            style: const TextStyle(
                fontFamily: "Inter", fontSize: 13, color: Color(0xFF7A7A7A)),
            textAlign: TextAlign.center)
      ],
    );
  }

  Widget circleState() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colorhandle,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.priority_high,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFECECEC),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(Icons.close, size: 20))),
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
                              onPressed: () async {})),
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
