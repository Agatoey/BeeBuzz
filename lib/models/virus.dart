import 'dart:convert';

List<Body> parseBodys(String jsonStr) {
  final parsed = json.decode(jsonStr).cast<Map<String, dynamic>>();
  return parsed.map<Body>((json) => Body.fromJson(json)).toList();
}

List<Attributes> parseBody(String jsonStr) {
  final parsed = json.decode(jsonStr).cast<Map<String, dynamic>>();
  return parsed.map<Body>((json) => Body.fromJson(json)).toList();
}

class VirusTotalModel {
  VirusTotalModel({required this.data});

  List<Body> data;

  factory VirusTotalModel.fromJson(Map<String, dynamic> jSon) =>
      VirusTotalModel(data: parseBodys(json.encode(jSon["data"])));

  Map<String, dynamic> toJson() => {'data': data};
}

class Body {
  Body({required this.attributes, required this.date});

  List<Attributes> attributes;
  String date;

  factory Body.fromJson(Map<String, dynamic> jSon) =>
      Body(attributes: parseBody(json.encode(jSon["attributes"])), date: jSon["date"]);

  Map<String, dynamic> toJson() => {
        'attributes': attributes,
        'date': date
      };
}

class Attributes {
  Attributes({required this.categories, required this.linkbody});

  String categories;
  String linkbody;

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
      categories: json["categories"].toString(),
      linkbody: json["date"].toString());

  Map<String, dynamic> toJson() =>
      {'categories': categories, 'date': linkbody};
}

class Categories {
  Categories({required this.categories});

  String categories;

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
        categories: json["categories"].toString(),
      );

  Map<String, dynamic> toJson() => {
        'categories': categories,
      };
}
