import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cabme/constant/logdata.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:cabme/utils/Preferences.dart';

class API {
  static const baseUrl = "https://your-base-url.com/api/v1/"; // live
  static const apiKey = "your-api-key";


  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };

  static Map<String, String> get headers {
    return {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      'apikey': apiKey,
      'accesstoken': Preferences.getString(Preferences.accesstoken),
    };
  }

  //new
  static const rideBook = "${baseUrl}ride-book";
  static const rentalRegister = "${baseUrl}rental-register";

  static const userSignUP = "${baseUrl}user";
  static const editProfile = "${baseUrl}update-user-profile";
  static const bannerHome = "${baseUrl}get-banners";
  static const userLogin = "${baseUrl}user-login";
  static const sendResetPasswordOtp = "${baseUrl}reset-password-otp";
  static const resetPasswordOtp = "${baseUrl}reset-password";
  static const getProfileByPhone = "${baseUrl}profilebyphone";
  static const getExistingUserOrNot = "${baseUrl}existing-user";
  static const changePassword = "${baseUrl}update-user-mdp";
  static const contactUs = "${baseUrl}contact-us";
  static const updateToken = "${baseUrl}update-fcm";
  static const getWalletHistory = "${baseUrl}get-wallet-history";
  static const amount = "${baseUrl}amount";
  static const getFcmToken = "${baseUrl}fcm-token";

  static const onBoarding = "${baseUrl}on-boarding?type=Customer";
  static const getVehicleCategoryRental = "${baseUrl}vehicle-category";
  static const getVehicleCategory = "${baseUrl}vehicle-category-basefare";
  static const sos = "${baseUrl}storesos";
  static const paymentSetting = "${baseUrl}payment-settings";
  static const discountList = "${baseUrl}discount-list";
  static const getLanguage = "${baseUrl}language";
  static const deleteUser = "${baseUrl}user-delete";
  static const settings = "${baseUrl}settings";
  static const privacyPolicy = "${baseUrl}privacy-policy";
  static const termsOfCondition = "${baseUrl}terms-of-condition";
  static const referralAmount = "${baseUrl}get-referral";

  static const getBookingList = "${baseUrl}get-booking-list";
  static const getBookingDetails = "${baseUrl}get-booking-details";
  static const completeRequest = "${baseUrl}complete-requete";

  //Parcel API
  static const getParcelCategory = "${baseUrl}get-parcel-category";
  static const bookParcel = "${baseUrl}parcel-register";
  static const getparcelCategoryBasefare = "${baseUrl}parcel-category-basefare";

  static const getReview = "${baseUrl}get-review";
  static const getRentalPackages = "${baseUrl}get-rental-packages";

  static const setCancelledRequete = "${baseUrl}set-cancelled-requete";
  static const userRecentRide = "${baseUrl}user-recent-ride";
  static const submitReview = "${baseUrl}submit-review";

  static const getParcelDetail = "${baseUrl}get-parcel-detail";
  static const getUserParcelOrders = "${baseUrl}get-user-parcel-orders";
  static const getRentalBookingDetails = "${baseUrl}get-rental-booking-details";
  static const rentalComplete = "${baseUrl}rental-complete";
  static const rentalCanceled = "${baseUrl}rental-canceled";
  static const getDriverDetails = "${baseUrl}get-driver-details";
  static const parcelCanceled = "${baseUrl}parcel-canceled";
  static const changeBookingPaymentMethod = "${baseUrl}change-booking-payment-method";

  static const addComplaint = "${baseUrl}complaints";
  static const logout = "${baseUrl}logout";
  static const getServiceJson = "${baseUrl}get-service-json";
  static const increaseFare = "${baseUrl}ride-increase-fare";

  static bool _isRedirectingToLogin = false; // Prevent multiple redirects

  static Future<dynamic> handleApiRequest({required Future<http.Response> Function() request, bool showLoader = true}) async {
    try {
      if (showLoader) {
        ShowToastDialog.showLoader("Please wait");
      }

      final response = await request().timeout(const Duration(seconds: 30));

      showLog("✅ API :: URL :: ${response.request?.url}");
      showLog("✅ API :: Response Status :: ${response.statusCode}");
      showLog("✅ API :: Response Body :: ${response.body}");

      final decodedResponse = jsonDecode(response.body);

      if (showLoader) ShowToastDialog.closeLoader();
      if (response.statusCode == 401 && !_isRedirectingToLogin) {
        _isRedirectingToLogin = true; // Lock redirect
        Preferences.clearKeyData(Preferences.accesstoken);
        Preferences.clearKeyData(Preferences.isLogin);
        Preferences.clearKeyData(Preferences.user);
        Preferences.clearKeyData(Preferences.userId);
        Get.offAll(const LoginScreen());
        return null;
      }

      if (response.statusCode == 200) {
        return decodedResponse;
      } else if (response.statusCode == 401 && !_isRedirectingToLogin) {
        _isRedirectingToLogin = true; // Lock redirect
        Preferences.clearKeyData(Preferences.accesstoken);
        Preferences.clearKeyData(Preferences.isLogin);
        Preferences.clearKeyData(Preferences.user);
        Preferences.clearKeyData(Preferences.userId);
        Get.offAll(const LoginScreen());
        return null;
      } else {
        CustomDialog.showErrorDialog("Server Error", "Status Code: ${response.statusCode}");
        return null;
      }
    } on TimeoutException {
      showLog("⏰ Timeout Exception");
      CustomDialog.showErrorDialog("Server Timeout", "The server took too long to respond.");
    } on SocketException {
      showLog("🌐 No Internet / DNS Fail");
      CustomDialog.showErrorDialog("No Internet", "Please check your connection.");
    } on FormatException {
      showLog("📦 JSON Decode Error");
      ShowToastDialog.showToast("Invalid response format.");
    } catch (e) {
      showLog("🔥 Unexpected Error: $e");
      CustomDialog.showErrorDialog("Unexpected Error", "$e");
    } finally {
      if (showLoader) ShowToastDialog.closeLoader();
    }

    return null;
  }

  static Future<dynamic> handleMultipartRequest(
      {required String url, required Map<String, String> headers, required Map<String, String> fields, List<http.MultipartFile>? files, bool showLoader = true}) async {
    try {
      if (showLoader) {
        ShowToastDialog.showLoader("Please wait");
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        request.files.addAll(files);
      }

      var streamedResponse = await request.send();
      var responseBytes = await streamedResponse.stream.toBytes();
      var response = http.Response.bytes(
        responseBytes,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
        request: streamedResponse.request,
      );

      showLog("API :: URL :: ${response.request?.url}");
      showLog("API :: Response Status :: ${response.statusCode}");
      showLog("API :: Response Body :: ${response.body}");

      dynamic decodedResponse;
      try {
        decodedResponse = jsonDecode(response.body);
      } catch (e) {
        ShowToastDialog.showToast("Server error: ${response.body}");
        return null;
      }

      if (showLoader) {
        ShowToastDialog.closeLoader();
      }

      if (response.statusCode == 200 && (decodedResponse['success'] == 'success' || decodedResponse['success'] == 'Success')) {
        return decodedResponse;
      } else if (response.statusCode == 200 && (decodedResponse['success'] == 'Failed' || decodedResponse['success'] == 'failed')) {
        return decodedResponse;
      } else {
        ShowToastDialog.showToast(decodedResponse['error'] ?? "Something went wrong: ${response.statusCode}");
        return null;
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast("Timeout: ${e.message}");
    } on SocketException catch (e) {
      ShowToastDialog.showToast("Connection Error: ${e.message}");
    } on Error catch (e) {
      ShowToastDialog.showToast("Error: $e");
    } catch (e) {
      ShowToastDialog.showToast("Unexpected Error: $e");
    } finally {
      if (showLoader) {
        ShowToastDialog.closeLoader();
      }
    }
    return null;
  }
}

class CustomDialog {
  static bool _isDialogVisible = false;

  static void showErrorDialog(String title, String message) {
    if (_isDialogVisible) return;

    _isDialogVisible = true;

    Get.defaultDialog(
      title: title,
      content: Text(message),
      textConfirm: "OK",
      barrierDismissible: false,
      onConfirm: () {
        _isDialogVisible = false;
        Get.back();
      },
      onWillPop: () async {
        _isDialogVisible = false;
        return true;
      },
    );
  }
}
