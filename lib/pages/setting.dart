import 'dart:io';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/models/messages.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:getwidget/getwidget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:appbeebuzz/main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage(this.payload, {super.key, required this.listMessage});

  static const String routeName = '/SettingPage';
  final String? payload;
  final List<MessageModel> listMessage;
  

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late bool permission;
  // _MainState enable = _MainState();

  @override
  void initState() {
    permission = true;
    checkPermission();
    super.initState();
  }

  void onPressback() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Allsms(listMessage: widget.listMessage,filterTexts: [],)));
  }

  Future<bool> checkPermission() async {
    permission = await Permission.notification.isGranted;
    if (permission) {
      print(permission);
      return true;
    }
    return false;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
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
            body: Scaffold(backgroundColor: bgYellow, 
            body: const Center(child: Text("Coming Soon"),),
            // body: body()
            )));
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text(
                  "Notification",
                  style: TextStyle(fontFamily: 'inter'),
                ),
                GFToggle(
                    value: permission,
                    type: GFToggleType.ios,
                    enabledThumbColor: Colors.white,
                    enabledTrackColor: mainScreen,
                    onChanged: (val) async {
                      if (val == false) {
                        await flutterLocalNotificationsPlugin.cancelAll();
                      } if (val == true){
                        _isAndroidPermissionGranted();
                      }
                    })
              ])
            ])));
  }
}