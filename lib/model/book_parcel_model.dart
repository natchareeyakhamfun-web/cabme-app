class BookParcelModel {
  String? userId;
  String? lat1;
  String? lng1;
  String? lat2;
  String? lng2;
  String? sourceCity;
  String? destinationCity;
  String? distance;
  String? distanceUnit;
  String? idPayment;
  String? sourceAdrs;
  String? destinationAdrs;
  String? senderName;
  String? receiverName;
  String? senderPhone;
  String? receiverPhone;
  String? note;
  String? parcelWeight;
  String? parcelDimension;
  String? parcelType;
  String? parcelDate;
  String? parcelTime;
  String? receiveDate;
  String? receiveTime;
  String? amount;
  String? duration;

  BookParcelModel(
      {this.userId,
      this.lat1,
      this.lng1,
      this.lat2,
      this.lng2,
      this.sourceCity,
      this.destinationCity,
      this.distance,
      this.distanceUnit,
      this.idPayment,
      this.sourceAdrs,
      this.destinationAdrs,
      this.senderName,
      this.receiverName,
      this.senderPhone,
      this.receiverPhone,
      this.note,
      this.parcelWeight,
      this.parcelDimension,
      this.parcelType,
      this.parcelDate,
      this.parcelTime,
      this.receiveDate,
      this.receiveTime,
      this.amount,
      this.duration});

  BookParcelModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    lat1 = json['lat1'];
    lng1 = json['lng1'];
    lat2 = json['lat2'];
    lng2 = json['lng2'];
    sourceCity = json['source_city'];
    destinationCity = json['destination_city'];
    distance = json['distance'];
    distanceUnit = json['distance_unit'];
    idPayment = json['id_payment'];
    sourceAdrs = json['source_adrs'];
    destinationAdrs = json['destination_adrs'];
    senderName = json['sender_name'];
    receiverName = json['receiver_name'];
    senderPhone = json['sender_phone'];
    receiverPhone = json['receiver_phone'];
    note = json['note'];
    parcelWeight = json['parcel_weight'];
    parcelDimension = json['parcel_dimension'];
    parcelType = json['parcel_type'];
    parcelDate = json['parcel_date'];
    parcelTime = json['parcel_time'];
    receiveDate = json['receive_date'];
    receiveTime = json['receive_time'];
    amount = json['amount'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['lat1'] = lat1;
    data['lng1'] = lng1;
    data['lat2'] = lat2;
    data['lng2'] = lng2;
    data['source_city'] = sourceCity;
    data['destination_city'] = destinationCity;
    data['distance'] = distance;
    data['distance_unit'] = distanceUnit;
    data['id_payment'] = idPayment;
    data['source_adrs'] = sourceAdrs;
    data['destination_adrs'] = destinationAdrs;
    data['sender_name'] = senderName;
    data['receiver_name'] = receiverName;
    data['sender_phone'] = senderPhone;
    data['receiver_phone'] = receiverPhone;
    data['note'] = note;
    data['parcel_weight'] = parcelWeight;
    data['parcel_dimension'] = parcelDimension;
    data['parcel_type'] = parcelType;
    data['parcel_date'] = parcelDate;
    data['parcel_time'] = parcelTime;
    data['receive_date'] = receiveDate;
    data['receive_time'] = receiveTime;
    data['amount'] = amount;
    data['duration'] = duration;
    return data;
  }
}
