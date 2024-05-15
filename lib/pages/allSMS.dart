import 'dart:async';
import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/accPage.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/pages/filterPage.dart';
import 'package:appbeebuzz/pages/settingPage.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/service/getAPI.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:appbeebuzz/utils/classify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicons/unicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';

class Allsms extends StatefulWidget {
  Allsms({super.key, required this.listMessage});

  static const String routeName = '/Allsms';
  List<MessageModel> listMessage;

  @override
  State<Allsms> createState() => _AllsmsState();
}

class _AllsmsState extends State<Allsms> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey();

  final SmsQuery _query = SmsQuery();

  Map<String, List> messagesBySender = {};
  List<SmsMessage> _messages = [];
  List<MessageModel> messageModels = [];

  final _selectedSegment = ValueNotifier('all');

  late String? model;

  List<dynamic>? filterTexts;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Classifier _classifier;

  DateTime timeBackPressed = DateTime.now();

  late String tokenize;
  String? type;
  late double linkscore;

  @override
  void initState() {
    reload();
    messageModels = widget.listMessage;
    _classifier = Classifier();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int countMessages(List<MessageModel> listMessage) {
    return listMessage
        .map((messageModel) => messageModel.messages.length)
        .fold(0, (previousValue, element) => previousValue + element);
  }

  bool areBodiesEqual(List<MessageModel> list1, List<SmsMessage> list2) {
    if (countMessages(list1) != list2.length) {
      return false;
    }
    List x = [];
    for (int i = 0; i < list1.length; i++) {
      for (int j = 0; j < list1[i].messages.length; j++) {
        x.add(list1[i].messages[j].body);
      }
    }
    for (int i = 0; i < list1.length; i++) {
      // print("${x[i]} : ${list2[i].body}");
      if (x[i] != list2[i].body) {
        return false;
      }
    }

    return true;
  }

  // bool areBodiesEqual2(List<MessageModel> list1, List<MessageModel> list2) {
  //   if (countMessages(list1) != countMessages(list2)) {
  //     return false;
  //   }

  //   for (int i = 0; i < list1.length; i++) {
  //     for (int j = 0; j < list1[i].messages.length; j++) {
  //       if (list1[i].messages[j].body != list2[i].messages[j].body) {
  //         return false;
  //       }
  //     }
  //   }
  //   return true;
  // }

  // void printBodies(List<MessageModel> list1, List<SmsMessage> list2) {
  //   for (int i = 0; i < list1.length; i++) {
  //     for (int j = 0; j < list1[i].messages.length; j++) {
  //       debugPrint('List 1 body: ${list1[i].messages[j].body}');
  //     }
  //   }
  //   for (int i = 0; i < list2.length; i++) {
  //     debugPrint('List 2 body: ${list2[i].body}');
  //   }
  // }

  List<SmsMessage> testSMS = [];

  Future reload() async {
    testSMS = [];
    final messages = await _query.querySms(kinds: [
      SmsQueryKind.inbox,
    ], count: 5);
    setState(() {
      testSMS = messages;
    });

    var count1 = areBodiesEqual(widget.listMessage, testSMS);
    var count2 = areBodiesEqual(messageModels, testSMS);
    // printBodies(messageModels, testSMS);
    debugPrint(
        "จำนวน ${countMessages(widget.listMessage)} ${testSMS.length} : $count1 : $count2");
    if (count1 == false || count2 == false || messageModels.isEmpty) {
      loadSMS();
      getJson();
      debugPrint("โหลดใหม่");
    }
    if (widget.listMessage.isNotEmpty && count1) {
      debugPrint(
          "จำนวนข้อความ1: ${countMessages(widget.listMessage)} ${testSMS.length} : $count1");
      messageModels = widget.listMessage;
    } else if (messageModels.isNotEmpty) {
      messageModels = messageModels;
      debugPrint("จำนวนข้อความ2: ${testSMS.length}");
    }
  }

  getListFilter() async {
    if (user != null) {
      filterTexts = [];
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      final snapshot = await users.doc(user!.uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        filterTexts = data['filter'];
      });
    }
  }

  Future loadSMS() async {
    print("Load");
    messagesBySender = {};
    _messages = [];
    var permission = await Permission.sms.request();
    if (!permission.isGranted) {
    } else {
      final messages = await _query.querySms(kinds: [
        SmsQueryKind.inbox,
      ], count: 5);
      setState(() {
        _messages = messages;
      });

      await getListFilter();

      if (filterTexts!.isNotEmpty) {
        _messages.removeWhere((message) {
          for (var textFilter in filterTexts!) {
            if (message.body!
                .toLowerCase()
                .contains(textFilter.toLowerCase())) {
              return true;
            }
          }
          return false;
        });
      } else if (filterTexts == null) {
        return _messages;
      }

      for (var message in _messages) {
        if (!messagesBySender.containsKey(message.sender)) {
          messagesBySender[message.sender.toString()] = [];
        }
        setState(() {
          messagesBySender[message.sender]?.add(message);
        });
      }
    }
  }

  getJson() async {
    late String link;
    messageModels = [];
    var contacts;
    for (var entry in messagesBySender.entries) {
      var key = entry.key;
      var value = entry.value;
      var matches;
      RegExp regExp = RegExp(
          r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");

      contacts = await ContactsService.getContactsForPhone(key);
      if (contacts.isNotEmpty) {
        for (var msg in value) {
          link = "";
          String text = "";

          matches = regExp.allMatches(msg.body);
          for (final m in matches) {
            link = m[0];
            text = msg.body.replaceFirst(link, '');
          }

          double score;
          if (link.isEmpty) {
            link = "";
            text = msg.body;
            type = "Unkown";
            linkscore = 0;
          }
          if (text.isEmpty) {
            text = "";
          }
          if (link.isNotEmpty) {
            await getURLType(link);
            type ??= "Unkown";
          }

          model = "";
          score = await prediction(text, link, msg.body);

          int state = 0;

          if (score <= 30) {
            state = 0;
          }
          if (score > 31 && score <= 70) {
            state = 1;
          }
          if (score > 71) {
            state = 2;
          }

          debugPrint(
              "Model : $score | $predic | $link | $type | $linkscore | $state | $model");

          var samename = messageModels
              .indexWhere((model) => model.name == contacts.first.displayName);
          if (samename != -1) {
            messageModels[samename].messages.add(Messages(
                body: msg.body,
                date: DateTime.parse(msg.date.toString()),
                time: "${msg.date!.hour}:${msg.date!.minute}",
                score: score,
                scoresms: predic!,
                linkbody: link,
                linktype: type,
                scorelink: linkscore,
                state: state,
                model: model));
          } else {
            messageModels.add(MessageModel(
                name: contacts.first.displayName,
                photo: contacts.first.avatar,
                messages: [
                  Messages(
                      body: msg.body,
                      date: DateTime.parse(msg.date.toString()),
                      time: "${msg.date!.hour}:${msg.date!.minute}",
                      score: score,
                      scoresms: predic!,
                      linkbody: link,
                      linktype: type,
                      scorelink: linkscore,
                      state: state,
                      model: model)
                ]));
          }
        }
      }
      if (contacts.isEmpty) {
        for (var msg in value) {
          link = "";
          String text = "";

          matches = regExp.allMatches(msg.body);
          for (final m in matches) {
            link = m[0];
            text = msg.body.replaceFirst(link, '');
          }

          double score;
          if (link.isEmpty) {
            link = "";
            text = msg.body;
            type = "Unkown";
            linkscore = 0;
          }
          if (text.isEmpty) {
            text = "";
          }
          if (link.isNotEmpty) {
            await getURLType(link);
            type ??= "Unkown";
          }

          // print("text : $text");
          // print("Link : $link");
          model = "";
          score = await prediction(text, link, msg.body);

          int state = 0;

          if (score <= 30) {
            state = 0;
          }
          if (score > 31 && score <= 70) {
            state = 1;
          }
          if (score > 71) {
            state = 2;
          }

          debugPrint(
              "Model : $score | $predic | $link | $type | $linkscore | $state | $model");

          var samename = messageModels.indexWhere((model) => model.name == key);
          if (samename != -1) {
            messageModels[samename].messages.add(Messages(
                body: msg.body,
                date: DateTime.parse(msg.date.toString()),
                time: "${msg.date!.hour}:${msg.date!.minute}",
                score: score,
                scoresms: predic!,
                linkbody: link,
                linktype: type,
                scorelink: linkscore,
                state: state,
                model: model));
          } else {
            messageModels.add(MessageModel(name: key, photo: [], messages: [
              Messages(
                  body: msg.body,
                  date: DateTime.parse(msg.date.toString()),
                  time: "${msg.date!.hour}:${msg.date!.minute}",
                  score: score,
                  scoresms: predic!,
                  linkbody: link,
                  linktype: type,
                  scorelink: linkscore,
                  state: state,
                  model: model)
            ]));
          }
        }
      }
    }
    // Print the result
    // JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    // String prettyprint = encoder.convert(messageModels);
    // // debugPrint(prettyprint);
    // print(jsonEncode("Messages ${prettyprint}"));
    // for (var element in messageModels) {
    //   debugPrint(element.messages.first.body);
    // }

    setState(() {
      widget.listMessage = messageModels;
    });
    for (var element in widget.listMessage) {
      debugPrint(element.messages.first.body);
    }
  }

  Future<String?> selectModels(String sms) async {
    var res = await Data().selectmodel(sms);
    model = res!["model"].toString();
    tokenize = res["sms"].toString();
    print(tokenize);
    return model;
  }

  getURLType(String linkbody) async {
    type = "";
    var res = await Data().xSendUrlScan(linkbody);

    if (res?.attributes["last_analysis_stats"] != null) {
      Map<String, dynamic> x;

      x = res?.attributes["last_analysis_stats"];
      debugPrint("last_analysis_stats : $x");

      int maxMalicious = x['malicious'] ?? 0;
      int maxSuspicious = x['suspicious'] ?? 0;

      x.forEach((key, value) {
        if (key == 'malicious' && value > maxMalicious) {
          maxMalicious = value;
        }
        if (key == 'suspicious' && value > maxSuspicious) {
          maxSuspicious = value;
        }
      });

      if (maxMalicious > maxSuspicious) {
        linkscore = 1;
      } else if (maxMalicious < maxSuspicious) {
        linkscore = 0.5;
      } else if (maxMalicious == maxSuspicious) {
        linkscore = 1;
        if (maxMalicious == 0 && maxSuspicious == 0) {
          linkscore = 0;
        }
      }
    } else if (res?.attributes["last_analysis_stats"] == null) {
      linkscore = 0;
    }

    type = res?.attributes["categories"]["Webroot"];
    type ??= res?.attributes["categories"]["Forcepoint ThreatSeeker"];
    type ??= "Unkown";
    debugPrint("last_analysis_stats : $type");
  }

  double? predic;
  Future<double> prediction(String text, String link, String msg) async {
    predic = 0;
    double score = 0;
    // linkscore = 1; //test
    // print("linkscore : $linkscore");
    if (text == "Text" && link.isNotEmpty) {
      score = linkscore * 100;
      predic = 0;
      model = "link";
      // print("Predic 1: $text || $model || $linkscore || Total predic: $score");
    } else if (text.toString().isNotEmpty && link.isEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await _classifier.classify(
            tokenize, "en_ta_gru_w2v.tflite", 'en_ta_w2v_vocab.txt', 79);
        score = (predic! * 100);
        // print("Predic 2: $text || $model || $linkscore || Total predic: $score");
      }
      if (model == "thai") {
        predic = await _classifier.classify(
            tokenize, "th_lstm_grid.tflite", 'thai_vocab.txt', 109);
        score = predic! * 100;
        // print("Predic 3: $text || $model || $linkscore || Total predic: $score");
      }
    } else if (text.toString().isNotEmpty && link.isNotEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await _classifier.classify(
            tokenize, "en_ta_gru_w2v.tflite", 'en_ta_w2v_vocab.txt', 79);
        score = (predic! * 50) + (linkscore * 50);
        // print("Predic 4: $text || $model || $linkscore || Total predic: $score");
      }
      if (model == "thai") {
        predic = await _classifier.classify(
            tokenize, "th_lstm_grid.tflite", 'thai_vocab.txt', 109);
        score = (predic! * 50) + (linkscore * 50);
        // print("Predic 5: $text || $model || $linkscore || Total predic: $score");
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= const Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        if (isExitWarning) {
          const message = 'Press back again to exit';
          showToast(message,
              // ignore: use_build_context_synchronously
              context: context,
              animation: StyledToastAnimation.fade,
              reverseAnimation: StyledToastAnimation.fade,
              curve: Curves.linear,
              reverseCurve: Curves.linear);
        } else {
          // Navigator.of(context).pop();
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: mainScreen,
              centerTitle: true,
              leading: IconButton(
                  icon: const Icon(Icons.density_medium /*Icons.dehaze*/,
                      color: Colors.white),
                  onPressed: () {
                    if (_scaffoldkey.currentState?.isDrawerOpen == false) {
                      _scaffoldkey.currentState?.openDrawer();
                    } else {
                      _scaffoldkey.currentState?.openEndDrawer();
                    }
                  }),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                )
              ]),
          body: Scaffold(
              backgroundColor: bgYellow,
              key: _scaffoldkey,
              drawer: navBar(),
              body: SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(children: [
                        Container(
                          constraints: const BoxConstraints.expand(height: 50),
                          decoration: ShapeDecoration(
                              color: const Color(0xFFF7F7F9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: AdvancedSegment(
                            controller: _selectedSegment,
                            segments: const {
                              'all': 'All SMS',
                              'fraud': 'Fraud SMS',
                            },
                            backgroundColor: const Color(0xFFF7F7F9),
                            activeStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            inactiveStyle:
                                const TextStyle(color: Color(0xFFB2B7BE)),
                            sliderColor: Colors.white,
                          ),
                        ),
                        SingleChildScrollView(
                            child: RefreshIndicator(
                                onRefresh: reload,
                                child: Container(
                                    height: 550,
                                    margin: const EdgeInsets.only(
                                        top: 20, bottom: 20),
                                    decoration: ShapeDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(21))),
                                    child: ValueListenableBuilder<String>(
                                        valueListenable: _selectedSegment,
                                        builder: (_, key, __) {
                                          switch (key) {
                                            case 'all':
                                              return allSMS(_messages);
                                            case 'fraud':
                                              return fraudSMS(_messages);
                                            default:
                                              return const SizedBox();
                                          }
                                        }))))
                      ]))))),
    );
  }

  Widget allSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty && messageModels.isEmpty) {
      return Stack(children: [
        ListView(),
        const Center(
            child: Text("No message", style: TextStyle(fontFamily: "Kanit")))
      ]);
    }
    if (messageModels.isNotEmpty) {
      debugPrint("มีข้อมูล: ${messageModels.length} คน");
      return ListView.builder(
        shrinkWrap: true,
        itemCount: messageModels.length,
        itemBuilder: (context, index) {
          var count = messageModels[index].messages.length - 1;
          return ListTile(
            // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
            title: Text(messageModels[index].name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(messageModels[index].messages[0].body,
                style: const TextStyle(fontFamily: "Kanit"),
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
                  child: messageModels[index].photo.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            Uint8List.fromList(messageModels[index].photo),
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          "assets/images/profile.png",
                          fit: BoxFit.fitWidth,
                        )),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: messageModels[index].messages[0].state == 0
                      ? Container()
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: ShapeDecoration(
                              color:
                                  messageModels[index].messages[count].state ==
                                          1
                                      ? const Color(0xFFFCE205)
                                      : const Color(0xFFFF2F00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100))),
                          child: const Center(
                              child: Icon(
                                  color: Colors.white,
                                  Icons.priority_high,
                                  size: 18))))
            ]),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => ShowMsg(
                            messageModel: messageModels[index],
                            listMessage: messageModels,
                          )));
            },
          );
        },
      );
    }
    return FutureBuilder(
      future: getJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              alignment: Alignment.center,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("loading...",
                        style: TextStyle(fontFamily: "Kanit", fontSize: 15)),
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(mainScreen)))
                  ]));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: messageModels.length,
          itemBuilder: (context, index) {
            var count = messageModels[index].messages.length - 1;
            return ListTile(
              // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
              title: Text(messageModels[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(messageModels[index].messages[0].body,
                  style: const TextStyle(fontFamily: "Kanit"),
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
                    child: messageModels[index].photo.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              Uint8List.fromList(messageModels[index].photo),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            "assets/images/profile.png",
                            fit: BoxFit.fitWidth,
                          )),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: messageModels[index].messages[0].state == 0
                        ? Container()
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                                color: messageModels[index]
                                            .messages[count]
                                            .state ==
                                        1
                                    ? const Color(0xFFFCE205)
                                    : const Color(0xFFFF2F00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100))),
                            child: const Center(
                                child: Icon(
                                    color: Colors.white,
                                    Icons.priority_high,
                                    size: 18))))
              ]),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ShowMsg(
                              messageModel: messageModels[index],
                              listMessage: messageModels,
                            )));
              },
            );
          },
        );
      },
    );
  }

  Widget fraudSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty && messageModels.isEmpty) {
      return Stack(
        children: [
          ListView(),
          const Center(
            child: Text("No message", style: TextStyle(fontFamily: "Kanit")),
          )
        ],
      );
    }
    if (messageModels.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: messageModels.length,
        itemBuilder: (context, index) {
          var count = 0;
          if (messageModels[index].messages[count].state != 0) {
            return ListTile(
              // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
              title: Text(messageModels[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(messageModels[index].messages[0].body,
                  style: const TextStyle(fontFamily: "Kanit"),
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
                    child: messageModels[index].photo.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              Uint8List.fromList(messageModels[index].photo),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            "assets/images/profile.png",
                            fit: BoxFit.fitWidth,
                          )),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: messageModels[index].messages[0].state == 0
                        ? Container()
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                                color: messageModels[index]
                                            .messages[count]
                                            .state ==
                                        1
                                    ? const Color(0xFFFCE205)
                                    : const Color(0xFFFF2F00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100))),
                            child: const Center(
                                child: Icon(
                                    color: Colors.white,
                                    Icons.priority_high,
                                    size: 18))))
              ]),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ShowMsg(
                              messageModel: messageModels[index],
                              listMessage: messageModels,
                            )));
              },
            );
          } else {
            return Container();
          }
        },
      );
    }
    return FutureBuilder(
      future: getJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "loading...",
                    style: TextStyle(fontFamily: "Kanit"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(mainScreen),
                    ),
                  ),
                ],
              ));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: messageModels.length,
          itemBuilder: (context, index) {
            var count = messageModels[index].messages.length - 1;
            if (messageModels[index].messages[count].state != 0) {
              return ListTile(
                // tileColor: message.isRead == false ? const Color(0xFFCDE9FF) : null,
                title: Text(messageModels[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(messageModels[index].messages[0].body,
                    style: const TextStyle(fontFamily: "Kanit"),
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
                      child: messageModels[index].photo.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                Uint8List.fromList(messageModels[index].photo),
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              "assets/images/profile.png",
                              fit: BoxFit.fitWidth,
                            )),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: messageModels[index].messages[0].state == 0
                          ? Container()
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                  color: messageModels[index]
                                              .messages[count]
                                              .state ==
                                          1
                                      ? const Color(0xFFFCE205)
                                      : const Color(0xFFFF2F00),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100))),
                              child: const Center(
                                  child: Icon(
                                      color: Colors.white,
                                      Icons.priority_high,
                                      size: 18))))
                ]),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ShowMsg(
                                messageModel: messageModels[index],
                                listMessage: messageModels,
                              )));
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget navBar() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Manu',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'Inter')),
          ),
          ListTile(
              leading:
                  FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
              title: Text('Message', style: textBar),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => Allsms(
                              listMessage: widget.listMessage,
                            )));
              }),
          ListTile(
            leading: FaIcon(UniconsLine.user, size: 20, color: grayBar),
            title: Text('Account', style: textBar),
            onTap: () {
              Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: AccPage(listMessage: messageModels)));
            },
          ),
          ListTile(
              leading: FaIcon(UniconsLine.filter, size: 20, color: grayBar),
              title: Text('Messages Filter', style: textBar),
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: FilterPage(listMessage: messageModels)));
              }),
          Container(height: 2, color: const Color(0xFFCFCFCF)),
          const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                      fontSize: 14,
                      fontFamily: 'Inter'))),
          ListTile(
            leading: Icon(FeatherIcons.settings, size: 20, color: grayBar),
            title: Text('Settings', style: textBar),
            onTap: () {
              Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: SettingPage('',listMessage: messageModels,)));
            }
          ),
          Container(height: 2, color: const Color(0xFFCFCFCF)),
          ListTile(
            leading: const Icon(FeatherIcons.logOut,
                size: 20, color: Color(0xFFD55F5A)),
            title: const Text(
              'Logout',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD55F5A),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  height: 0.10,
                  letterSpacing: -0.28),
            ),
            onTap: () async {
              final providers =
                  FirebaseAuth.instance.currentUser!.providerData[0].providerId;
              print(FirebaseAuth.instance.currentUser!.providerData);
              AuthMethods().signOut(providers);
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
