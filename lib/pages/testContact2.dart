import 'dart:async';

import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/SMS_messages.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class Contacts2 extends StatefulWidget {
  const Contacts2({super.key});

  @override
  Contacts2State createState() => Contacts2State();
}

class Contacts2State extends State<Contacts2> {
  List<Contact> _contacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    getallContact();
  }

  Future getallContact() async {
    List<Contact> contacts =
        (await ContactsService.getContacts()).toList();
    for (var contact in contacts) {
      print('Name: ${contact.displayName}');
      for (var phone in contact.phones!) {
        print('Phone number: ${phone.value}');
      }
    }
    setState(() {
      _contacts = contacts;
    });
  }

  String _getPhoneNumber(Contact contact) {
    if (contact.phones!.isNotEmpty) {
      return contact.phones!.first.value.toString();
    } else {
      return 'No phone number available';
    }
  }

  // Future _fetchData() async {
  //   var permission = await FlutterContacts.requestPermission(readonly: true);
  //   if (!permission) {
  //     setState(() => _permissionDenied = true);
  //   } else {
  //     final contacts = await FlutterContacts.getContacts(withPhoto: true);
  //     print(contacts[0].accounts);
  //     setState(() => _contacts = contacts);
  //   }
  // }

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
          onRefresh: getallContact, child: Scaffold(body: _body())));

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _contacts.length,
        itemBuilder: (context, i) {
          Contact contact = _contacts[i];
          return ListTile(
              leading: (contact.avatar!.isNotEmpty)
                  ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                  : CircleAvatar(
                      child: Text(contact.initials()),
                    ),
              // Stack(children: [
              //   Container(
              //     height: 50,
              //     width: 50,
              //     decoration: ShapeDecoration(
              //         color: const Color(0xFFCB9696),
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(100))),
              //     child: Image.asset(
              //       "assets/images/profile.png",
              //       fit: BoxFit.fitWidth,
              //     ),
              //   ),
              //   Positioned(
              //       bottom: 0,
              //       right: 0,
              //       child: Container(
              //           width: 20,
              //           height: 20,
              //           decoration: ShapeDecoration(
              //               color: const Color(0xFFFF2F00),
              //               shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(100))),
              //           child: const Center(
              //               child: Icon(
              //                   color: Colors.white,
              //                   Icons.priority_high,
              //                   size: 18))))
              // ]),
              title: Text(contact.displayName.toString()),
              subtitle: Text(_getPhoneNumber(contact)),
              onTap: () async {
                // final fullContact =
                //     await FlutterContacts.getContact(_contacts![i].id);
                // await Navigator.of(context).push(
                //     MaterialPageRoute(builder: (_) => ContactPage(fullContact!)));
              });
        });
  }
}

// class ContactPage extends StatelessWidget {
//   final Contact contact;
//   const ContactPage(this.contact, {super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//       appBar: AppBar(title: Text(contact.displayName)),
//       body: Column(children: [
//         Text('First name: ${contact.name.first}'),
//         Text('Last name: ${contact.name.last}'),
//         Text(
//             'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
//         Text(
//             'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
//       ]));
// }
