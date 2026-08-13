import 'dart:convert';

class BookingRequestModel {
  String? userId;
  String? latitudeDepart;
  String? longitudeDepart;
  String? latitudeArrivee;
  String? longitudeArrivee;
  String? departName;
  String? destinationName;
  String? duration;
  String? totalPeople;
  String? totalChildren;
  List<StopModel>? stops;
  String? distance;
  String? discountId;
  String? distanceUnit;
  String? subTotal;
  String? idPaymentMethod;
  String? vehicleTypeId;
  String? surgeMultiplier;

  BookingRequestModel(
      {this.userId,
        this.latitudeDepart,
        this.longitudeDepart,
        this.latitudeArrivee,
        this.longitudeArrivee,
        this.departName,
        this.destinationName,
        this.duration,
        this.discountId,
        this.totalPeople,
        this.totalChildren,
        this.stops,
        this.distance,
        this.distanceUnit,
        this.subTotal,this.idPaymentMethod,this.vehicleTypeId,this.surgeMultiplier});

  BookingRequestModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    latitudeDepart = json['latitude_depart'];
    longitudeDepart = json['longitude_depart'];
    latitudeArrivee = json['latitude_arrivee'];
    longitudeArrivee = json['longitude_arrivee'];
    departName = json['depart_name'];
    destinationName = json['destination_name'];
    duration = json['duration'];
    totalPeople = json['total_people'];
    totalChildren = json['total_children'];
    if (json['stops'] != null) {
      stops = <StopModel>[];
      json['stops'].forEach((v) {
        stops!.add(StopModel.fromJson(v));
      });
    }

    distance = json['distance'];
    distanceUnit = json['distance_unit'];
    subTotal = json['sub_total'];
    idPaymentMethod = json['id_payment'];
    vehicleTypeId = json['vehicle_type_id'];
    discountId = json['discount_id'];
    surgeMultiplier = json['surge_multiplier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['latitude_depart'] = latitudeDepart;
    data['longitude_depart'] = longitudeDepart;
    data['latitude_arrivee'] = latitudeArrivee;
    data['longitude_arrivee'] = longitudeArrivee;
    data['depart_name'] = departName;
    data['destination_name'] = destinationName;
    data['duration'] = duration;
    data['total_people'] = totalPeople;
    data['total_children'] = totalChildren;
    data['stops'] = jsonEncode(stops!.map((v) => v.toJson()).toList());
    data['distance'] = distance;
    data['distance_unit'] = distanceUnit;
    data['sub_total'] = subTotal;
    data['id_payment'] = idPaymentMethod;
    data['vehicle_type_id'] = vehicleTypeId;
    data['discount_id'] = discountId;
    data['surge_multiplier'] = surgeMultiplier;
    return data;
  }
}

class StopModel {
  String? latitude;
  String? longitude;
  String? location;

  StopModel({this.latitude, this.longitude, this.location});

  StopModel.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['location'] = location;
    return data;
  }
}
