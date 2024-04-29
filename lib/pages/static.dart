import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/style.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/widgets.dart';

class Showstatic extends StatefulWidget {
  const Showstatic({
    super.key,
    required this.messages,
    required this.name,
    required this.msgbody,
  });

  final List messages;
  final String name;
  final String msgbody;

  @override
  State<Showstatic> createState() => _ShowstaticState();
}

class _ShowstaticState extends State<Showstatic> {
  late var state = 2;

  late double scoreY;
  late double real;
  late double score = 80;

  late double scoreX;
  late double realNew;
  late double scoreNew = 80;

  late Color Colorhandle;
  bool link = false;

  @override
  void initState() {
    super.initState();
    calculateState();
    calculateStateNew();
    link = true;
  }

  calculateState() {
    if (state == 0) {
      score = score;
      scoreX = score * 3.34;
      setState(() {
        real = scoreX;
      });
    }
    if (state == 1) {
      score = score - 30;
      scoreX = score * 2.5;
      setState(() {
        real = scoreX;
      });
    }

    if (state == 2) {
      score = score - 70;
      scoreX = score * 3.34;
      setState(() {
        real = scoreX;
      });
    }
  }

  calculateStateNew() {
    if (state == 0) {
      scoreY = scoreNew * 0.83;
      setState(() {
        realNew = scoreY;
        Colorhandle = greenState;
      });
      print(realNew);
    }
    if (state == 1) {
      scoreY = (scoreNew + 10) * 0.83;
      setState(() {
        realNew = scoreY;
        Colorhandle = yelloState;
      });
      print(realNew);
    }

    if (state == 2) {
      scoreY = (scoreNew + 20) * 0.83;
      setState(() {
        realNew = scoreY;
        Colorhandle = redState;
      });
      print(realNew);
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
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                        width: 230,
                        decoration: ShapeDecoration(
                            // color: Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21))),
                        child: Stack(alignment: Alignment.topCenter, children: [
                          // ส่วนที่ 1
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            child: DashedCircularProgressBar.square(
                              // progress: real,
                              dimensions: 220,
                              startAngle: 270,
                              sweepAngle: 42,
                              // corners: StrokeCap.butt,
                              circleCenterAlignment: Alignment.center,
                              foregroundColor: greenState,
                              backgroundColor: greenState,
                              foregroundStrokeWidth: 15,
                              backgroundStrokeWidth: 15,
                              // seekColor:
                              //     state == 0 ? greenState : Colors.transparent,
                              // seekSize: 30,
                              animation: true,
                            ),
                          ),
                          // ส่วนที่ 2
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            child: DashedCircularProgressBar.square(
                              // progress: real,
                              dimensions: 220,
                              startAngle: 332,
                              sweepAngle: 56,
                              // corners: StrokeCap.butt,
                              circleCenterAlignment: Alignment.center,
                              foregroundColor: yelloState,
                              backgroundColor: yelloState,
                              foregroundStrokeWidth: 15,
                              backgroundStrokeWidth: 15,
                              // seekColor:
                              //     state == 1 ? yelloState : Colors.transparent,
                              // seekSize: 30,
                              animation: true,
                            ),
                          ),
                          // ส่วนที่ 3
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            child: DashedCircularProgressBar.square(
                              // progress: real,
                              dimensions: 220,
                              startAngle: 48,
                              sweepAngle: 42,
                              // corners: StrokeCap.butt,
                              circleCenterAlignment: Alignment.center,
                              foregroundColor: redState,
                              backgroundColor: redState,
                              foregroundStrokeWidth: 15,
                              backgroundStrokeWidth: 15,
                              // seekColor:
                              //     state == 2 ? redState : Colors.transparent,
                              // seekSize: 30,
                              animation: true,
                            ),
                          ),
                          Positioned(bottom: 80, child: circleState()),
                          ArcProgressBar(
                            percentage: realNew,
                            arcThickness: 15,
                            strokeCap: StrokeCap.round,
                            innerPadding: 11,
                            handleSize: 30,
                            animationDuration: Duration.zero,
                            foregroundColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            handleWidget: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colorhandle,
                                      width: 6,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0)))),
                          ),
                          Positioned(
                            bottom: 30,
                            child: Text(
                              'ระดับความเสี่ยง : $scoreNew',
                              style: const TextStyle(
                                color: Color(0xFF83868E),
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
                            margin: const EdgeInsets.symmetric(horizontal: 25),
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
                                  widget.msgbody,
                                  style: textmsg,
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Visibility(visible: link == true, child: _linkInfo()),
                        ],
                      ),
                    )
                  ],
                ))));
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
            const Text("ตรวจพบลิ้งค์ที่ไม่ปลอดภัย",
                style: TextStyle(
                    fontFamily: "Saraban",
                    fontSize: 13,
                    color: Color(0xFF7A7A7A)),
                textAlign: TextAlign.center)
          ],
        ),
        Text("ประเภทลิ้ง : $scoreNew",
            style: const TextStyle(
                fontFamily: "Saraban", fontSize: 13, color: Color(0xFF7A7A7A)),
            textAlign: TextAlign.center)
      ],
    );
  }

  Widget circleState() {
    if (state == 0) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: greenState, shape: BoxShape.circle),
        child: const Icon(
          Icons.priority_high,
          color: Colors.white,
          size: 50,
        ),
      );
    }
    if (state == 1) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: yelloState,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high,
          color: Colors.white,
          size: 50,
        ),
      );
    }
    if (state == 2) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: redState,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high,
          color: Colors.white,
          size: 50,
        ),
      );
    }
    return Container();
  }
}
