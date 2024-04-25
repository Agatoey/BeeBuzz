import 'package:appbeebuzz/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ChipPosition { above, below }

class ChipTags extends StatefulWidget {
  const ChipTags({
    Key? key,
    this.iconColor,
    this.chipColor,
    this.textColor,
    this.decoration,
    this.keyboardType,
    this.separator,
    this.createTagOnSubmit = false,
    this.chipPosition = ChipPosition.below,
    required this.list,
  }) : super(key: key);

  ///sets the remove icon Color
  final Color? iconColor;

  ///sets the chip background color
  final Color? chipColor;

  ///sets the color of text inside chip
  final Color? textColor;

  ///container decoration
  final InputDecoration? decoration;

  ///set keyboradType
  final TextInputType? keyboardType;

  ///customer symbol to seprate tags by default
  ///it is " " space.
  final String? separator;

  /// list of String to display
  final List<String> list;

  final ChipPosition chipPosition;

  /// Default `createTagOnSumit = false`
  /// Creates new tag if user submit.
  /// If true they separtor will be ignored.
  final bool createTagOnSubmit;

  @override
  _ChipTagsState createState() => _ChipTagsState();
}

class _ChipTagsState extends State<ChipTags>
    with SingleTickerProviderStateMixin {
  FocusNode _focusNode = FocusNode();

  ///Form key for TextField
  final _formKey = GlobalKey<FormState>();
  TextEditingController _inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
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
              controller: _inputController,
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
                  ? (value) {
                      widget.list.add(value);

                      ///setting the controller to empty
                      _inputController.clear();

                      ///resetting form
                      _formKey.currentState!.reset();

                      ///refersing the state to show new data
                      setState(() {});
                      _focusNode.requestFocus();
                    }
                  : null,
              onChanged: widget.createTagOnSubmit
                  ? null
                  : (value) {
                      ///check if user has send separator so that it can break the line
                      ///and add that word to list
                      if (value.endsWith(widget.separator ?? " ")) {
                        ///check for ' ' and duplicate tags
                        if (value != widget.separator &&
                            !widget.list.contains(value.trim())) {
                          widget.list.add(value
                              .replaceFirst(widget.separator ?? " ", '')
                              .trim());
                        }

                        ///setting the controller to empty
                        _inputController.clear();

                        ///resetting form
                        _formKey.currentState!.reset();

                        ///refersing the state to show new data
                        setState(() {});
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
              onPressed: () {
                print(widget.list);
                var value = _inputController.text;
                if (value.isNotEmpty) {
                  if (widget.createTagOnSubmit) {
                    return;
                  }
                  if (value != widget.separator &&
                      !widget.list.contains(value.trim())) {
                    widget.list.add(value);
                  }
                  _inputController.clear();
                  _formKey.currentState!.reset();
                  setState(() {});
                }
              },
            ))
      ],
    );
  }

  Visibility _chipListPreview() {
    return Visibility(
      //if length is 0 it will not occupie any space
      visible: widget.list.length > 0,
      child: Wrap(
        ///creating a list
        children: widget.list.map((text) {
          return Padding(
              padding: const EdgeInsets.all(5.0),
              child: FilterChip(
                  shape: const StadiumBorder(
                      side: BorderSide(style: BorderStyle.none)),
                  backgroundColor: widget.chipColor ?? Colors.blue,
                  label: Text(
                    text,
                    style: TextStyle(
                        color: widget.textColor ?? Colors.white, fontSize: 16),
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
                  onDeleted: () {
                    widget.list.remove(text);
                    setState(() {});
                  },
                  onSelected: (_) {}));
        }).toList(),
      ),
    );
  }
}
