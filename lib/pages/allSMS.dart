import 'dart:async';
import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/accPage.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/pages/filterPage.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/pages/testContact1.dart';
import 'package:appbeebuzz/service/getAPI.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
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
  late String signoutWith;

  final SmsQuery _query = SmsQuery();

  Map<String, List> messagesBySender = {};
  List<SmsMessage> _messages = [];
  List<MessageModel> messageModels = [];
  bool _permissionDenied = false;

  List filterText = ["free", "click"];

  bool isPress1 = true;
  final _selectedSegment = ValueNotifier('all');

  // late Data data;

  // late Timer delay;

  @override
  void initState() {
    isPress1 = true;
    roadSMSTest();
    getJson();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getURL(){
    Data().xSendUrlScan("https://twitter.com/linlinSsakura/status/1784897696744047063");
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
        setState(() {
          messagesBySender[message.sender]?.add(message);
        });
        // print("${message.date!.hour}:${message.date!.minute}");
      }
      await Permission.contacts.request();
      getURL();
      // print(messagesBySender.keys);
      // messagesBySender.forEach((key, value) {
      //   print(key.toString());
      // });
    }
  }

  getJson() async {
    messageModels = [];
    late var contacts;
    for (var entry in messagesBySender.entries) {
      var key = entry.key;
      var value = entry.value;
      // var score;
      // score = 10;

      List<Messages> messages = [];
      contacts = await ContactsService.getContactsForPhone(key);
      if (contacts.isNotEmpty) {
        for (var msg in value) {
          messages.add(Messages(
              body: msg.body,
              date: DateTime.parse(msg.date.toString()),
              time: "${msg.date!.hour}:${msg.date!.minute}",
              score: 0,
              state: 0,
              linkState: false,
              link: ""));
        }

        messageModels.add(MessageModel(
            name: contacts.first.displayName,
            photo: contacts.first.avatar,
            messages: messages));
      }
      if (contacts.isEmpty) {
        for (var msg in value) {
          // print(msg.date);
          messages.add(Messages(
              body: msg.body,
              date: DateTime.parse(msg.date.toString()),
              time: "${msg.date!.hour}:${msg.date!.minute}",
              score: 60,
              state: 1,
              linkState: true,
              link: ""));
        }
        messageModels
            .add(MessageModel(name: key, photo: [], messages: messages));
      }
    }
    // Print the result
    // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    // String prettyprint = encoder.convert(messageModels);
    // debugPrint(prettyprint);
    // print(jsonEncode(messageModels));
  }

  // Future<String?> getContactName(String phoneNumber) async {
  //   final contacts = await ContactsService.getContactsForPhone(phoneNumber);
  //   if (contacts.isNotEmpty) {
  //     return contacts.first.displayName;
  //   }
  //   return null;
  // }

  // Future<Uint8List?> getContactPhoto(String phoneNumber) async {
  //   final contacts = await ContactsService.getContactsForPhone(phoneNumber);
  //   if (contacts.isNotEmpty) {
  //     return contacts.first.avatar;
  //   }
  //   return null;
  // }

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
          body: Container(
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
                SingleChildScrollView(
                  child: RefreshIndicator(
                    onRefresh: roadSMSTest,
                    child: Container(
                      height: 550,
                      // constraints: BoxConstraints(
                      //   minHeight: 550,
                      //   // minHeight: MediaQuery.of(context).size.height / 2,
                      // ),
                      // padding: EdgeInsets.only(bottom: 20),
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
                              return allSMS(_messages);
                            case 'fraud':
                              return fraudSMS(_messages);
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Uint8List stringToUint8List(String text) {
    print(Uint8List.fromList(text.codeUnits));
    return Uint8List.fromList(text.codeUnits);
  }

  Widget allSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty) {
      return Scaffold(
          backgroundColor: bgYellow,
          body: const Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder(
      future: getJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(mainScreen),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: messageModels.length,
          itemBuilder: (context, index) {
            var count = messageModels[index].messages.length - 1;
            return ListTile(
              // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
              title: Text(messageModels[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(messageModels[index].messages[0].body,
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
                    child: messageModels[index].photo.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              Uint8List.fromList(messageModels[index].photo),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            "assets/images/profile.png",
                            fit: BoxFit.fitWidth,
                          )),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: messageModels[index].messages[0].state == 0
                        ? Container()
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                                color: messageModels[index]
                                            .messages[count]
                                            .state ==
                                        1
                                    ? const Color(0xFFFCE205)
                                    : const Color(0xFFFF2F00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100))),
                            child: const Center(
                                child: Icon(
                                    color: Colors.white,
                                    Icons.priority_high,
                                    size: 18))))
              ]),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowMsg(
                              messages: messageModels[index].messages,
                              name: messageModels[index].name,
                            )));
              },
            );
          },
        );
      },
    );
  }

  Widget fraudSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty) {
      return Scaffold(
          backgroundColor: bgYellow,
          body: const Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder(
      future: getJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(mainScreen),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: messageModels.length,
          itemBuilder: (context, index) {
            var count = messageModels[index].messages.length - 1;
            if (messageModels[index].messages[count].state != 0) {
              return ListTile(
                // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
                title: Text(messageModels[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(messageModels[index].messages[0].body,
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
                      child: messageModels[index].photo.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                Uint8List.fromList(messageModels[index].photo),
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              "assets/images/profile.png",
                              fit: BoxFit.fitWidth,
                            )),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: messageModels[index].messages[0].state == 0
                          ? Container()
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                  color: messageModels[index]
                                              .messages[count]
                                              .state ==
                                          1
                                      ? const Color(0xFFFCE205)
                                      : const Color(0xFFFF2F00),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100))),
                              child: const Center(
                                  child: Icon(
                                      color: Colors.white,
                                      Icons.priority_high,
                                      size: 18))))
                ]),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowMsg(
                                messages: messageModels[index].messages,
                                name: messageModels[index].name,
                              )));
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
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
