import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/SMS_messages.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class TestLastSMS extends StatefulWidget {
  const TestLastSMS({
    super.key,
    required this.messages,
  });
  final List<SmsMessage> messages;

  @override
  State<TestLastSMS> createState() => _TestLastSMSState();
}

class _TestLastSMSState extends State<TestLastSMS> {
  @override
  void initState() {
    testsms();
    super.initState();
  }

  Map<String, List<SmsMessage>> messagesBySender = {};
  testsms() {
    for (var message in widget.messages) {
      var sender = message.sender;
      if (!messagesBySender.containsKey(sender)) {
        messagesBySender[sender.toString()] = [];
      }
      messagesBySender[sender]?.add(message);
    }
    // debugPrint(widget.messages.toString());
    debugPrint(messagesBySender.toString());
    setState(() {
      messagesBySender = messagesBySender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("TestSMS", style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyApp()));
            },
          ),
        ),
        backgroundColor: bgYellow,
        body: ListView.builder(
          itemCount: messagesBySender.length,
          itemBuilder: (context, index) {
            String sender = messagesBySender.keys.toList()[index];
            List<SmsMessage>? messages = messagesBySender[sender];
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) {
                SmsMessage message = messages![index];
                return ListTile(
                  title: Text('Sender: $sender',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(message.body.toString()),
                );
              },
            );
          },
        ));
  }
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
    _fetchData();
  }

  Future _fetchData() async {
    var permission = await FlutterContacts.requestPermission(readonly: true);
    if (!permission) {
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
