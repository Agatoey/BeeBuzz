import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/SMS_messages.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
      final contacts = await FlutterContacts.getContacts(withPhoto: true);
      // print(contacts[0].phones[0].number);
      setState(() => _contacts = contacts);
      getName("0821308781");
    }
  }

  Future getName(String sender) async {
    for (final contact in _contacts!) {
      final _contact = await FlutterContacts.getContact(contact.id);
      if (_contact!.phones.isNotEmpty) {
        // print(_contact.phones.first.number);
        if (sender == _contact.phones.first.number) {
          print(_contact.phones.first.number);
          return;
        } else {}
      }
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
                MaterialPageRoute(builder: (context) => const Allsms()));
          },
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _fetchData, child: Scaffold(body: _body())));

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, i) {
          Contact contact = _contacts![i];
          // print(contact.displayName);
          return ListTile(
              leading: Stack(children: [
                Container(
                    height: 50,
                    width: 50,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFCB9696),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100))),
                    child: (contact.photo != null)
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!))
                        : const CircleAvatar()),
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
              title: Text(contact.displayName),
              onTap: () async {
                final fullContact =
                    await FlutterContacts.getContact(contact.id);
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ContactPage(fullContact!)));
              });
        });
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
