import 'package:appbeebuzz/models/virus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:json_pretty/json_pretty.dart';

class Data {
  final String xApiToken =
      '0d4b50c2d7d24ad44032b1eeea0fa7eda3c33b616134aadf99183e4a470b55e6';
  final String linkScanUrl = 'https://www.virustotal.com/api/v3/urls';
  final String linkScanUrlAnalysis =
      'https://www.virustotal.com/api/v3/analyses/';
  final String linkScanUrlAnalysisReport =
      'https://www.virustotal.com/api/v3/urls/';

  Future<Body?> xSendUrlScan(String urlScan) async {
    try {
      final response = await http.post(Uri.parse(linkScanUrl),
          headers: {'x-apikey': xApiToken}, body: {"url": urlScan});
      // print("URL : $urlScan");
      if (response.statusCode == 200) {
        // print("Respone :${response.body}");

        var data = json.decode(response.body);
        // print("Data = ${data["data"]["id"]}");

        final responseTwo = await http.get(
          Uri.parse(linkScanUrlAnalysis + data["data"]["id"]),
          headers: {'x-apikey': xApiToken},
        );

        if (responseTwo.statusCode == 200) {
          // var meta = json.decode(responseTwo.body);
          // print("Meta = ${meta["meta"]["url_info"]["id"]}");

          final responseSeconde = await http.get(
            Uri.parse(data["data"]["links"]["self"]),
            headers: {'x-apikey': xApiToken},
          );
          var meta = json.decode(responseSeconde.body);

          // print(meta["data"]["attributes"]);

          Body model = Body.fromJson(meta["data"]);
          if (data["data"] != null) {
            return model;
          } else {
            print("error!!!!");
          }
          // return responseSeconde;
        } else {
          throw ('An error occurred when requesting Posts');
        }
      } else {
        throw ('An error occurred when requesting Posts');
      }
    } catch (e) {
      print("Error : ${e.toString()}");
    }
    return null;
  }
}


// {
//   "data": {
//     "id": "90672acf2f5cafcae45c663fa7ab26d98bc9d846b7995d4fb941433f8e604e7a",
//     "type": "url",
//     "links": {
//       "self": "https://www.virustotal.com/api/v3/urls/90672acf2f5cafcae45c663fa7ab26d98bc9d846b7995d4fb941433f8e604e7a"
//     },
//     "attributes": {
//       "tld": "ly",
//       "tags": [
//         "multiple-redirects"
//       ],
//       "title": "LINE",
//       "url": "http://bit.ly/3Dac9eS",
//       "last_modification_date": 1714482024,
//       "trackers": {
//         "Google Tag Manager": [
//           {
//             "url": "//www.googletagmanager.com/gtm.js?id=' + i + dl",
//             "id": "GTM-TVHZDL",
//             "timestamp": 1714478063
//           }
//         ]
//       },
//       "last_http_response_code": 200,
//       "reputation": -1,
//       "categories": {
//         "BitDefender": "computersandsoftware",
//         "Xcitium Verdict Cloud": "web applications",
//         "Sophos": "information technology",
//         "Forcepoint ThreatSeeker": "web hosting"
//       },
//       "times_submitted": 3,
//       "first_submission_date": 1702001028,
//       "redirection_chain": [
//         "http://bit.ly/3Dac9eS",
//         "https://lin.ee/TqMLsev"
//       ],
//       "last_analysis_stats": {
//         "malicious": 2,
//         "suspicious": 0,
//         "undetected": 19,
//         "harmless": 71,
//         "timeout": 0
//       },
//       "last_analysis_date": 1714482010
//     }
//   }
// }