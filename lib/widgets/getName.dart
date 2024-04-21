import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class GetName extends StatefulWidget {
  const GetName({super.key, required this.sender});
  final String sender;

  @override
  State<GetName> createState() => _GetNameState();
}

class _GetNameState extends State<GetName> {
  List<Contact>? _contacts;
  late final Contact infocontact;

  @override
  void initState() {
    super.initState();
  }

  Future<Contact?> getName(String sender) async {
    print("Sender = ${widget.sender}");
    _contacts = await FlutterContacts.getContacts(withPhoto: true);
    for (final contact in _contacts!) {
      final contactid = await FlutterContacts.getContact(contact.id);
      if (contactid!.phones.isNotEmpty) {
        if (sender == contactid.phones.first.number) {
          print(contactid.phones.first.number);
          setState(() {
            infocontact = contactid;
          });
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return test();
  }

  Widget test() {
    return FutureBuilder<Contact?>(
      future: getName(widget.sender),
      builder: (BuildContext context, AsyncSnapshot<Contact?> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold));
        }
        return Text(widget.sender,
            style: const TextStyle(fontWeight: FontWeight.bold));
      },
    );
  }

  Widget setinfocontact() {
    getName(widget.sender);
    return Text(
        infocontact.phones.isEmpty ? widget.sender : infocontact.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold));
  }
}

class GetImage extends StatefulWidget {
  const GetImage({super.key, required this.sender, required this.type});
  final String sender;
  final String type;

  @override
  State<GetImage> createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  List<Contact>? _contacts;
  late final Contact infocontact;

  @override
  void initState() {
    super.initState();
    getImage();
  }

  Future<Contact?> getImage() async {
    print("Sender = ${widget.sender}");
    _contacts = await FlutterContacts.getContacts(withPhoto: true);
    for (final contact in _contacts!) {
      final contactid = await FlutterContacts.getContact(contact.id);
      if (contactid!.phones.isNotEmpty) {
        if (widget.sender == contactid.phones.first.number) {
          print(contactid.phones.first.number);
          setState(() {
            infocontact = contactid;
          });
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return setinfocontact();
  }

  Widget setinfocontact() {
    if (infocontact.photo!.isEmpty) {
      return Image.asset(
        "assets/images/profile.png",
        fit: BoxFit.fitWidth,
      );
    } else {
      return CircleAvatar(backgroundImage: MemoryImage(infocontact.photo!));
    }
  }
}
