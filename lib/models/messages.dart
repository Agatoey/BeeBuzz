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
      required this.scoresms,
      required this.state,
      required this.linkbody,
      required this.linktype,
      required this.scorelink,
      required this.model});

  String body;
  DateTime date;
  String time;
  double score;
  double scoresms;
  int state;
  String linkbody;
  String? linktype;
  double scorelink;
  String? model;

  Map<String, dynamic> toJson() => {
        'body': body,
        'date': date.toString(),
        'time': time,
        'score': score,
        'scoresms': scoresms,
        'state': state,
        'linkbody': linkbody,
        'linktype': linktype,
        'scorelink': scorelink,
        'model': model
      };
}