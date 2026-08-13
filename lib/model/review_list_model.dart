class ReviewModel {
  String? success;
  int? code;
  String? message;
  ReviewData? data;

  ReviewModel({this.success, this.code, this.message, this.data});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? ReviewData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ReviewData {
  String? id;
  String? userId;
  String? driverId;
  String? reviewFrom;
  String? reviewTo;
  String? bookingId;
  String? bookingType;
  String? comment;
  String? rating;
  String? createdAt;
  String? updatedAt;

  ReviewData(
      {this.id,
        this.userId,
        this.driverId,
        this.reviewFrom,
        this.reviewTo,
        this.bookingId,
        this.bookingType,
        this.comment,
        this.rating,
        this.createdAt,
        this.updatedAt});

  ReviewData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    driverId = json['driver_id'];
    reviewFrom = json['review_from'];
    reviewTo = json['review_to'];
    bookingId = json['booking_id'];
    bookingType = json['booking_type'];
    comment = json['comment'];
    rating = json['rating'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['driver_id'] = driverId;
    data['review_from'] = reviewFrom;
    data['review_to'] = reviewTo;
    data['booking_id'] = bookingId;
    data['booking_type'] = bookingType;
    data['comment'] = comment;
    data['rating'] = rating;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
