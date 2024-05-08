import 'dart:async';
import 'package:appbeebuzz/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/pages/login.dart';

// void main() {
//   runApp(const Main());
// }

// class Main extends StatefulWidget {
//   const Main({super.key});

//   @override
//   State<Main> createState() => _MainState();
// }

// class _MainState extends State<Main> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(
//     const Duration(seconds: 3),
//     () => Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
//     ),
//   );

//   }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//       backgroundColor: const Color(0xFFFCE305),
//       body: const Center(
//         child: CircularProgressIndicator(),
//       )
//       // const Center(
//       //       child: Image(
//       //           image: AssetImage('assets/images/logos_transparent.png'),
//       //           height: 68,)),
//       );
// }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RunMyApp());
}

class RunMyApp extends StatelessWidget {
  const RunMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();

    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage())));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainScreen,
        body: const Center(
            child: Center(
                child: Image(
                    image: AssetImage('assets/images/Beebuzz-logos.png'),
                    height: 68))));
  }
}
