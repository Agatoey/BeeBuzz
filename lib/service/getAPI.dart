import 'package:appbeebuzz/models/virus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Data {
  final String xApiToken =
      '0d4b50c2d7d24ad44032b1eeea0fa7eda3c33b616134aadf99183e4a470b55e6';
  final String xLinkScanUrl = 'https://www.virustotal.com/api/v3/urls';
  final String xLinkScanUrlReport =
      'ttps://www.virustotal.com/api/v3/analyses/';

  Future xSendUrlScan(String urlScan) async {
    final xResponse = await http.post(Uri.parse(xLinkScanUrl),
        body: {"apikey": "$xApiToken", "url": "$urlScan"});
    
    try {
      if (xResponse.statusCode == 200) {
      print(" respone :${xResponse.body}");
      // final Map xResultado = jsonDecode(xResponse.body);
      // final xResponseTwo = await http.post(Uri.parse(xLinkScanUrlReport),
      // body: {"apikey": "$xApiToken", "resource": xResultado["resource"]});
      // if (xResponseTwo.statusCode == 200) {
      //   final Map xResultado = jsonDecode(xResponseTwo.body);
      //   return List.generate(
      //       xResultado['scans'].length,
      //       (int index) => VirusTotalModel.fromJson(
      //           xResultado['scans'].keys.toList()[index],
      //           xResultado['scans'][xResultado['scans'].keys.toList()[index]]));
      // } else {
      //   //Erro
      //   throw ('Ocorreu um erro ao realizar o request dos Posts');
      // }
    } else {
      throw ('Ocorreu um erro ao realizar o request dos Posts');
    }
    } catch(e){
      print("Error : ${e.toString()}");
    }
  }
}
