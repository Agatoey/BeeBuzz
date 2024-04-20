import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class ShowMsg extends StatefulWidget {
  const ShowMsg({
    super.key,
    required this.message,
    required this.name,
    // required this.state,
  });

  final List<SmsMessage> message;
  final String name;
  // final List state;

  @override
  State<ShowMsg> createState() => _ShowMsgState();
}

class _ShowMsgState extends State<ShowMsg> {
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
          },
        ),
      ),
      body: Container(
        child: message(context),
      ),
    );
  }

  Widget message(BuildContext context) {
    return ListView.builder(
        itemCount: widget.message.length,
        itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 30, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: 290,
                      constraints: const BoxConstraints(minHeight: 60),
                      decoration: ShapeDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(widget.message[index].body.toString(), style: textmsg),
                      )),
                  Container(
                    height: 10,
                  ),
                  Row(
                          children: [
                            const Icon(Icons.error,
                                    size: 17, color: Color(0xFFFF2F00)),
                            Container(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text('ระดับความเสี่ยง : สูง',
                                        style: texterro))
                          ],
                        )
                  // widget.state[index] != 0
                  //     ? Row(
                  //         children: [
                  //           widget.state[index] == 1
                  //               ? const Icon(Icons.error,
                  //                   size: 17, color: Color(0xFFFCE205))
                  //               : const Icon(Icons.error,
                  //                   size: 17, color: Color(0xFFFF2F00)),
                  //           Container(
                  //               padding: const EdgeInsets.only(left: 10),
                  //               child: widget.state[index] == 1
                  //                   ? Text('ระดับความเสี่ยง : ปานกลาง',
                  //                       style: texterro)
                  //                   : Text('ระดับความเสี่ยง : สูง',
                  //                       style: texterro))
                  //         ],
                  //       )
                      // : Container()
                ],
              ),
            ));
  }
}
