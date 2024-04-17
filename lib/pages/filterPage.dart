import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController filterController = TextEditingController();

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
          padding: EdgeInsets.all(40),
          alignment: Alignment.topCenter,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 300,
                  height: 100,
                  child: TextField(
                    controller: filterController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0)),
                        hintText: 'หากมีมากกว่า 1 คำ ให้คั่นด้วยสัญลักษณ์ , หรือ /',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.white),
                    maxLines: 5,
                    minLines: 3,
                  )),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Container(
                  width: 300,
                  height: 40,
                  decoration: ShapeDecoration(
                      color: mainScreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: TextButton(
                      onPressed: () {},
                      child: const Center(
                        child: Text(
                          "Submit",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            height: 0.17,
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
