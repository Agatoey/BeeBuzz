import 'dart:typed_data';

import 'package:appbeebuzz/pages/SMS_messages.dart';
import 'package:appbeebuzz/pages/accPage.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/pages/filterPage.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/pages/testContact1.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicons/unicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';

class Allsms extends StatefulWidget {
  const Allsms({super.key});

  @override
  State<Allsms> createState() => _AllsmsState();
}

class _AllsmsState extends State<Allsms> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey();
  List<Map> staticData = MyData.data;
  late String signoutWith;

  final SmsQuery _query = SmsQuery();

  Map<String, List> messagesBySender = {};
  List<SmsMessage> _messages = [];
  bool _permissionDenied = false;

  List filterText = ["free", "click"];

  bool isPress1 = true;
  final _selectedSegment = ValueNotifier('all');

  @override
  void initState() {
    isPress1 = true;
    roadSMSTest();
    super.initState();
  }

  Future roadSMSTest() async {
    messagesBySender = {};
    _messages = [];
    var permission = await Permission.sms.request();
    if (!permission.isGranted) {
      setState(() => _permissionDenied = true);
    } else {
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox,
          // SmsQueryKind.sent,
        ],
      );
      setState(() {
        _messages = messages;
      });

      for (var message in _messages) {
        if (!messagesBySender.containsKey(message.sender)) {
          messagesBySender[message.sender.toString()] = [];
        }
        messagesBySender[message.sender]?.add(message);
        // print("${message.date!.hour}:${message.date!.minute}");
      }
      await Permission.contacts.request();
      // messagesBySender.forEach((key, value) {
      //   print(key.toString());
      // });
    }
  }

  Future<String?> getContactName(String phoneNumber) async {
    final contacts = await ContactsService.getContactsForPhone(phoneNumber);
    if (contacts.isNotEmpty) {
      return contacts.first.displayName;
    }
    return null;
  }

  Future<Uint8List?> getContactPhoto(String phoneNumber) async {
    final contacts = await ContactsService.getContactsForPhone(phoneNumber);
    if (contacts.isNotEmpty) {
      return contacts.first.avatar;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: mainScreen,
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.density_medium /*Icons.dehaze*/,
                  color: Colors.white),
              onPressed: () {
                if (_scaffoldkey.currentState?.isDrawerOpen == false) {
                  _scaffoldkey.currentState?.openDrawer();
                } else {
                  _scaffoldkey.currentState?.openEndDrawer();
                }
              }),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            )
          ]),
      body: Scaffold(
          backgroundColor: bgYellow,
          key: _scaffoldkey,
          drawer: navBar(),
          body: SingleChildScrollView(
              child: RefreshIndicator(
            onRefresh: roadSMSTest,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints.expand(height: 50),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFF7F7F9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: AdvancedSegment(
                      controller: _selectedSegment,
                      segments: const {
                        'all': 'All SMS',
                        'fraud': 'Fraud SMS',
                      },
                      backgroundColor: const Color(0xFFF7F7F9),
                      activeStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                      inactiveStyle: const TextStyle(color: Color(0xFFB2B7BE)),
                      sliderColor: Colors.white,
                    ),
                  ),
                  Container(
                    height: 600,
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    decoration: ShapeDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21))),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _selectedSegment,
                      builder: (_, key, __) {
                        switch (key) {
                          case 'all':
                            return messagesListView(_messages);
                          case 'fraud':
                            return fraudSMS(context);
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ))),
    );
  }

  Widget messagesListView(List<SmsMessage> messages) {
    if (_messages.isEmpty) {
      return Scaffold(
          backgroundColor: bgYellow,
          body: const Center(child: CircularProgressIndicator()));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messagesBySender.length,
      itemBuilder: (context, index) {
        String sender = messagesBySender.keys.toList()[index];
        List? messages = messagesBySender[sender];
        SmsMessage message = messages![0];
        return ListTile(
          // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
          title:
              // Text(sender,
              //     style: const TextStyle(
              //         fontWeight: FontWeight.bold, fontFamily: "Kanit")),
              FutureBuilder<String?>(
            future: getContactName(sender),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!,
                    style: const TextStyle(fontWeight: FontWeight.bold));
              }
              return Text(sender,
                  style: const TextStyle(fontWeight: FontWeight.bold));
            },
          ),
          subtitle: Text('${message.body}',
              style: const TextStyle(fontFamily: "Kanit"),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1),
          leading: Stack(children: [
            Container(
                height: 50,
                width: 50,
                decoration: ShapeDecoration(
                    color: const Color(0xFFCB9696),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                child: FutureBuilder<Uint8List?>(
                  future: getContactPhoto(sender),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List?> snapshot) {
                    final Uint8List? imageData = snapshot.data;
                    if (snapshot.hasData && imageData!.isNotEmpty) {
                      return CircleAvatar(
                        backgroundImage: MemoryImage(imageData),
                      );
                    }
                    return Image.asset(
                      "assets/images/profile.png",
                      fit: BoxFit.fitWidth,
                    );
                  },
                )),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    width: 20,
                    height: 20,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFFF2F00),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100))),
                    child: const Center(
                        child: Icon(
                            color: Colors.white,
                            Icons.priority_high,
                            size: 18))))
          ]),
          onTap: () {
            print(messages);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ShowMsg(
                          messages: messages,
                          name: sender,
                          // state: data['state'],
                          // time: data['time'],
                        )));
          },
        );
      },
    );
  }

  Widget allSMS(BuildContext context) {
    List<Map> staticData = MyData.data;
    return ListView.builder(
        itemBuilder: (builder, index) {
          Map data = staticData[index];
          return ListTile(
              onTap: () {
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ShowMsg(
                //               message: data['message'],
                //               phoneNumber: data['phone'],
                //               name: data['name'],
                //               state: data['state'],
                //               // time: data['time'],
                //             )));
              },
              title: Text("${data['name']}", overflow: TextOverflow.ellipsis),
              subtitle: Text("${data['message'][0]}",
                  overflow: TextOverflow.ellipsis),
              leading: Stack(children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                      color: const Color(0xFFCB9696),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                  child: Image.asset(
                    data['image'],
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: data['state'][0] == 0
                        ? Container()
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                                color: data['state'][0] == 1
                                    ? const Color(0xFFFCE205)
                                    : const Color(0xFFFF2F00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100))),
                            child: const Center(
                                child: Icon(
                                    color: Colors.white,
                                    Icons.priority_high,
                                    size: 18))))
              ]));
        },
        itemCount: staticData.length);
  }

  Widget fraudSMS(BuildContext context) {
    List<Map> staticData = MyData.data;
    return ListView.builder(
      itemBuilder: (builder, index) {
        Map data = staticData[index];
        if (data['state'][0] != 0) {
          return ListTile(
            onTap: () {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ShowMsg(
              //               message: data['message'],
              //               phoneNumber: data['phone'],
              //               name: data['name'],
              //               state: data['state'],
              //               // time: data['time'],
              //             )));
            },
            title: Text("${data['name']}"),
            subtitle:
                Text("${data['message'][0]}", overflow: TextOverflow.ellipsis),
            leading: Stack(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                      color: const Color(0xFFCB9696),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                  child: Image.asset(data['image'], fit: BoxFit.fitWidth),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: ShapeDecoration(
                          color: data['state'][0] == 1
                              ? const Color(0xFFFCE205)
                              : const Color(0xFFFF2F00),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100))),
                      child: const Center(
                          child: Icon(
                              color: Colors.white,
                              Icons.priority_high,
                              size: 18)),
                    ))
              ],
            ),
          );
        } else {
          return Container();
        }
      },
      itemCount: staticData.length,
    );
  }

  Widget navBar() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Main',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'Inter')),
          ),
          ListTile(
              leading:
                  FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
              title: Text('Message', style: textBar),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Allsms()));
              }),
          // ListTile(
          //     leading:
          //         FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
          //     title: Text('Test Message', style: textBar),
          //     onTap: () {
          //       Navigator.pushReplacement(
          //           context, MaterialPageRoute(builder: (context) => MyApp()));
          //     }),
          ListTile(
              leading:
                  FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
              title: Text('Contacts', style: textBar),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContactsExample()));
              }),
          ListTile(
            leading: FaIcon(UniconsLine.user, size: 20, color: grayBar),
            title: Text('Account', style: textBar),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AccPage()));
            },
          ),
          ListTile(
              leading: FaIcon(UniconsLine.filter, size: 20, color: grayBar),
              title: Text('Messages Filter', style: textBar),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterPage()));
              }),
          Container(height: 2, color: const Color(0xFFCFCFCF)),
          const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                      fontSize: 14,
                      fontFamily: 'Inter'))),
          ListTile(
            leading: Icon(FeatherIcons.settings, size: 20, color: grayBar),
            title: Text(
              'Settings',
              style: textBar,
            ),
            onTap: () {},
          ),
          Container(height: 2, color: const Color(0xFFCFCFCF)),
          ListTile(
              leading: Icon(FeatherIcons.helpCircle, size: 20, color: grayBar),
              title: Text('Help', style: textBar),
              onTap: () {}),
          ListTile(
            leading: const Icon(FeatherIcons.logOut,
                size: 20, color: Color(0xFFD55F5A)),
            title: const Text(
              'Logout',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD55F5A),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  height: 0.10,
                  letterSpacing: -0.28),
            ),
            onTap: () async {
              final providers =
                  FirebaseAuth.instance.currentUser!.providerData[0].providerId;
              print(FirebaseAuth.instance.currentUser!.providerData);
              AuthMethods().signOut(providers);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

class MyData {
  static List<Map> data = [
    {
      "id": 1,
      "name": "พ่อ",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["Hii", "Hello"],
      "state": [0, 0]
    },
    {
      "id": 2,
      "name": "แม่",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["I Love U"],
      "state": [0]
    },
    {
      "id": 3,
      "name": "0999999999",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": [
        "ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ ยืมเงินหน่อยคับ"
      ],
      "state": [1]
    },
    {
      "id": 4,
      "name": "0888888888",
      "phone": "0888888888",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สวัสดีฮะ", "สวัสดีฮะ"],
      "state": [1, 2]
    },
    {
      "id": 5,
      "name": "แฟน",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สบายดีรึเปล่า"],
      "state": [0]
    },
    {
      "id": 6,
      "name": "แฟน",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สบายดีรึเปล่า"],
      "state": [0]
    },
    {
      "id": 7,
      "name": "แฟน",
      "phone": "0999999999",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สบายดีรึเปล่า"],
      "state": [0]
    },
    {
      "id": 8,
      "name": "0999999998",
      "phone": "0999999998",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สบายดีรึเปล่า"],
      "state": [2]
    },
    {
      "id": 9,
      "name": "0999999998",
      "phone": "0999999998",
      "image": "assets/images/profile.png",
      "time": [],
      "message": ["สบายดีรึเปล่า"],
      "state": [2]
    }
  ];
}
