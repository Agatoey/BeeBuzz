import 'dart:convert';

List<VirusTotalModel> listFromjson(String str) => List<VirusTotalModel>.from(
    json.decode(str).map((x) => VirusTotalModel.fromJson(x)));

class VirusTotalModel {
  VirusTotalModel({required this.data});

  Body data;

  factory VirusTotalModel.fromJson(Map<String, dynamic> jSon) =>
      VirusTotalModel(data: Body.fromJson(jSon["data"]));

  Map<String, dynamic> toJson() => {'data': data.toJson()};
}

class Body {
  Body({required this.attributes});

  Map<String, dynamic> attributes;

  factory Body.fromJson(Map<String, dynamic> jSon) =>
      Body(attributes: Map<String, dynamic>.from(jSon["attributes"]));

  Map<String, dynamic> toJson() => {"attributes": attributes};
}