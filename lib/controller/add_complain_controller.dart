import 'dart:convert';

import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/model/parcel_bokking_model.dart';
import 'package:cabme/model/rental_booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../service/api.dart';

class AddComplainController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;

  Rx<BookingData> bookingData = BookingData().obs;
  Rx<ParcelBookingData> parcelBookingData = ParcelBookingData().obs;
  Rx<RentalBookingData> rentalBookingData = RentalBookingData().obs;
  RxString bookingType = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArguments();
    super.onInit();
  }

  void getArguments() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingType.value = argumentData['bookingType'];
      if (bookingType.value == 'ride') {
        bookingData.value = argumentData['bookingModel'];
        if (bookingData.value.complaint == true) {
          titleController.value.text = bookingData.value.complainDetails!.title ?? '';
          descriptionController.value.text = bookingData.value.complainDetails!.description ?? '';
        }
      } else if (bookingType.value == 'rental') {
        rentalBookingData.value = argumentData['rentalBookingData'];
        if (rentalBookingData.value.complaint == true) {
          titleController.value.text = rentalBookingData.value.complainDetails!.title ?? '';
          descriptionController.value.text = rentalBookingData.value.complainDetails!.description ?? '';
        }
      } else if (bookingType.value == 'parcel') {
        parcelBookingData.value = argumentData['parcelBookingData'];
        if (parcelBookingData.value.complaint == true) {
          titleController.value.text = parcelBookingData.value.complainDetails!.title ?? '';
          descriptionController.value.text = parcelBookingData.value.complainDetails!.description ?? '';
        }
      }
    }
    isLoading.value = false;
  }

  Future<void> submitComplain() async {
    Map<String, dynamic> bodyParams = {
      'booking_id': bookingType.value == "ride"
          ? bookingData.value.id.toString()
          : bookingType.value == "rental"
              ? rentalBookingData.value.id.toString()
              : parcelBookingData.value.id.toString(),
      'title': titleController.value.text,
      'description': descriptionController.value.text,
      'booking_type': bookingType.value,
    };
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.addComplaint), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Complain submitted successfully");
            Get.back(result: true);
          }
        }
      },
    );
  }
}
