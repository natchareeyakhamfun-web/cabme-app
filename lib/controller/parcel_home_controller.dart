import 'dart:convert';

import 'package:cabme/model/banner_model.dart';
import 'package:cabme/model/parcel_bokking_model.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/parcel_category_model.dart';

class ParcelHomeController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ParcelCategoryData> parcelCategoryList = <ParcelCategoryData>[].obs;

  RxList<BannerModelData> bannerList = <BannerModelData>[].obs;

  Rx<PageController> pageController = PageController(viewportFraction: 0.877).obs;
  RxInt currentPage = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getParcelCategory();
    super.onInit();
  }

  Future<void> getParcelCategory() async {
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.bannerHome), headers: API.headers), showLoader: false).then(
      (value) {
        if (value != null) {
          BannerModel bannerModel = BannerModel.fromJson(value);
          bannerList.value = bannerModel.data ?? [];
        }
      },
    );

    await API.handleApiRequest(request: () => http.get(Uri.parse(API.getParcelCategory), headers: API.headers), showLoader: false).then(
      (value) {
        if (value != null) {
          GetParcelCategoryModel bannerModel = GetParcelCategoryModel.fromJson(value);
          parcelCategoryList.value = bannerModel.data ?? [];
        }
      },
    );

    isLoading.value = false;
  }

  RxList<ParcelBookingData> parcelList = <ParcelBookingData>[].obs;

  Future<void> getParcelList() async {
    Map<String, dynamic> bodyParams = {
      'id_user': Preferences.getInt(Preferences.userId),
    };

    await API.handleApiRequest(request: () => http.post(Uri.parse(API.getUserParcelOrders), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false).then(
      (value) async {
        if (value != null) {
          // ParcelBookingModel model = ParcelBookingModel.fromJson(value);
          if (value['success'] == "Failed" || value['success'] == "failed") {
            return null;
          } else {
            parcelList.value = (value['data'] as List).map((e) => ParcelBookingData.fromJson(e)).toList();
          }
        }
      },
    );
  }
}
