import 'package:flutter/material.dart';
import 'package:appbeebuzz/models/virus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Data {
  
  // API For selectmodel
  Future<Map<String, dynamic>?> selectmodel(String sms) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('https://select-model-vjqykiu2ba-uc.a.run.app'));
      request.body = json.encode({"sms": sms});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(await response.stream.bytesToString());
        return json;
      } else {
        debugPrint("Error Selectmodel ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("Error : ${e.toString()}");
    }
    return null;
  }

  // API For Scan URL
  final String xApiToken = '0d4b50c2d7d24ad44032b1eeea0fa7eda3c33b616134aadf99183e4a470b55e6';
  final String linkScanUrl = 'https://www.virustotal.com/api/v3/urls';
  final String linkScanUrlAnalysis = 'https://www.virustotal.com/api/v3/analyses/';
  final String linkScanUrlAnalysisReport = 'https://www.virustotal.com/api/v3/urls/';

  Future<Body?> xSendUrlScan(String urlScan) async {
    try {
      final response = await http.post(Uri.parse(linkScanUrl),
          headers: {'x-apikey': xApiToken}, body: {"url": urlScan});
      if (response.statusCode == 200) {

        var data = json.decode(response.body);
        final responseTwo = await http.get(
          Uri.parse(linkScanUrlAnalysis + data["data"]["id"]),
          headers: {'x-apikey': xApiToken},
        );

        if (responseTwo.statusCode == 200) {
          var meta = json.decode(responseTwo.body);
          final responseSeconde = await http.get(
            Uri.parse(linkScanUrlAnalysisReport + "/" + meta["meta"]["url_info"]["id"]),
            headers: {'x-apikey': xApiToken});
            
          var res = json.decode(responseSeconde.body);

          Body model = Body.fromJson(res["data"]);
          if (data["data"] != null) {
            return model;
          } else {
            debugPrint("error!!!!");
          }
          return model;
        } else {
          throw ('An error occurred when requesting Posts');
        }
      } else {
        throw ('An error occurred when requesting Posts');
      }
    } catch (e) {
      debugPrint("Error : ${e.toString()}");
    }
    return null;
  }
}