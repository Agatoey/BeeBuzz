import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/pages/testContact1.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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

  @override
  void initState() {
    super.initState();
    roadSMSTest();
    // getName("0821308781");
  }

  Future _fetchData() async {
    var permission = await FlutterContacts.requestPermission(readonly: true);
    final contacts = await FlutterContacts.getContacts(withPhoto: true);
    if (permission) {
      setState(() => _contacts = contacts);
    }
  }

  Future roadSMSTest() async {
    var permission = await Permission.sms.request();
    if (!permission.isGranted) {
      setState(() => _permissionDenied = true);
    } else {
      final messages =
          await _query.querySms(kinds: [SmsQueryKind.inbox], count: 100);
      setState(() {
        _messages = messages;
      });
      _fetchData();
    }
  }

  String getName(String sender) {
    for (var i = 0; i < _contacts!.length;) {
      var contact = _contacts![i];
      if (sender == contact.phones.elementAt(0).number) {
        print("เบอร์ ${contact.phones.first.number}");
        return contact.phones.first.number;
      }
      return sender;
    }
    return "Unknow";
  }

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
            },
          ),
        ),
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
    Map<String, List<SmsMessage>> messagesBySender = {};

    void testsms() {
      for (var message in messages) {
        var sender = message.sender;
        if (!messagesBySender.containsKey(sender)) {
          messagesBySender[sender.toString()] = [];
        }
        messagesBySender[sender]?.add(message);
      }
    }

    testsms();
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
            return ListTile(
              title: Text(sender,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Image.asset(
                    "assets/images/profile.png",
                    fit: BoxFit.fitWidth,
                  ),
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
          },
        ));
  }
}
