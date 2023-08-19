class AnalyzeModel {
  String? result;
  String? color;

  AnalyzeModel({this.result, this.color});

  AnalyzeModel.fromJson(Map<String, dynamic> json) {
    result = json["result"];
    color = json["color"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["result"] = result;
    data["color"] = color;
    return data;
  }
}