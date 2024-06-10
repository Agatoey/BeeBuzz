import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/models/virus.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:page_transition/page_transition.dart';

class ShowstaticFromNoti extends StatefulWidget {
  const ShowstaticFromNoti(this.payload, {super.key});

  final String? payload;
  static const String routeName = '/Showstatic';

  @override
  State<ShowstaticFromNoti> createState() => _ShowstaticFromNotiState();
}

class _ShowstaticFromNotiState extends State<ShowstaticFromNoti> {
  late double real;
  late double realNew;

  late Color colorhandle;

  Body? res;

  FirebaseFirestore db = FirebaseFirestore.instance;

  String? textstate;
  int? count;

  @override
  void initState() {
    super.initState();
    splitPayload(widget.payload);
    calculateState();
    linkstate();
  }

  String name = '';
  String body = '';
  double score = 0;
  double linkscore = 0;
  double smsscore = 0;
  String type = '';
  String link = '';
  int state = 0;

  splitPayload(String? payload) {
    List<dynamic> parts = payload!.split('<text>');

    name = parts[0].substring(parts[0].indexOf(':') + 1);
    body = parts[1].substring(parts[1].indexOf(':') + 1);
    score = double.parse(parts[2].substring(parts[2].indexOf(':') + 1));
    linkscore = double.parse(parts[3].substring(parts[3].indexOf(':') + 1));
    smsscore = double.parse(parts[4].substring(parts[4].indexOf(':') + 1));
    type = parts[5].substring(parts[5].indexOf(':') + 1);
    link = parts[6].substring(parts[6].indexOf(':') + 1);
    state = int.parse(parts[7].substring(parts[7].indexOf(':') + 1));

    print('Name: $name');
    print('Body: $body');
    print('Score: $score');
    print('Link Score: $linkscore');
    print('SMS Score: $smsscore');
    print('Type: $type');
    print('Link: $link');
    print('State: $state');
  }

  void onPressback() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            child: Allsms(listMessage: const [],filterTexts: [],)));
  }

  calculateState() {
    if (state == 0) {
      setState(() {
        real = score * 3.34;
        realNew = score * 0.83;
        colorhandle = greenState;
      });
    }
    if (state == 1) {
      setState(() {
        real = (score - 30) * 2.5;
        realNew = (score + 10) * 0.83;
        colorhandle = yelloState;
      });
    }
    if (state == 2) {
      setState(() {
        real = (score - 70) * 3.34;
        realNew = (score + 20) * 0.83;
        colorhandle = redState;
      });
    }
  }

  countDoc() async {
    var myRef = db.collection('sms');
    var snapshot = await myRef.count().get();
    setState(() {
      count = snapshot.count;
    });
    print('collection Sum ${snapshot.count}');
  }

  linkstate() {
    if (state == 1) {
      textstate = "suspicious";
    }
    if (state == 2) {
      textstate = "malicious";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          onPressback();
        },
        child: PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: bgYellow,
              appBar: AppBar(
                  centerTitle: false,
                  title: Text(name, style: textHead),
                  backgroundColor: mainScreen,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      onPressback();
                    },
                  )),
              body: widgetbody(),
            )));
  }

  Widget widgetbody() {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(children: [
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
                        child: Text('Risk level : ${score.toStringAsFixed(2)}',
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
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(name,
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
                                  spreadRadius: 0)
                            ]),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              body,
                              style: textmsg,
                              textAlign: TextAlign.center,
                            ))),
                    Visibility(visible: link.isNotEmpty, child: _linkInfo()),
                  ])),
              Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: const Text("Do you think this message is fraud")),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                            color: const Color(0xFFECECEC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadows: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 1,
                                  offset: const Offset(0, 2))
                            ]),
                        child: TextButton(
                            onPressed: () async {
                              await countDoc();
                              await db
                                  .collection("sms")
                                  .doc("${count! + 1}")
                                  .set({
                                "respone": "yes",
                                "all_score": score,
                                "score link": linkscore,
                                "score sms": smsscore,
                                "sms": body
                              });
                              showToast('Thank for your respone.',
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  animation: StyledToastAnimation.fade,
                                  reverseAnimation: StyledToastAnimation.fade,
                                  curve: Curves.linear,
                                  reverseCurve: Curves.linear);
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                // foregroundColor: Colors.white.withOpacity(0),
                                fixedSize: const Size.fromWidth(120)),
                            child: const Text("Yes",
                                style: TextStyle(color: Color(0xFF7A7A7A))))),
                    Container(
                        alignment: Alignment.center,
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                            color: const Color(0xFFECECEC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadows: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 1,
                                  offset: const Offset(0, 2))
                            ]),
                        child: TextButton(
                          onPressed: () async {
                            await countDoc();
                            await db
                                .collection("sms")
                                .doc("${count! + 1}")
                                .set({
                              "respone": "no",
                              "all_score": score,
                              "score link": linkscore,
                              "score sms": smsscore,
                              "sms": body
                            });
                            showToast('Thank for your respone.',
                                // ignore: use_build_context_synchronously
                                context: context,
                                animation: StyledToastAnimation.fade,
                                reverseAnimation: StyledToastAnimation.fade,
                                curve: Curves.linear,
                                reverseCurve: Curves.linear);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              // foregroundColor: Colors.white.withOpacity(0),
                              fixedSize: const Size.fromWidth(120)),
                          child: const Text("No",
                              style: TextStyle(color: Color(0xFF7A7A7A))),
                        ))
                  ]),
              const Text(
                  "*By answering this, you agree to let the application to collect the response including the message to improve the application",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8B8989), fontSize: 12))
            ])));
  }

  Widget _linkInfo() {
    if (linkscore == 0) {
      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: const EdgeInsets.all(10),
              width: 20,
              height: 20,
              child: LayoutBuilder(builder: (context, constraint) {
                return Icon(Icons.priority_high,
                    color: const Color(0xFF8B8989),
                    size: constraint.biggest.height);
              })),
          const Text("Link detected.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Inter", fontSize: 13, color: Color(0xFF7A7A7A)))
        ]),
        Text("Type : ${type}",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: "Inter", fontSize: 13, color: Color(0xFF7A7A7A)))
      ]);
    }
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            margin: const EdgeInsets.all(10),
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: redState, shape: BoxShape.circle),
            child: LayoutBuilder(builder: (context, constraint) {
              return Icon(Icons.priority_high,
                  color: Colors.white, size: constraint.biggest.height);
            })),
        Text("Potentially $textstate link detected.",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: "Inter", fontSize: 13, color: Color(0xFF7A7A7A)))
      ]),
      Text("Type : ${type}",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: "Inter", fontSize: 13, color: Color(0xFF7A7A7A)))
    ]);
  }

  Widget circleState() {
    return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(color: colorhandle, shape: BoxShape.circle),
        child: const Icon(Icons.priority_high, color: Colors.white, size: 60));
  }
}
