import 'dart:convert';

List<VirusTotalModel> listFromjson(String str) => List<VirusTotalModel>.from(
    json.decode(str).map((x) => VirusTotalModel.fromJson(x)));

String companyToJson(List<VirusTotalModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VirusTotalModel {
  VirusTotalModel({required this.data});

  Body data;

  factory VirusTotalModel.fromJson(Map<String, dynamic> jSon) =>
      VirusTotalModel(data: Body.fromJson(jSon["data"]));

  Map<String, dynamic> toJson() => {'data': data.toJson()};
}

class Body {
  Body({
    required this.attributes,
    // required this.id
  });

  Map<String, dynamic> attributes;
  // String id;

  factory Body.fromJson(Map<String, dynamic> jSon) => Body(
        attributes: Map<String, dynamic>.from(jSon["attributes"]),
        // id: jSon["id"].toString()
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes,
        // "id": id
      };
}

// class Attributes {
//   Attributes({required this.categories});

//   Categories categories;

//   factory Attributes.fromJson(Map<String, dynamic> jSon) =>
//       Attributes(categories: Categories.fromJson(jSon["categories"]));

//   Map<String, dynamic> toJson() => {
//         'categories': categories.toJson(),
//       };
// }

// class Categories {
//   Categories({required this.bitDefender});

//   String bitDefender;

//   factory Categories.fromJson(Map<String, dynamic> json) => Categories(
//         bitDefender: json["BitDefender"].toString(),
//       );

//   Map<String, dynamic> toJson() => {
//         'BitDefender': bitDefender,
//       };
// }
