import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/pages/test.dart';
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

  @override
  void initState() {
    roadSMS();
    super.initState();
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
        body: _messages.isEmpty
            ? Scaffold(
                backgroundColor: bgYellow,
                body: const Center(child: CircularProgressIndicator()))
            : Scaffold(
                backgroundColor: bgYellow,
                body: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child: RefreshIndicator(
                          onRefresh: roadSMS,
                          child: messagesListView(_messages),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ContactsExample()));
                        },
                        child: const Text('Contacts')),
                    TextButton(
                        onPressed: () {
                          // roadSMS();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TestLastSMS(messages: _messages)));
                        },
                        child: const Text('Test'))
                  ],
                ),
              ));
  }

  Future<bool> roadSMS() async {
    bool res = false;
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox
        ],
        count: 5,
      );
      debugPrint('sms inbox messages: ${messages.length}');
      setState(() => _messages = messages);

      res = true;
    } else {
      await Permission.sms.request();
    }
    return res;
  }
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
      height: 600,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: ShapeDecoration(
          color: Colors.white.withOpacity(0.7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(21))),
      child: ListView.builder(
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
              ]));
        },
      ));
}

class ContactsExample extends StatefulWidget {
  const ContactsExample({super.key});

  @override
  ContactsExampleState createState() => ContactsExampleState();
}

class ContactsExampleState extends State<ContactsExample> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Contacts", style: textHead),
        backgroundColor: mainScreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MyApp()));
          },
        ),
      ),
      body: Scaffold(body: _body()));

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, i) => ListTile(
            title: Text(_contacts![i].displayName),
            onTap: () async {
              final fullContact =
                  await FlutterContacts.getContact(_contacts![i].id);
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ContactPage(fullContact!)));
            }));
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  const ContactPage(this.contact, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(contact.displayName)),
      body: Column(children: [
        Text('First name: ${contact.name.first}'),
        Text('Last name: ${contact.name.last}'),
        Text(
            'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
        Text(
            'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
      ]));
}