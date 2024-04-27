import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/static.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowMsg extends StatefulWidget {
  const ShowMsg({
    super.key,
    required this.messages,
    required this.name,
    // required this.state,
  });

  final List messages;
  final String name;
  // final List state;

  @override
  State<ShowMsg> createState() => _ShowMsgState();
}

class _ShowMsgState extends State<ShowMsg> {
  List<String> filterTexts = ["free", "click", "สวัสดี"];

  @override
  void initState() {
    super.initState();
    textFilter();
  }

  textFilter() {
    // debugPrint("Before Filter : ${widget.messages.length}");
    widget.messages.removeWhere((message) {
      for (var textFilter in filterTexts) {
        if (message.body.contains(textFilter)) {
          return true;
        }
      }
      return false;
    });
    // debugPrint("After Fillter : ${widget.messages.length}");
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
          },
        ),
      ),
      body: Container(
        child: message(context),
      ),
    );
  }

  Widget message(BuildContext context) {
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
                              constraints: const BoxConstraints(minHeight: 60),
                              decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
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
                                          msgbody: item.body.toString(),
                                        )));
                          },
                        ),
                        // Container(
                        //   alignment: Alignment.topLeft,
                        //   margin: const EdgeInsets.only(bottom: 10),
                        //   width: 290,
                        //   constraints: const BoxConstraints(minHeight: 60),
                        //   decoration: ShapeDecoration(
                        //       color: Colors.white.withOpacity(0.7),
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(5))),
                        //   child: TextButton(
                        //       style: TextButton.styleFrom(
                        //           padding: EdgeInsets.zero),
                        //       onPressed: () {},
                        //       child:
                        //           Text(item.body.toString(), style: textmsg)),
                        // ),
                        Container(
                          margin: const EdgeInsets.only(left: 5, bottom: 10),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "${item.date!.hour}:${item.date!.minute}",
                            style: texterroEN,
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.error,
                              size: 17, color: Color(0xFFFF2F00)),
                          Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('ระดับความเสี่ยง : สูง',
                                  style: texterroTH))
                        ],
                      ),
                    ),

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
                ));
          }),
    );
  }
}
