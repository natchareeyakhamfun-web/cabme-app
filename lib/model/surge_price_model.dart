class SurgePriceModel {
  String? success;
  int? code;
  String? message;
  SurgePriceData? data;

  SurgePriceModel({this.success, this.code, this.message, this.data});

  SurgePriceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new SurgePriceData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SurgePriceData {
  int? surgeMultiplier;

  SurgePriceData({this.surgeMultiplier});

  SurgePriceData.fromJson(Map<String, dynamic> json) {
    surgeMultiplier = json['surge_multiplier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['surge_multiplier'] = this.surgeMultiplier;
    return data;
  }
}
