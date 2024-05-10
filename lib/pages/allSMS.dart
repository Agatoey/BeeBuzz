import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:appbeebuzz/models/messages_model.dart';
import 'package:appbeebuzz/pages/accPage.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/pages/filterPage.dart';
import 'package:appbeebuzz/pages/showmsg.dart';
import 'package:appbeebuzz/service/getAPI.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:json_pretty/json_pretty.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicons/unicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class Allsms extends StatefulWidget {
  const Allsms({super.key});

  @override
  State<Allsms> createState() => _AllsmsState();
}

class _AllsmsState extends State<Allsms> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey();

  final SmsQuery _query = SmsQuery();

  Map<String, List> messagesBySender = {};
  List<SmsMessage> _messages = [];
  List<MessageModel> messageModels = [];

  bool isPress1 = true;
  final _selectedSegment = ValueNotifier('all');

  late String? model;

  List<dynamic>? filterTexts;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final int _sentenceLen = 79;
  final String start = '<START>';
  final String pad = '<PAD>';
  final String unk = '<UNKNOWN>';
  late Map<String, int> _dict;

  @override
  void initState() {
    isPress1 = true;
    roadSMSTest();
    getJson();
    model = "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  // TensorFlow Lite Interpreter object
  late tfl.Interpreter _interpreter;

  Future<bool> _loadModel(String modelFile) async {
    // Creating the interpreter using Interpreter.fromAsset
    // print('Interpreter loaded ${_interpreter.isAllocated}');
    _interpreter = await tfl.Interpreter.fromAsset('assets/models/$modelFile');
    // print('Interpreter loaded successfully ${_interpreter.isAllocated}');
    return _interpreter.isAllocated;
  }

  Future<bool> _loadDictionary(String vocabFile) async {
    final vocab = await rootBundle.loadString('assets/models/$vocabFile');
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    _dict = dict;
    // print('Dictionary loaded successfully');
    return _dict.isNotEmpty;
  }

  Future<double?> classify(
      String rawText, String modelFile, String vocabFile) async {
    bool res = await _loadModel(modelFile);
    if (res == true) {
      bool res2 = await _loadDictionary(vocabFile);
      if (res2 == true) {
        List<List<double>> input = tokenizeInputText(rawText);
        var output = List<double>.filled(1, 0).reshape([1, 1]);
        _interpreter.run(input, output);
        // print(input);
        return output[0][0];
      }
    }
    return null;
  }

  List<List<double>> tokenizeInputText(String text) {
    // Whitespace tokenization
    // print(text);
    final toks = text.split(' ');

    // final toks = [text];

    debugPrint("toks >>>>> $toks");

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<double>.filled(_sentenceLen, _dict[pad]!.toDouble());

    var index = 0;
    if (_dict.containsKey(start)) {
      vec[index++] = _dict[start]!.toDouble();
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in toks) {
      if (index > _sentenceLen) {
        break;
      }
      vec[index++] = _dict.containsKey(tok)
          ? _dict[tok]!.toDouble()
          : _dict[unk]!.toDouble();
    }

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    // print(vec);
    return [vec];
  }

  Future roadSMSTest() async {
    messagesBySender = {};
    _messages = [];
    var permission = await Permission.sms.request();
    if (!permission.isGranted) {
    } else {
      await Permission.contacts.request();
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox,
        ],
      );
      setState(() {
        _messages = messages;
      });

      await getListFilter();

      // debugPrint("Before Filter : ${_messages.length}");
      if (filterTexts!.isNotEmpty) {
        _messages.removeWhere((message) {
          for (var textFilter in filterTexts!) {
            if (message.body!.contains(textFilter)) {
              return true;
            }
          }
          return false;
        });
      } else if (filterTexts == null) {
        return _messages;
      }
      // debugPrint("After Fillter : ${_messages.length}");

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

  late String tokenize;

  Future<String?> selectModels(String sms) async {
    var res = await Data().selectmodel(sms);
    model = res!["model"].toString();
    tokenize = res["sms"].toString();
    print(tokenize);
    return model;
  }

  String? type;
  late double linkscore;

  getURLType(String linkbody) async {
    type = "";
    var res = await Data().xSendUrlScan(linkbody);

    if (res?.attributes["last_analysis_stats"] != null) {
      Map<String, dynamic> x;

      x = res?.attributes["last_analysis_stats"];
      print("last_analysis_stats : $x");

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
      print("Predic 1: $text || $link || $model || $linkscore");
    } else if (text.toString().isNotEmpty && link.isEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await classify(
            tokenize, "nlp_lstm_w2v.tflite", 'nlp_w2v_text_classification_vocab.txt');
        score = (predic! * 100);
        print("Predic 2: $text || $link || $model || $linkscore");
      }
      if (model == "thai") {
        predic = await classify(
            tokenize, "nlp_lstm_w2v.tflite", 'nlp_w2v_text_classification_vocab.txt');
        score = predic! * 100;
        print("Predic 3: $text || $link || $model || $linkscore");
      }
    } else if (text.toString().isNotEmpty && link.isNotEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await classify(
            tokenize, "nlp_lstm_w2v.tflite", 'nlp_w2v_text_classification_vocab.txt');
        score = (predic! * 50) + (linkscore * 50);
        print("Predic 4: $text || $link || $model || $linkscore");
      }
      if (model == "thai") {
        predic = await classify(
            tokenize, "nlp_lstm_w2v.tflite", 'nlp_w2v_text_classification_vocab.txt');
        score = (predic! * 50) + (linkscore * 50);
        print("Predic 5: $text || $link || $model || $linkscore");
      }
    }
    print("Total predic: $predic");
    return score;
  }

  // bool _isLink(String input) {
  //   final matcher = RegExp(
  //       r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
  //   return matcher.hasMatch(input);
  // }

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

          // print("Check: ${_isLink(msg.body).toString()}");

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

          print("text : $text");
          print("Link : $link");
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

          debugPrint("Model : $score | $predic | $link | $type | $linkscore | $state | $model");

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

          print("text : $text");
          print("Link : $link");
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

          debugPrint("Model : $score | $predic | $link | $type | $linkscore | $state | $model");

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
    // prettyPrintJson(messageModels.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                children: [
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
                          color: Colors.black, fontWeight: FontWeight.w600),
                      inactiveStyle: const TextStyle(color: Color(0xFFB2B7BE)),
                      sliderColor: Colors.white,
                    ),
                  ),
                  SingleChildScrollView(
                    child: RefreshIndicator(
                      onRefresh: roadSMSTest,
                      child: Container(
                        height: 550,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        decoration: ShapeDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21))),
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
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget allSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty) {
      return Stack(
        children: [
          ListView(),
          const Center(
            child: Text("No message", style: TextStyle(fontFamily: "Kanit")),
          )
        ],
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
                    style: TextStyle(fontFamily: "Kanit", fontSize: 15),
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
                    MaterialPageRoute(
                        builder: (context) => ShowMsg(
                              messages: messageModels[index].messages,
                              name: messageModels[index].name,
                            )));
              },
            );
          },
        );
      },
    );
  }

  Widget fraudSMS(List<SmsMessage> messages) {
    if (_messages.isEmpty) {
      return Stack(
        children: [
          ListView(),
          const Center(
            child: Text("No message", style: TextStyle(fontFamily: "Kanit")),
          )
        ],
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
                      MaterialPageRoute(
                          builder: (context) => ShowMsg(
                                messages: messageModels[index].messages,
                                name: messageModels[index].name,
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Allsms()));
              }),
          // ListTile(
          //     leading:
          //         FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
          //     title: Text('Contacts', style: textBar),
          //     onTap: () {
          //       Navigator.pushReplacement(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => const ContactsExample()));
          //     }),
          // ListTile(
          //     leading:
          //         FaIcon(FontAwesomeIcons.envelope, size: 20, color: grayBar),
          //     title: Text('Test', style: textBar),
          //     onTap: () {
          //       Navigator.pushReplacement(context,
          //           MaterialPageRoute(builder: (context) => const MyApp()));
          //     }),
          ListTile(
            leading: FaIcon(UniconsLine.user, size: 20, color: grayBar),
            title: Text('Account', style: textBar),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AccPage()));
            },
          ),
          ListTile(
              leading: FaIcon(UniconsLine.filter, size: 20, color: grayBar),
              title: Text('Messages Filter', style: textBar),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterPage()));
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
            onTap: () {},
          ),
          Container(height: 2, color: const Color(0xFFCFCFCF)),
          // ListTile(
          //     leading: Icon(FeatherIcons.helpCircle, size: 20, color: grayBar),
          //     title: Text('Help', style: textBar),
          //     onTap: () {}),
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
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
