import 'dart:convert';

// class MessageModel {
//   MessageModel({required this.name, required this.messages});

//   String name;
//   List<Messages> messages;

//   factory MessageModel.fromJson(Map<String, dynamic> json) {
//     List<dynamic> messagesJson = json['messages'];
//     List<Messages> messages =
//         messagesJson.map((message) => Messages.fromJson(message)).toList();
//     return MessageModel(
//       name: json['name'],
//       messages: messages,
//     );
//   }
// }

// class Messages {
//   Messages({required this.body, required this.date, required this.time});

//   String body;
//   DateTime date;
//   String time;

//   factory Messages.fromJson(Map<String, dynamic> json) {
//     return Messages(
//       body: json['body'],
//       date: DateTime.parse(json['date']),
//       time: json['time'],
//     );
//   }
// }

class MessageModel {
  MessageModel({required this.name, required this.messages});

  String name;
  List<Messages> messages;

  Map<String, dynamic> toJson() => {
        'name': name,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };
}

class Messages {
  Messages({required this.body, required this.date, required this.time});

  String body;
  DateTime date;
  String time;

  Map<String, dynamic> toJson() =>
      {'body': body, 'date': date.toString(), 'time': time};
}

// void main() {
//   String jsonString = '''
//   [
//     {
//       "name": "A",
//       "messages": [
//         {"body": "Hello", "date": "2024-04-29", "time": "10:00:00"},
//         {"body": "i love u", "date": "2024-04-29", "time": "10:15:00"}
//       ]
//     },
//     {
//       "name": "B",
//       "messages": [
//         {"body": "Hello", "date": "2024-04-29", "time": "09:30:00"},
//         {"body": "i love u", "date": "2024-04-29", "time": "09:45:00"}
//       ]
//     }
//   ]
//   ''';

//   List<dynamic> jsonList = jsonDecode(jsonString);
//   List<MessageModel> messageModels =
//       jsonList.map((json) => MessageModel.fromJson(json)).toList();

//   // ตรวจสอบการทำงาน
//   for (var messageModel in messageModels) {
//     print('Name: ${messageModel.name}');
//     for (var message in messageModel.messages) {
//       print(
//           'Message: ${message.body}, Date: ${message.date}, Time: ${message.time}');
//     }
//     print('-----');
//   }
// }
