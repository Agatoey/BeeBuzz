import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/SMS_messages.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';
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
