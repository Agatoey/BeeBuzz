import 'package:appbeebuzz/main.dart';
import 'package:appbeebuzz/pages/forgotpass.dart';
import 'package:appbeebuzz/pages/register.dart';
import 'package:appbeebuzz/widgets/inputFormField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? isChecked = false;
  late bool passenable;

  final AuthMethods _authMethods = AuthMethods();
  final _selectedSegment = ValueNotifier('email');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final _otpformKey = GlobalKey<FormState>();
  final _phoneKey = GlobalKey<FormState>();

  String errorString = "";
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  late double height;
  late double heighterror;
  late String provider;

  late String _verificationId;

  @override
  void initState() {
    passenable = true;
    _cancelAllNotifications();
    super.initState();
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthMethods().authChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // print("Here!!!");
            initializeService();
            return Allsms(
              listMessage: const [],
              filterTexts: const [],
            );
          } else {
            return newLogin();
          }
        });
  }

  Widget newLogin() {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bgYellow,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildLogo(),
                        loginGoogle(),
                        divider(),
                        loginSelect(),
                      ],
                    )),
              ),
              register()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Column(children: [
      Container(
          alignment: Alignment.topLeft,
          child: const Text('Welcome to',
              style: TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 0.09))),
      Container(
          margin: const EdgeInsets.only(top: 11),
          alignment: Alignment.topLeft,
          child: const Image(
              image: AssetImage('assets/images/Beebuzz-logo.png'), height: 30))
    ]);
  }

  Widget loginGoogle() {
    return Container(
        constraints: const BoxConstraints.expand(height: 45),
        margin: const EdgeInsets.only(top: 12),
        height: 45,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: const [
            BoxShadow(
              color: Color(0x1C000000),
              blurRadius: 15,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: SignInButton(
          text: "Continue with google",
          Buttons.google,
          onPressed: () async {
            bool res = await _authMethods.signInWithGoogle();
            if (res) {
              errrorText("Successfully signed in", Colors.green[100]!);
              await initializeService();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Allsms(
                            listMessage: const [],
                            filterTexts: const [],
                          )));
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
  }

  Widget divider() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: const Row(children: [
        Expanded(child: Divider(color: Color(0xFFBFBFBF), height: 36)),
        Padding(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Text("OR",
                style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.15))),
        Expanded(child: Divider(color: Color(0xFFBFBFBF), height: 36))
      ]),
    );
  }

  Widget email() {
    return Form(
      key: _formKey,
      child: Column(children: [
        InputFormField(
            textHint: "Email",
            obscure: false,
            type: "email",
            controller: emailController),
        buildTextFieldPassword(),
        isCheckbox(),
        buildButtonLogin("email")
      ]),
    );
  }

  Widget buildTextFieldPassword() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: passwordController,
        obscureText: passenable,
        maxLength: 48,
        decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16)),
            hintText: "Password",
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            prefixIcon: const Icon(Icons.key, color: Colors.black45),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    if (passenable) {
                      passenable = false;
                    } else {
                      passenable = true;
                    }
                  });
                },
                icon: Icon(
                    passenable == true
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 15))),
        keyboardType: TextInputType.text,
        onChanged: (val) {},
        maxLines: 1,
        validator: (value) {
          if (passwordController.text.isEmpty) {
            return "Please enter password.";
          } else if (passwordController.text.length < 6) {
            return "Please enter minimum 10 characters.";
          }
          return null;
        },
      ),
    );
  }

  Widget phonenumber() {
    return Column(
      children: [
        Form(
          key: _phoneKey,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: InputFormField(
                textHint: "Phone Number",
                obscure: false,
                type: "phone",
                controller: phoneNumberController),
          ),
        ),
        buildButtonSendOTP(),
        Form(
            key: _otpformKey,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: InputFormField(
                  textHint: "OTP Code",
                  obscure: false,
                  type: "otp",
                  controller: otpController),
            )),
        isCheckbox(),
        buildButtonLogin("phone")
      ],
    );
  }

  Widget isCheckbox() {
    return Container(
        // margin: const EdgeInsets.symmetric(vertical: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        // style: ButtonStyle.styleFrom(

        // ),
        child: const Text("Forgot Password?",
            style: TextStyle(
                color: Color(0xFFDB5757),
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 0.15)),
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const FogetPass()));
        },
      )
    ]));
  }

  Widget register() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Don’t have an account? ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 0.17,
          )),
      TextButton(
          style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text('Register',
              style: TextStyle(
                  color: Color(0xFFFCB605),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 0.17)),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Register()));
          })
    ]);
  }

  Widget loginSelect() {
    return Column(children: [
      Container(
          constraints: const BoxConstraints.expand(height: 40),
          margin: const EdgeInsets.only(top: 12),
          decoration: ShapeDecoration(
              color: const Color(0xFFF7F7F9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          child: AdvancedSegment(
            controller: _selectedSegment,
            segments: const {
              'email': 'Email',
              'phonenumber': 'Phone Number',
            },
            backgroundColor: const Color(0xFFF7F7F9),
            activeStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
            inactiveStyle: const TextStyle(color: Color(0xFFB2B7BE)),
            sliderColor: Colors.white,
          )),
      Container(
          decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21))),
          child: ValueListenableBuilder<String>(
              valueListenable: _selectedSegment,
              builder: (_, key, __) {
                switch (key) {
                  case 'email':
                    return email();
                  case 'phonenumber':
                    return phonenumber();
                  default:
                    return const SizedBox();
                }
              }))
    ]);
  }

  Future<bool> checkPhoneNumberAlreadyUsed(String phoneNumber) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: phoneNumber)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Widget buildButtonSendOTP() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        constraints: const BoxConstraints.expand(height: 40),
        decoration: ShapeDecoration(
            // color: phoneNumberController.text.trim().length != 10
            //     ? const Color(0xFFD7D7D7)
            //     : mainScreen,
            color: mainScreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: TextButton(
            child: const Center(
                child: Text("Send OTP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2E2E2E),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 0.17,
                    ))),
            onPressed: () async {
              _phoneKey.currentState?.validate();
              String phoneNumber = phoneNumberController.text.trim();
              if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
                debugPrint(phoneNumber.length.toString());
                phoneNumber = '+66${phoneNumber.substring(1)}';
              } else if (phoneNumber.startsWith('+66')) {
                if (phoneNumber.startsWith('+660')) {
                  if (phoneNumber.length == 13) {
                    debugPrint(phoneNumber.length.toString());
                    phoneNumber = '+66${phoneNumber.substring(4)}';
                  } else {
                    errrorText("Invalid format", Colors.red[100]!);
                  }
                } else if (phoneNumber.length == 12) {
                  debugPrint(phoneNumber.length.toString());
                  phoneNumber = phoneNumber;
                } else {
                  errrorText("Invalid format", Colors.red[100]!);
                }
              }
              bool phoneNumberAlreadyUsed =
                  await checkPhoneNumberAlreadyUsed(phoneNumber);
              if (phoneNumber.isNotEmpty && phoneNumberAlreadyUsed == true) {
                try {
                  await _auth.verifyPhoneNumber(
                    phoneNumber: phoneNumber.toString(),
                    timeout: const Duration(seconds: 1),
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                      await _auth.signInWithCredential(credential);
                    },
                    verificationFailed: (FirebaseAuthException ex) {
                      throw Exception(ex.message);
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {
                      setState(() {
                        _verificationId = verificationId;
                      });
                    },
                    codeSent: (String verificationId, int? resendtoken) {},
                  );
                } on FirebaseAuthException catch (e) {
                  errrorText(e.message.toString(), Colors.red[100]!);
                }
              } else if (phoneNumberAlreadyUsed == false &&
                  phoneNumber.isNotEmpty) {
                errrorText("This number doesn't exist.", Colors.red[100]!);
              }
            }));
  }

  Widget buildButtonLogin(String type) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      constraints: const BoxConstraints.expand(height: 40),
      decoration: ShapeDecoration(
          color: mainScreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: TextButton(
        child: const Center(
            child: Text("Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 0.17,
                ))),
        onPressed: () async {
          if (type == "phone") {
            _otpformKey.currentState?.validate();
          } else {
            _formKey.currentState?.validate();
          }
          await signIn();
        },
      ),
    );
  }

  signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((user) async {
        errrorText("${user.user!.displayName} : Successfully signed in",
            Colors.green[100]!);
      }).catchError((error) {
        if (error.message == "The email address is badly formatted.") {
          errrorText("The email address is badly formatted", Colors.red[100]!);
        }
        if (error.message ==
            "The supplied auth credential is incorrect, malformed or has expired.") {
          errrorText(
              "Your email address or password is incorrect.", Colors.red[100]!);
        }
        debugPrint(error.message);
      });
    }
    if (phoneNumber.isNotEmpty) {
      try {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otpController.text,
        );

        final User? user = (await _auth.signInWithCredential(credential)).user;
        errrorText("${user?.displayName} : Successfully signed in",
            Colors.green[100]!);
      } catch (e) {
        errrorText(e.toString(), Colors.red[100]!);
      }
    }
  }

  errrorText(String errortext, Color? color) {
    showToast(errortext,
        // ignore: use_build_context_synchronously
        context: context,
        textStyle: const TextStyle(color: Colors.black),
        backgroundColor: color,
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        curve: Curves.linear,
        reverseCurve: Curves.linear);
  }
}
