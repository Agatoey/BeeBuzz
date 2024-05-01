class MessageModel {
  MessageModel(
      {required this.name, required this.photo, required this.messages});

  String name;
  List<int> photo;
  List<Messages> messages;

  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': photo,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };
}

class Messages {
  Messages(
      {required this.body,
      required this.date,
      required this.time,
      required this.score,
      required this.state,
      required this.link,
      required this.linkState});

  String body;
  DateTime date;
  String time;
  int score;
  int state;
  String link;
  String linkState;

  Map<String, dynamic> toJson() => {
        'body': body,
        'date': date.toString(),
        'time': time,
        'score': score,
        'state': state,
        'link': link,
        'linkState': linkState
      };
}

// class Link {
//   Link({
//     required this.state,
//     required this.link,
//   });

//   bool state;
//   int link;

//   Map<String, dynamic> toJson() => {
//         'state': state,
//         'link': link,
//       };
// }
