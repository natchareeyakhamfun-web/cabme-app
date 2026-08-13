class DiscountListModel {
  String? success;
  String? error;
  String? message;
  List<DiscountData>? data;

  DiscountListModel({this.success, this.error, this.message, this.data});

  DiscountListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DiscountData>[];
      json['data'].forEach((v) {
        data!.add(DiscountData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DiscountData {
  String? id;
  String? code;
  String? discount;
  String? type;
  String? discription;
  String? couponType;
  String? expireAt;
  String? statut;
  String? creer;
  String? modifier;
  String? deletedAt;

  DiscountData(
      {this.id,
        this.code,
        this.discount,
        this.type,
        this.discription,
        this.couponType,
        this.expireAt,
        this.statut,
        this.creer,
        this.modifier,
        this.deletedAt});

  DiscountData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    discount = json['discount'];
    type = json['type'];
    discription = json['discription'];
    couponType = json['coupon_type'];
    expireAt = json['expire_at'];
    statut = json['statut'];
    creer = json['creer'];
    modifier = json['modifier'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['discount'] = discount;
    data['type'] = type;
    data['discription'] = discription;
    data['coupon_type'] = couponType;
    data['expire_at'] = expireAt;
    data['statut'] = statut;
    data['creer'] = creer;
    data['modifier'] = modifier;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
