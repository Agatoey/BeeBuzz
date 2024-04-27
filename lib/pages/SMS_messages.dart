import 'dart:typed_data';

import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:sms_advanced/sms_advanced.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  Map<String, List<SmsMessage>> messagesBySender = {};
  Map<String, List<SmsMessage>> bySender = {};

  @override
  void initState() {
    super.initState();
    roadSMSTest();
  }

  Future roadSMSTest() async {
    messagesBySender = {};
    bySender = {};
    var permission = await Permission.sms.request();
    if (!permission.isGranted) {
      setState(() => _permissionDenied = true);
    } else {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        // address: getContactAddress(),
      );
      setState(() {
        _messages = messages;
      });
      _fetchData();
      for (var message in _messages) {
        if (!messagesBySender.containsKey(message.sender)) {
          messagesBySender[message.sender.toString()] = [];
        }
        messagesBySender[message.sender]?.add(message);
      }
    }
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

  Future<Contact?> getInfo(String sender) async {
    for (final contact in _contacts!) {
      final contactid = await FlutterContacts.getContact(contact.id);
      if (contactid!.phones.isNotEmpty) {
        if (sender == contactid.phones.first.number) {
          return contactid;
        }
      }
    }
    return null;
  }

  // Future _fetchData() async {
  //   var permission = await FlutterContacts.requestPermission(readonly: true);
  //   final contacts = await FlutterContacts.getContacts(withPhoto: true);
  //   if (permission) {
  //     setState(() => _contacts = contacts);
  //   }
  // }

  Future _fetchData() async {
    var permission = await FlutterContacts.requestPermission(readonly: true);
    final contacts = await FlutterContacts.getContacts(withPhoto: true);
    if (permission) {
      setState(() => _contacts = contacts);
      var sender;

      for (var message in _messages) {
        sender = message.sender;
        if (!messagesBySender.containsKey(sender)) {
          messagesBySender[sender.toString()] = [];
        }
        messagesBySender[sender]?.add(message);
      }

      // print("จำนวนผู้ส่ง: ${messagesBySender.length}");
      // messagesBySender.forEach((sender, messages) async {
      //   for (final contact in _contacts!) {
      //     final contactid = await FlutterContacts.getContact(contact.id);
      //     if (contactid!.phones.isNotEmpty) {
      //       if (sender == contactid.phones.first.number) {
      //         messagesBySender[contactid.displayName] =
      //             messagesBySender[sender]!;
      //         print("$sender = ${contactid.displayName}");
      //         setState(() {
      //           messagesBySender.remove(sender);
      //           bySender = messagesBySender;
      //         });
      //       } else {

      //       }
      //     }
      //   }
      // });
    }
  }

  // Future<Contact?> getInfo(String sender) async {
  //   for (final contact in _contacts!) {
  //     final contactid = await FlutterContacts.getContact(contact.id);
  //     if (contactid!.phones.isNotEmpty) {
  //       if (sender == contactid.phones.first.number) {
  //         return contactid;
  //       }
  //     }
  //   }
  //   return null;
  // }

  // Future<String?> getName(String sender) async {
  //   for (final contact in _contacts!) {
  //     final _contact = await FlutterContacts.getContact(contact.id);
  //     if (_contact!.phones.isNotEmpty) {
  //       if (sender == _contact.phones.first.number) {
  //         print(_contact.phones.first.number);
  //         return _contact.displayName;
  //       }
  //     }
  //   }
  //   return null;
  // }

  // Future<Uint8List?> getImage(String sender) async {
  //   for (final contact in _contacts!) {
  //     final _contact = await FlutterContacts.getContact(contact.id);
  //     if (_contact!.phones.isNotEmpty) {
  //       if (sender == _contact.phones.first.number &&
  //           _contact.photo!.isNotEmpty) {
  //         return _contact.photo;
  //       }
  //     }
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Text("Test", style: textHead),
            backgroundColor: mainScreen,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Allsms()));
                })),
        body: _body());
  }

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: roadSMSTest,
        child: Scaffold(
            backgroundColor: bgYellow,
            body: const Center(child: CircularProgressIndicator())),
      );
    }
    return Scaffold(
      backgroundColor: bgYellow,
      body: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10.0),
              child: RefreshIndicator(
                onRefresh: roadSMSTest,
                child: messagesListView(_messages),
              )),
          TextButton(onPressed: () {}, child: const Text('Test'))
        ],
      ),
    );
  }

  Widget messagesListView(List<SmsMessage> messages) {
    return Container(
        height: 500,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        decoration: ShapeDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21))),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: messagesBySender.length,
            itemBuilder: (context, index) {
              String sender = messagesBySender.keys.toList()[index];
              List<SmsMessage>? messages = messagesBySender[sender];
              SmsMessage message = messages![0];
              // String sender = bySender.keys.toList()[index];
              // List<SmsMessage>? messages = bySender[sender];
              // SmsMessage message = messages![0];
              return ListTile(
                title:
                    // Text(sender,
                    //     style: const TextStyle(fontWeight: FontWeight.bold)),
                    FutureBuilder<Contact?>(
                  future: getInfo(sender),
                  builder:
                      (BuildContext context, AsyncSnapshot<Contact?> snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold));
                    }
                    return Text(sender,
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  },
                ),
                // FutureBuilder<String?>(
                //   future: getContactName(sender),
                //   builder:
                //       (BuildContext context, AsyncSnapshot<String?> snapshot) {
                //     if (snapshot.hasData) {
                //       return Text(snapshot.data!,
                //           style: const TextStyle(fontWeight: FontWeight.bold));
                //     }
                //     return Text(sender,
                //         style: const TextStyle(fontWeight: FontWeight.bold));
                //   },
                // ),
                subtitle: Text('${message.body}',
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
                      child:
                          // Image.asset(
                          //   "assets/images/profile.png",
                          //   fit: BoxFit.fitWidth,
                          // ),

                          FutureBuilder<Contact?>(
                  future: getInfo(sender),
                  builder:
                      (BuildContext context, AsyncSnapshot<Contact?> snapshot) {
                    final Uint8List? imageData = snapshot.data?.photo;
                    if (snapshot.hasData && imageData != null) {
                      return CircleAvatar(
                        backgroundImage: MemoryImage(imageData),
                      );
                    }
                    return Image.asset(
                      "assets/images/profile.png",
                      fit: BoxFit.fitWidth,
                    );
                  },
                )
                      //     FutureBuilder<Uint8List?>(
                      //   future: getContactPhoto(sender),
                      //   builder: (BuildContext context,
                      //       AsyncSnapshot<Uint8List?> snapshot) {
                      //     final Uint8List? imageData = snapshot.data;
                      //     if (snapshot.hasData && imageData!.isNotEmpty) {
                      //       return CircleAvatar(
                      //         backgroundImage: MemoryImage(imageData),
                      //       );
                      //     }
                      //     return Image.asset(
                      //       "assets/images/profile.png",
                      //       fit: BoxFit.fitWidth,
                      //     );
                      //   },
                      // )
                      ),
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
                onTap: () {},
              );
            }));
  }
}