class ParcelCategoryModel {
  String? success;
  String? error;
  String? message;
  List<ParcelCategory>? data;

  ParcelCategoryModel({this.success, this.error, this.message, this.data});

  ParcelCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ParcelCategory>[];
      json['data'].forEach((v) {
        data!.add(ParcelCategory.fromJson(v));
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

class ParcelCategory {
  int? id;
  String? title;
  String? description;
  String? image;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  double? baseFare;
  String? pricingSource;
  String? matchedZoneId;
  String? matchedZoneName;
  double? perKmCharge;
  double? perKgCharge;

  ParcelCategory({
    this.id,
    this.title,
    this.description,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.baseFare,
    this.pricingSource,
    this.matchedZoneId,
    this.matchedZoneName,
    this.perKmCharge,
    this.perKgCharge,
  });

  factory ParcelCategory.fromJson(Map<String, dynamic> json) {
    return ParcelCategory(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      baseFare: double.parse(json['base_fare'].toString()),
      pricingSource: json['pricing_source'] ?? '',
      matchedZoneId: json['matched_zone_id'].toString(),
      matchedZoneName: json['matched_zone_name'] ?? '',
      perKmCharge: double.parse(json['per_km_charge'].toString()),
      perKgCharge: double.parse(json['per_kg_charge'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'base_fare': baseFare,
      'pricing_source': pricingSource,
      'matched_zone_id': matchedZoneId,
      'matched_zone_name': matchedZoneName,
      'per_km_charge': perKmCharge,
      'per_kg_charge': perKgCharge,
    };
  }
}
