import 'package:appbeebuzz/constant.dart';
import 'package:appbeebuzz/pages/allSMS.dart';
import 'package:appbeebuzz/style.dart';
import 'package:appbeebuzz/widgets/chip_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController filterController = TextEditingController();
  late TextEditingController _inputController;

  List<dynamic> _myList = [];

  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    _inputController = TextEditingController();
    getList();
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  getList() async {
    if (user != null) {
      _myList = [];
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      final snapshot = await users.doc(user!.uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _myList = data['filter'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_myList);
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
          child: ChipTags(
            inputController: _inputController,
            list: _myList,
            createTagOnSubmit: false,
            separator: " ",
            chipColor: const Color(0xFFFCE205),
            iconColor: Colors.white,
            textColor: Colors.white,
            keyboardType: TextInputType.text,
            chipPosition: ChipPosition.below,
          ),
        ),
      ),
    );
  }

  // getList(List<String> list){
  //   setState(() {

  //   });
  // }
}
