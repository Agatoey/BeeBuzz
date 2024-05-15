import 'dart:async';
import 'dart:io';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/pages/settingPage.dart';
import 'package:appbeebuzz/pages/static.dart';
import 'package:appbeebuzz/service/getAPI.dart';
import 'package:appbeebuzz/utils/classify.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

int id = 0;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

const String navigationActionId = 'id_1';
const String navigationAugActionId = 'id_2';

void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: false, autoStart: true));
}

final FirebaseAuth _auth = FirebaseAuth.instance;
Stream<User?> get authChange => _auth.authStateChanges();

_MainState _main = _MainState();
User? user = FirebaseAuth.instance.currentUser;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized();

  final plugin = EasySmsReceiver.instance;
  plugin.listenIncomingSms(onNewMessage: (message) {
    _main = _MainState();
    print("ข้อความ:");
    print("::::::Message Address: ${message.address}");
    print("::::::Message body: ${message.body}");
    _main._showNotification(
        message.address.toString(), message.body.toString());
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String initialRoute = Main.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    initialRoute = Allsms.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          // print("tap");
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  user != null ? print(user!.displayName) : print("no login");

  if (user != null) {
    initializeService();
  }

  runApp(MaterialApp(
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        Main.routeName: (_) => const Main(),
        Allsms.routeName: (_) => Allsms(listMessage: [])
      }));
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class Main extends StatefulWidget {
  const Main({super.key});

  static const String routeName = '/';

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _notificationsEnabled = false;

  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  List<Permission> statuses = [
    Permission.sms,
    Permission.contacts,
    Permission.notification
  ];

  Future<void> requestPermission() async {
    try {
      for (var element in statuses) {
        if ((await element.status.isDenied ||
            await element.status.isPermanentlyDenied)) {
          await statuses.request();
        }
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      await requestPermission();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  // ignore: non_constant_identifier_names
  String? Address;
  // ignore: non_constant_identifier_names
  String? Body;

  Future<void> _showNotification(String address, String body) async {
    await splitText(body);
    String? name;
    var contacts;
    contacts = await ContactsService.getContactsForPhone(address);

    contacts.isEmpty ? name = address : name = contacts.first.displayName;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'id_1',
      'Notification',
      channelDescription: 'Notification SMS',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: "ic_launcher",
      largeIcon: DrawableResourceAndroidBitmap(largeIcon),
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(id++, name, body, notificationDetails, payload: 'item x');

    // Address = address;
    // print("Address >>> $Address");
  }

  void _configureSelectNotificationSubject() {
    // print("Address2 >>> $Address");
    selectNotificationStream.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => Allsms(listMessage: [],),
      ));
    });
  }

  double? predic;
  late String? model;
  String? type;
  late double linkscore;
  late String tokenize;
  late Classifier _classifier;
  var matches;
  late String link;
  late String text;
  late String largeIcon;

  splitText(String msg) async {
    link = '';
    text = '';
    print(msg);
    RegExp regExp = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    matches = regExp.allMatches(msg);
    for (final m in matches) {
      link = m[0];
      text = msg.replaceFirst(link, '');
    }

    late double score;
    if (link.isEmpty) {
      link = "";
      text = msg;
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

    score = await prediction(text, link, msg);

    if (score <= 30) {
      largeIcon = "greenstate";
    }
    if (score > 31 && score <= 70) {
      largeIcon = "yellostate";
    }
    if (score > 71) {
      largeIcon = "redstate";
    }
  }

  getURLType(String linkbody) async {
    type = "";
    var res = await Data().xSendUrlScan(linkbody);

    if (res?.attributes["last_analysis_stats"] != null) {
      Map<String, dynamic> x;

      x = res?.attributes["last_analysis_stats"];
      // ignore: avoid_print
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

  Future<String?> selectModels(String sms) async {
    var res = await Data().selectmodel(sms);
    model = res!["model"].toString();
    tokenize = res["sms"].toString();
    // ignore: avoid_print
    print(tokenize);
    return model;
  }

  Future<double> prediction(String text, String link, String msg) async {
    _classifier = Classifier();
    predic = 0;
    double score = 0;
    if (text == "Text" && link.isNotEmpty) {
      score = linkscore * 100;
      predic = 0;
      model = "link";
      print("Predic 1: $text || $model || $linkscore || Total predic: $score");
    } else if (text.toString().isNotEmpty && link.isEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await _classifier.classify(
            tokenize, "en_ta_gru_w2v.tflite", 'en_ta_w2v_vocab.txt', 79);
        score = (predic! * 100);
        print(
            "Predic 2: $text || $model || $linkscore || Total predic: $score");
      }
      if (model == "thai") {
        predic = await _classifier.classify(
            tokenize, "th_lstm_grid.tflite", 'thai_vocab.txt', 109);
        score = predic! * 100;
        print(
            "Predic 3: $text || $model || $linkscore || Total predic: $score");
      }
    } else if (text.toString().isNotEmpty && link.isNotEmpty) {
      model = await selectModels(msg);
      if (model == "english") {
        predic = await _classifier.classify(
            tokenize, "en_ta_gru_w2v.tflite", 'en_ta_w2v_vocab.txt', 79);
        score = (predic! * 50) + (linkscore * 50);
        print(
            "Predic 4: $text || $model || $linkscore || Total predic: $score");
      }
      if (model == "thai") {
        predic = await _classifier.classify(
            tokenize, "th_lstm_grid.tflite", 'thai_vocab.txt', 109);
        score = (predic! * 50) + (linkscore * 50);
        print(
            "Predic 5: $text || $model || $linkscore || Total predic: $score");
      }
    }
    return score;
  }

  @override
  void initState() {
    requestPermission();
    _requestPermissions();
    _isAndroidPermissionGranted();
    _configureSelectNotificationSubject();
    super.initState();

    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage())));
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: mainScreen,
          body: const Center(
              child: Center(
                  child: Image(
                      image: AssetImage('assets/images/Beebuzz-logos.png'),
                      height: 68)))),
    );
  }
}
