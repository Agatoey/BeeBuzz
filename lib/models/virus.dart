class VirusTotalModel {
  String? xNameAV;
  bool? xDetected;
  String? xResult;
  DateTime? createdDate;

  VirusTotalModel({
    required this.xNameAV,
    required this.xDetected,
    required this.xResult,
    required this.createdDate
  });
 
  String data() {
    return '${createdDate!.day.toString().padLeft(2,'0')}/${createdDate!.month.toString().padLeft(2,'0')}/${createdDate!.year.toString().padLeft(4,'0')}';
  }

  VirusTotalModel.fromJson(String nameAv, Map mapAv) {
    xNameAV = nameAv;
    xDetected = mapAv["detected"];
    xResult = mapAv["result"];
  }
  
}