import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';

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
                          messages: widget.messages,
                          name: widget.name,
                        )));
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              width: 315,
              height: 214,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
