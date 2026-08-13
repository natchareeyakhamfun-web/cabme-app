import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/banner_model.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/service/pusher_service.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeOneController extends GetxController {
  RxBool isLoading = true.obs;

  final List<double> fareBumpAmounts = const [10, 20, 30];

  RxList<String> serviceList = <String>[
    if (Constant.activeServices.contains("ride")) "ride",
    if (Constant.activeServices.contains("parcel")) "parcel",
    if (Constant.activeServices.contains("rental")) "rental",
  ].obs;
  RxList<BannerModelData> bannerList = <BannerModelData>[].obs;

  Rx<PageController> pageController = PageController(viewportFraction: 0.877).obs;
  RxInt currentPage = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  Future<dynamic> getData() async {
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.bannerHome), headers: API.headers), showLoader: false).then(
      (value) {
        if (value != null) {
          BannerModel bannerModel = BannerModel.fromJson(value);
          bannerList.value = bannerModel.data ?? [];
        }
      },
    );
    await getBooking();
    await getBookingData();
    isLoading.value = false;
  }

  Rx<BookingModel> bookingModel = BookingModel().obs;

  Future<void> getBooking() async {
    Map<String, dynamic> bodyParams = {
      'id_user': Preferences.getInt(Preferences.userId),
    };

    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.userRecentRide), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false)
        .then(
      (value) async {
        if (value != null) {
          if (value['success'] == "Failed" || value['success'] == "failed") {
            bookingModel.value = BookingModel();
            return null;
          } else {
            setBookingData(BookingModel.fromJson(value));
          }
        }
      },
    );
  }

  RxList<Stops> locationData = <Stops>[].obs;

  void setBookingData(BookingModel booking) {
    bookingModel.value = booking;
    if (booking.data != null) {
      if (booking.data!.statut == RideStatus.newRide ||
          booking.data!.statut == RideStatus.confirmed ||
          booking.data!.statut == RideStatus.onRide) {
        locationData.clear();
        locationData.add(
            Stops(location: booking.data!.departName, latitude: booking.data!.latitudeDepart, longitude: booking.data!.longitudeDepart));
        if(booking.data!.stops != null){
          locationData.addAll(booking.data!.stops!.map((e) => Stops(location: e.location, latitude: e.latitude, longitude: e.longitude)));
        }
        locationData.add(Stops(
            location: booking.data!.destinationName, latitude: booking.data!.latitudeArrivee, longitude: booking.data!.longitudeArrivee));
      } else if (booking.data!.statut == RideStatus.canceled ||
          booking.data!.statut == RideStatus.completed ||
          booking.data!.statut == RideStatus.rejected) {
        bookingModel.value = BookingModel();
      }
    }
    update();
  }

  Future<void> getBookingData() async {
    PusherService().subscribeCustomerRecentRide<BookingModel>(
      customerId: Preferences.getInt(Preferences.userId).toString(),
      event: 'updated',
      fromJson: BookingModel.fromJson,
      onData: (ride) {
        setBookingData(ride);
      },
    );
    update();
  }

  Future<void> increaseFare(double bumpAmount) async {
    if (bookingModel.value.data == null) return;
    final currentAmount = double.tryParse(bookingModel.value.data!.montant.toString()) ?? 0.0;
    final newAmount = currentAmount + bumpAmount;
    final Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.data!.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'new_amount': newAmount.toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2),
      'bump_amount': bumpAmount.toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2),
    };
    await API
        .handleApiRequest(
          request: () => http.post(Uri.parse(API.increaseFare), headers: API.headers, body: jsonEncode(bodyParams)),
          showLoader: true,
        )
        .then((value) {
      if (value == null) return;
      if (value['success'] == 'Failed' || value['success'] == 'failed') {
        ShowToastDialog.showToast(value['message']?.toString() ?? 'Unable to update fare');
        return;
      }
      bookingModel.value.data!.montant = newAmount.toString();
      bookingModel.refresh();
      ShowToastDialog.showToast("Fare updated. Searching for a driver...");
      getBooking();
    });
  }

  Future<void> cancelRequest() async {
    Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.data!.id.toString(),
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
            getBooking();
            Get.back();
          }
        }
      },
    );
  }

}
