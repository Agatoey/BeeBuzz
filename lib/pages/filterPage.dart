import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/widgets/chip_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:material_tag_editor/tag_editor.dart';
// import 'package:google_fonts/google_fonts.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController filterController = TextEditingController();

  List<String> _myList = [];
  List<String> _myListCustom = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Messages Filter", style: textHead),
        backgroundColor: mainScreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Allsms()));
          },
        ),
      ),
      body: Scaffold(
        backgroundColor: bgYellow,
        body: Container(
            alignment: Alignment.topCenter,
            // margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ChipTags(
                  list: _myList,
                  createTagOnSubmit:
                      false, // flase ไม่ต้องกดเพื่อเพิ่ม ture ต้องกด submit
                  separator: " ",
                  chipColor: const Color(0xFFFCE205),
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  keyboardType: TextInputType.text,
                  chipPosition: ChipPosition.below,
                ),
                const Positioned(
                    top: 250,
                    child: Column(
                      children: [
                        Text("Messages Filter",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 10),
                        Text(
                          "สกรีนข้อความเบื้องต้น ด้วยคำที่คุณไม่อยากเห็น",
                          style: TextStyle(
                              fontFamily: "kanit",
                              color: Color(0xFF636363),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        // Text(
                        //   "สกรีนข้อความเบื้องต้น ด้วยคำที่คุณไม่อยากเห็น",
                        //   style: GoogleFonts.kanit(
                        //     textStyle: const TextStyle(
                        //         color: Color(0xFF636363),
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400),
                        //   ),
                        // ),
                      ],
                    ))
              ],
            )),
      ),
    );
  }

  Widget body() {
    return Scaffold(
      backgroundColor: bgYellow,
      body: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 250,
                child: TextField(
                  controller: filterController,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)),
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: Colors.white),
                  maxLines: 1,
                )),
            Container(
                constraints: const BoxConstraints.expand(height: 32, width: 40),
                decoration: ShapeDecoration(
                    color: const Color(0xB951D968),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () {},
                ))
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _values = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  List<String> _myList = [];
  // List<String> _myListCustom = [];

  _onDelete(index) {
    setState(() {
      _values.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: tagFile()),
    );
  }

  Widget tagFile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: ShapeDecoration(
            color: mainScreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: ListView(
          children: <Widget>[
            TagEditor(
              length: _values.length,
              controller: _textEditingController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.next,
              delimiters: const [',', ' '],
              hasAddButton: false,
              resetTextOnSubmitted: true,
              textStyle: const TextStyle(color: Colors.grey),
              onSubmitted: (outstandingValue) {
                setState(() {
                  _values.add(outstandingValue);
                });
              },
              inputDecoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                )),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                labelText: 'separate,  with,  commas',
                labelStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  backgroundColor: Color(0x65dffd02), // was Color(0xffDDFDFC),
                  color: Colors.black87, // was Color(0xffD82E6D),
                  fontSize: 14,
                ),
              ),
              onTagChanged: (newValue) {
                setState(() {
                  _values.add(newValue);
                });
              },
              tagBuilder: (context, index) => _Chip(
                index: index,
                label: _values[index],
                onDeleted: _onDelete,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[/\\]'))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tagTest() {
    return SingleChildScrollView(
        child: Container(
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 12.0,
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  'In just a few words, what are 3 positive things about dogs?', // was 'What are 3 good or positive things about the house, property or neighborhood?', //  [ 1 ​]
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            TextSpan(
                              text: '  (optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.italic,
                                fontSize: 14.0,
                                color: Colors.black54,
                              ), // was 'misleading or inaccurate?',
                            ),
                          ],
                        ),
                      ),
                      // BEGIN code from material_tag_editor
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TagEditor(
                          length: _values.length,
                          delimiters: [
                            ','
                          ], // was delimiters: [',', ' '],  Also tried "return" ('\u2386',)
                          hasAddButton: true,
                          textInputAction: TextInputAction
                              .next, // moves user from one field to the next!!!!
                          autofocus: false,
                          maxLines: 1,
                          // focusedBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(color: Colors.lightBlue),
                          //   borderRadius: BorderRadius.circular(20.0),
                          // ),
                          inputDecoration: const InputDecoration(
                            // below was "border: InputBorder.none,"
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                              // above is per https://github.com/flutter/flutter/issues/5191
                            ),
                            labelText: 'separate,  with,  commas',
                            labelStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              backgroundColor:
                                  Color(0x65dffd02), // was Color(0xffDDFDFC),
                              color: Colors.black87, // was Color(0xffD82E6D),
                              fontSize: 14,
                            ),
                          ),
                          onTagChanged: (newValue) {
                            setState(() {
                              _values.add(newValue);
                            });
                          },
                          tagBuilder: (context, index) => _Chip(
                            index: index,
                            label: _values[index],
                            onDeleted: _onDelete,
                          ),
                        ),
                      )
                    ]))));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: const Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
