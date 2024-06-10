import 'package:appbeebuzz/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ChipPosition { above, below }

class ChipTags extends StatefulWidget {
  const ChipTags({
    super.key,
    this.iconColor,
    this.chipColor,
    this.textColor,
    this.decoration,
    this.keyboardType,
    this.separator,
    this.createTagOnSubmit = false,
    this.chipPosition = ChipPosition.below,
    required this.list,
    required this.inputController,
  });

  final Color? iconColor;
  final Color? chipColor;
  final Color? textColor;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final String? separator;
  final List<dynamic> list;
  final ChipPosition chipPosition;
  final bool createTagOnSubmit;
  final TextEditingController inputController;

  @override
  State<ChipTags> createState() => _ChipTagsState();
}

class _ChipTagsState extends State<ChipTags>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///Form key for TextField
  final _formKey = GlobalKey<FormState>();
  late bool visible;

  @override
  void initState() {
    visible = false;
    visibleState();

    super.initState();
  }

  visibleState() {
    if (widget.inputController.text.isEmpty) {
      setState(() {
        visible = false;
      });
      print("สถานะ isEmpty $visible");
    }
    if (widget.inputController.text.isNotEmpty) {
      setState(() {
        visible = true;
      });
      print("${widget.inputController.text} สถานะ isNotEmpty $visible");
    }
  }

  List<dynamic>? listKeyword;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
                visible: widget.chipPosition == ChipPosition.above,
                child: _chipListPreview()),
            textFormField(),
            Visibility(
                visible: widget.chipPosition == ChipPosition.below,
                child: _chipListPreview()),
          ],
        ),
        Visibility(visible: visible == false, child: _info()),
        Visibility(visible: visible == true, child: _info2()),
      ],
    );
  }

  Widget _info() {
    return const Positioned(
        top: 250,
        child: Column(children: [
          Text("Messages Filter",
              style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 10),
          Text("Filter message out with words you don't want to see",
              style: TextStyle(
                  fontFamily: "Kanit",
                  color: Color(0xFF636363),
                  fontSize: 14,
                  fontWeight: FontWeight.w400))
        ]));
  }

  Widget _info2() {
    return Positioned(
        top: 250,
        child: Row(
          children: [
            const Text("Press",
                style: TextStyle(
                    fontFamily: "Inter",
                    color: Color(0xFF636363),
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.expand(height: 25, width: 25),
                decoration: ShapeDecoration(
                    color: const Color(0xB951D968),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
                child: Text(String.fromCharCode(Icons.check.codePoint),
                    style: TextStyle(
                      inherit: false,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: Icons.check.fontFamily,
                    ))),
            const Text(
              "to add keyword",
              style: TextStyle(
                  fontFamily: "Inter",
                  color: Color(0xFF636363),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ));
  }

  Widget textFormField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            // margin: const EdgeInsets.only(right: 10),
            width: 290,
            height: 50,
            child: TextField(
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              controller: widget.inputController,
              style: const TextStyle(
                  fontFamily: "Kanit",
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Color(0xFF636363)),
              decoration: widget.decoration ??
                  InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(left: 10, bottom: 0, top: 0),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(9)),
                    // hintText: "Separate Tags with '${widget.separator ?? 'space'}'",
                    // hintStyle: const TextStyle(
                    //     fontFamily: "kanit",
                    //     color: Color(0xFF636363),
                    //     fontSize: 16),
                  ),
              keyboardType: widget.keyboardType ?? TextInputType.text,
              textInputAction: TextInputAction.done,
              focusNode: _focusNode,
              onSubmitted: widget.createTagOnSubmit
                  ? (value) async {
                      widget.list.add(value);
                      await firestore.collection("users").doc(user!.uid).set(
                          {'filter': widget.list},
                          SetOptions(merge: true)).then((value) {});
                      widget.inputController.clear();
                      _formKey.currentState!.reset();
                      setState(() {});
                      _focusNode.requestFocus();
                    }
                  : null,
              onChanged: widget.createTagOnSubmit
                  ? null
                  : (value) async {
                      visibleState();
                      if (widget.inputController.text.isNotEmpty) {
                        if (value.endsWith(widget.separator ?? " ")) {
                          if (value != widget.separator &&
                              !widget.list.contains(value.trim())) {
                            widget.list.add(value
                                .replaceFirst(widget.separator ?? " ", '')
                                .trim());
                            await firestore
                                .collection("users")
                                .doc(user!.uid)
                                .set({'filter': widget.list},
                                    SetOptions(merge: true)).then((value) {});
                          }
                          widget.inputController.clear();
                          _formKey.currentState!.reset();
                          setState(() {
                            visible = false;
                          });
                        }
                      }
                    },
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.expand(height: 32, width: 40),
            decoration: ShapeDecoration(
                color: const Color(0xB951D968),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9))),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                // backgroundColor: Colors.white.withOpacity(0),
              ),
              child: Text(
                String.fromCharCode(Icons.check.codePoint),
                textAlign: TextAlign.center,
                style: TextStyle(
                  inherit: false,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: Icons.check.fontFamily,
                ),
              ),
              onPressed: () async {
                print(widget.list);
                var value = widget.inputController.text;
                if (value.isNotEmpty) {
                  if (widget.createTagOnSubmit) {
                    return;
                  }
                  if (value != widget.separator &&
                      !widget.list.contains(value.trim())) {
                    widget.list.add(value);
                    await firestore.collection("users").doc(user!.uid).set(
                        {'filter': widget.list},
                        SetOptions(merge: true)).then((value) {});
                  }
                  widget.inputController.clear();
                  _formKey.currentState!.reset();
                  setState(() {
                    visible = false;
                  });
                  print("สถานะ isEmpty $visible");
                }
              },
            ))
      ],
    );
  }

  Widget _chipListPreview() {
    // print(widget.list);
    return Container(
      // color: Colors.white.withOpacity(0.7),
      height: 180,
      child: SingleChildScrollView(
        child: Visibility(
          //if length is 0 it will not occupie any space
          visible: widget.list.length > 0,
          child: Wrap(
            children: widget.list
                .map((text) {
                  return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FilterChip(
                          shape: const StadiumBorder(
                              side: BorderSide(style: BorderStyle.none)),
                          backgroundColor: widget.chipColor ?? Colors.blue,
                          label: Text(
                            text,
                            style: TextStyle(
                                fontFamily: "Kanit",
                                fontWeight: FontWeight.normal,
                                color: widget.textColor ?? Colors.white,
                                fontSize: 16),
                          ),
                          deleteIcon: Text(
                            String.fromCharCode(Icons.close.codePoint),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              inherit: false,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              fontFamily: Icons.close.fontFamily,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          onDeleted: () async {
                            widget.list.remove(text);
                            await firestore
                                .collection("users")
                                .doc(user!.uid)
                                .set({'filter': widget.list},
                                    SetOptions(merge: true)).then((value) {});
                            setState(() {});
                          },
                          onSelected: (_) {}));
                })
                .toList()
                .reversed
                .toList(),
          ),
        ),
      ),
    );
  }
}
