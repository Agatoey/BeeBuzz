import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/login.dart';
import 'package:appbeebuzz/pages/otpReader.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/utils/auth_methods.dart';
import 'package:appbeebuzz/widgets/inputFormField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cfpasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  final FocusNode addressFocus = FocusNode();

  final _selectedSegment = ValueNotifier('email');

  final _formKey = GlobalKey<FormState>();
  final _phoneformKey = GlobalKey<FormState>();

  late bool passenable;
  late bool cfpassenable;

  late String errorText;

  @override
  void initState() {
    passenable = true;
    cfpassenable = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("Register", style: textHead),
          backgroundColor: mainScreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ),
        body: Scaffold(
          backgroundColor: bgYellow,
          body: Center(
            child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
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
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                            inactiveStyle:
                                const TextStyle(color: Color(0xFFB2B7BE)),
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
                                    return phoneNumber();
                                  default:
                                    return const SizedBox();
                                }
                              }))
                    ]))),
          ),
        ));
  }

  Widget email() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InputFormField(
              textHint: "User Name",
              obscure: false,
              type: "user",
              controller: userNameController),
          InputFormField(
              textHint: "Email",
              obscure: false,
              type: "email",
              controller: emailController),
          buildTextFieldPassword(),
          buildTextFieldPasswordConfirm(),
          buildButtonLogin("email"),
        ],
      ),
    );
  }

  Widget phoneNumber() {
    return Form(
      key: _phoneformKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InputFormField(
              textHint: "Phone Number",
              obscure: false,
              type: "phone",
              controller: phoneNumberController),
          buildButtonVerification(),
        ],
      ),
    );
  }

  Widget phoneOTP() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      InputFormField(
          textHint: "Phone Number",
          obscure: false,
          type: "phone",
          controller: phoneNumberController),
      Container(
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), color: mainScreen),
          child: TextButton(
              onPressed: () async {},
              child: const Center(
                  child: Text("Sign up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF7F7F9),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 0.17,
                      )))))
    ]);
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
                return "Please input Password";
              } else if (passwordController.text.length < 6) {
                return "Please input minimum 10 characters";
              }
              return null;
            }));
  }

  Widget buildTextFieldPasswordConfirm() {
    return Container(
        margin: const EdgeInsets.only(top: 12),
        child: TextFormField(
          controller: cfpasswordController,
          obscureText: cfpassenable,
          maxLength: 48,
          decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16)),
              hintText: "Confirm Password",
              filled: true,
              fillColor: const Color(0xFFF7F7F9),
              prefixIcon: const Icon(Icons.key, color: Colors.black45),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      if (cfpassenable) {
                        cfpassenable = false;
                      } else {
                        cfpassenable = true;
                      }
                    });
                  },
                  icon: Icon(
                      cfpassenable == true
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 15))),
          keyboardType: TextInputType.text,
          onChanged: (val) {},
          maxLines: 1,
          validator: (value) {
            if (cfpasswordController.text.isEmpty ||
                passwordController.text.isEmpty) {
              return "Please Confirm Password";
            } else if (cfpasswordController.text.length < 6) {
              return "Please Input minimum 10 characters";
            } else if (cfpasswordController.text != passwordController.text &&
                cfpasswordController.text.length >= 6) {
              return "Password not match";
            }
            return null;
          },
          focusNode: addressFocus,
          autofocus: false,
        ));
  }

  Widget buildButtonVerification() {
    return Container(
        margin: const EdgeInsets.only(top: 12),
        constraints: const BoxConstraints.expand(height: 50),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: mainScreen),
        child: TextButton(
            onPressed: () {
              _phoneformKey.currentState?.validate();
              phoneAuth();
            },
            child: const Center(
                child: Text("Send OTP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF7F7F9),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 0.17,
                    )))));
  }

  Widget buildButtonLogin(String type) {
    return Container(
        margin: const EdgeInsets.only(top: 12),
        constraints: const BoxConstraints.expand(height: 50),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: mainScreen),
        child: TextButton(
            onPressed: () async {
              if (type == "email") {
                _formKey.currentState?.validate();
              } else if (type == "phone") {
                _phoneformKey.currentState?.validate();
              }

              if (passwordController.text == cfpasswordController.text &&
                  passwordController.text.length >= 6) {
                await createUserWithEmailAndPassword();
              }
            },
            child: const Center(
                child: Text("Sign up",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF7F7F9),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 0.17,
                    )))));
  }

  Future<bool> checkPhoneNumberAlreadyUsed(String phoneNumber) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: phoneNumber)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> phoneAuth() async {
    try {
      String phoneNumber = phoneNumberController.text.trim();
      if (phoneNumber.startsWith('0') && phoneNumber.length == 10) {
        phoneNumber = '+66${phoneNumber.substring(1)}';
        debugPrint("1. phoneNumber: $phoneNumber");
      } else if (phoneNumber.startsWith('+66')) {
        if (phoneNumber.startsWith('+660')) {
          if (phoneNumber.length == 13) {
            phoneNumber = '+66${phoneNumber.substring(4)}';
            debugPrint("2. phoneNumber: $phoneNumber");
          } else {
            errrorText("Invalid format.", Colors.red[100]!);
          }
        } else if (phoneNumber.length == 12) {
          phoneNumber = phoneNumber;
          debugPrint("3. phoneNumber: $phoneNumber");
        } else {
          errrorText("Invalid format.", Colors.red[100]!);
        }
      }

      bool phoneNumberAlreadyUsed =
          await checkPhoneNumberAlreadyUsed(phoneNumber);
      debugPrint(phoneNumberAlreadyUsed.toString());
      if (phoneNumberAlreadyUsed == false) {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException ex) {
            throw Exception(ex.message);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          codeSent: (String verificationId, int? resendtoken) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OTPreader(
                          verificationId: verificationId,
                          phoneNumber: phoneNumber,
                        )));
          },
        );
      } else if (phoneNumberAlreadyUsed == true) {
        errrorText("Phone Number Already in Used", Colors.red[100]!);
      }
    } on FirebaseAuthException catch (e) {
      errrorText(e.message.toString(), Colors.red[100]!);
    }
  }

  createUserWithEmailAndPassword() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String userName = userNameController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty && userName.isNotEmpty) {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) async {
        await firestore.collection('users').doc(user.user?.uid).set({
          'username': userName,
          'uid': user.user?.uid,
          'profilePhoto':
              "https://cdn-icons-png.freepik.com/512/4945/4945750.png",
          'email': email,
          'providers': "password",
          'filter': []
        });
        user.user?.updateDisplayName(userName);
        user.user!.updatePhotoURL(
            'https://cdn-icons-png.freepik.com/512/4945/4945750.png');

        errrorText("Registration complete.", Colors.green[100]!);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
        debugPrint(
            "Sign up user successful ${AuthMethods().authChange.isEmpty}");
      }).catchError((error) {
        if (error.message ==
            "The email address is already in use by another account.") {
          errrorText("The email address is already in use by another account.",
              Colors.red[100]!);
        }
        if (error.message == "The email address is badly formatted.") {
          errrorText("The email address is badly formatted.", Colors.red[100]!);
        }
        debugPrint("Error : ${error.message}");
      });
    }
  }

  errrorText(String errortext, Color color) {
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
