import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/model/parcel_bokking_model.dart';
import 'package:cabme/model/rental_booking_model.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BookingController extends GetxController {
  RxBool isLoading = true.obs;
  RxString bookingType = "Ride Booking".obs;
  final LayerLink layerLink = LayerLink();
  GlobalKey overlayKey = GlobalKey();

  final List<String> types = [
    'Ride Booking',
    'Parcel Delivery',
    'Rental Cars',
  ];

  void selectType(String type) {
    bookingType.value = type;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getBookingList();
    isLoading.value = false;
    super.onInit();
  }

  RxList<BookingData> newList = <BookingData>[].obs;
  RxList<BookingData> onGoingList = <BookingData>[].obs;
  RxList<BookingData> completedList = <BookingData>[].obs;
  RxList<BookingData> cancelledList = <BookingData>[].obs;

  RxList<ParcelBookingData> newParcelList = <ParcelBookingData>[].obs;
  RxList<ParcelBookingData> onGoingParcelList = <ParcelBookingData>[].obs;
  RxList<ParcelBookingData> completedParcelList = <ParcelBookingData>[].obs;
  RxList<ParcelBookingData> cancelledParcelList = <ParcelBookingData>[].obs;

  RxList<RentalBookingData> newRentalList = <RentalBookingData>[].obs;
  RxList<RentalBookingData> onGoingRentalList = <RentalBookingData>[].obs;
  RxList<RentalBookingData> completedRentalList = <RentalBookingData>[].obs;
  RxList<RentalBookingData> cancelledRentalList = <RentalBookingData>[].obs;

  Future<void> getBookingList() async {
    Map<String, dynamic> bodyParams = {
      'user_type': "customer",
      'user_id': Preferences.getInt(Preferences.userId).toString(),
      'booking_type': bookingType.value == "Ride Booking"
          ? 'ride'
          : bookingType.value == "Parcel Delivery"
              ? "parcel"
              : 'rental',
    };
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.getBookingList), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed" || value['success'] == "failed") {
            return null;
          } else {
            if (bookingType.value == "Ride Booking") {
              newList.value = (value['data'] as List)
                  .map((e) => BookingData.fromJson(e))
                  .toList()
                  .where((element) => element.statut == RideStatus.newRide || element.statut == RideStatus.confirmed)
                  .toList();
              onGoingList.value = (value['data'] as List)
                  .map((e) => BookingData.fromJson(e))
                  .toList()
                  .where((element) => element.statut == RideStatus.onRide)
                  .toList();
              completedList.value = (value['data'] as List)
                  .map((e) => BookingData.fromJson(e))
                  .toList()
                  .where((element) => element.statut == RideStatus.completed)
                  .toList();
              cancelledList.value = (value['data'] as List)
                  .map((e) => BookingData.fromJson(e))
                  .toList()
                  .where((element) => element.statut == RideStatus.rejected || element.statut == RideStatus.canceled)
                  .toList();
            } else if (bookingType.value == "Parcel Delivery") {
              newParcelList.value = (value['data'] as List)
                  .map((e) => ParcelBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.newRide || element.status == RideStatus.confirmed)
                  .toList();
              onGoingParcelList.value = (value['data'] as List)
                  .map((e) => ParcelBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.onRide)
                  .toList();
              completedParcelList.value = (value['data'] as List)
                  .map((e) => ParcelBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.completed)
                  .toList();
              cancelledParcelList.value = (value['data'] as List)
                  .map((e) => ParcelBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.rejected || element.status == RideStatus.canceled)
                  .toList();
            } else if (bookingType.value == "Rental Cars") {
              newRentalList.value = (value['data'] as List)
                  .map((e) => RentalBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.newRide || element.status == RideStatus.confirmed)
                  .toList();
              onGoingRentalList.value = (value['data'] as List)
                  .map((e) => RentalBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.onRide)
                  .toList();
              completedRentalList.value = (value['data'] as List)
                  .map((e) => RentalBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.completed)
                  .toList();
              cancelledRentalList.value = (value['data'] as List)
                  .map((e) => RentalBookingData.fromJson(e))
                  .toList()
                  .where((element) => element.status == RideStatus.rejected || element.status == RideStatus.canceled)
                  .toList();
            }
          }
          Get.back();
        }
      },
    );

    isLoading.value = false;
  }

  String calculateParcelTotalAmountBooking(ParcelBookingData parcelBookingData) {
    String subTotal = parcelBookingData.amount.toString();
    String discount = "0.0";
    String taxAmount = "0.0";
    if (parcelBookingData.discountType != null) {
      discount = Constant.calculateDiscountOrder(amount: subTotal, offerModel: parcelBookingData.discountType).toString();
    }
    for (var element in parcelBookingData.tax!) {
      taxAmount = (double.parse(taxAmount) + Constant().calculateTax(amount: (double.parse(subTotal) - double.parse(discount)).toString(), taxModel: element))
          .toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
    }

    return ((double.parse(subTotal) - (double.parse(discount))) + double.parse(taxAmount)).toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
  }

  Future<void> cancelRequest(BookingData bookingData) async {
    Map<String, dynamic> bodyParams = {
      'id_ride': bookingData.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'reason': "Cancelled by user",
    };
    print("Cancel Request: ${bodyParams.toString()}");
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.setCancelledRequete), headers: API.headers, body: jsonEncode(bodyParams)),
            showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Ride cancelled successfully");
            getBookingList();
            Get.back();
          }
        }
      },
    );
  }

  Future<void> sosRequest(BookingData bookingData) async {
    Map<String, dynamic> bodyParams = {
      'ride_id': bookingData.id.toString(),
    };
    print("Cancel Request: ${bodyParams.toString()}");
    await API
        .handleApiRequest(request: () => http.post(Uri.parse(API.sos), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Sos request sent successfully");
            getBookingList();
            Get.back();
          }
        }
      },
    );
  }

  Future<void> cancelRentalRequest(RentalBookingData bookingData) async {
    Map<String, dynamic> bodyParams = {
      'id_rental': bookingData.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'reason': "Cancelled by user",
    };
    print("Cancel Request: ${bodyParams.toString()}");
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.rentalCanceled), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Ride cancelled successfully");
            getBookingList();
            Get.back();
          }
        }
      },
    );
  }

  Future<void> cancelParcelRequest(ParcelBookingData bookingData) async {
    Map<String, dynamic> bodyParams = {
      'id_parcel': bookingData.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'reason': "Cancelled by user",
    };
    print("Cancel Request: ${bodyParams.toString()}");
    await API
        .handleApiRequest(
        request: () => http.post(Uri.parse(API.parcelCanceled), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true)
        .then(
          (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Parcel cancelled successfully");
            getBookingList();
            Get.back();
          }
        }
      },
    );
  }

}
