// import 'package:beebuzz/constant.dart';
import 'package:flutter/material.dart';

class InputFormField extends StatefulWidget {
  const InputFormField(
      {super.key,
      required this.textHint,
      required this.obscure,
      required this.type,
      required this.controller});

  final String textHint;
  final bool obscure;
  final String type;
  final TextEditingController controller;

  @override
  State<InputFormField> createState() => InputFormFieldState();
}

class InputFormFieldState extends State<InputFormField> {
  Icon? getIcon(String type) {
    switch (type) {
      case 'email':
        return const Icon(Icons.email, color: Colors.black45);
      case 'key':
        return const Icon(Icons.vpn_key, color: Colors.black45);
      case 'user':
        return const Icon(Icons.person, color: Colors.black45);
      case 'phone':
        return const Icon(Icons.phone_android, color: Colors.black45);
      default:
        return null;
    }
  }

  TextInputType? textType(String type) {
    switch (type) {
      case 'email':
        return TextInputType.emailAddress;
      case 'key':
        return TextInputType.text;
      case 'user':
        return TextInputType.text;
      case 'phone':
        return TextInputType.number;
      default:
        return null;
    }
  }

  Widget cerrectPhoneNumber(int length) {
    return length > 9
        ? Container(
                margin: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.green),
                child: const Icon(Icons.done , color: Colors.white, size: 20,),
              )
        : const SizedBox(
            width: 5,
            height: 5,
            // margin: const EdgeInsets.all(5),
            // decoration:
            //     const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            // child: const Icon(Icons.done),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: widget.controller,
        maxLength: 48,
        decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16)),
            hintText: widget.textHint,
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            prefixIcon: getIcon(widget.type),
            suffixIcon: widget.type == "phone"
                ? cerrectPhoneNumber(widget.controller.text.length)
                : null),
        keyboardType: TextInputType.emailAddress,
        onChanged: (val) {
          if (widget.type == "phone") {
            setState(() {
              widget.controller.text = val;
            });
          }
          return;
        },
        maxLines: 1,
        validator: (value) {
          if (widget.controller.text.isEmpty) {
            if (widget.type == "email") {
              return "Please input Email";
            }
            if (widget.type == "user") {
              return "Please input User Name";
            }
            if (widget.type == "phone") {
              return "Please input Phone Number";
            }
          }

          return null;
        },
      ),
    );
  }
}

class InputFormFieldPassword extends StatefulWidget {
  const InputFormFieldPassword(
      {super.key,
      required this.textHint,
      required this.obscure,
      required this.type,
      required this.controller});

  final String textHint;
  final bool obscure;
  final String type;
  final TextEditingController controller;

  @override
  State<InputFormFieldPassword> createState() => _InputFormFieldPasswordState();
}

class _InputFormFieldPasswordState extends State<InputFormFieldPassword> {
  late bool passenable;

  @override
  void initState() {
    passenable = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 12),
        child: TextFormField(
          controller: widget.controller,
          obscureText: passenable,
          maxLength: 48,
          decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16)),
              hintText: widget.textHint,
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
            if (widget.type == "password") {
              if (widget.controller.text.isEmpty) {
                return "Please Confirm Password";
              } else if (widget.controller.text.length < 6) {
                return "Please enter minimum 10 characters";
              }
            }
            if (widget.type == "cfpassword") {
              if (widget.controller.text.isEmpty) {
                return "Please Confirm Password";
              } else if (widget.controller.text.length < 6) {
                return "Please enter minimum 10 characters";
              }
            }
            return null;
          },
        ));
  }
}
