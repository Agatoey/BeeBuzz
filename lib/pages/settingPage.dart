import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:page_transition/page_transition.dart';

class SettingPage extends StatefulWidget {
  const SettingPage(
    this.payload, {
    super.key, required this.listMessage
  });

  static const String routeName = '/SettingPage';
  final String? payload;
  final List<MessageModel> listMessage;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  String? _payload;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
    print("Payload : $_payload");
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
            title: Text('Setting', style: textHead),
            backgroundColor: mainScreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                onPressback();
              },
            )),
        body: Scaffold(
          backgroundColor: bgYellow,
          body: body(),
        ),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
        child: Container(
      alignment: Alignment.center,
      width: 450,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // shadows: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 1,
        //     offset: Offset(0, 2),
        //   )
        // ]
      ),
      child: Column(
        children: [
          Text('payload ${_payload ?? ''}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notofication",
                style: TextStyle(fontFamily: 'inter'),
              ),
              GFToggle(
                type: GFToggleType.ios,
                enabledThumbColor: Colors.white,
                enabledTrackColor: mainScreen,
                onChanged: (val) {
                  if(val == false){
                    
                  }
                },
                value: true,
              )
            ],
          ),
        ],
      ),
    ));
  }
}
