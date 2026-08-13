import 'dart:convert';
import 'dart:math';

import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CouponCodeController extends GetxController {
  RxBool isLoading = true.obs;
  final List<String> imageAssets = [
    'assets/images/coupon1.png',
    'assets/images/coupon2.png',
    'assets/images/coupon3.png',
  ];

  @override
  void onInit() {
    // TODO: implement onInit
    getArguments();
    super.onInit();
  }

  RxString type = "Ride".obs;

  Future<void> getArguments() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      await getCouponCode();
    }
    isLoading.value = false;
  }

  RxList<DiscountData> discountList = <DiscountData>[].obs;

  Future getCouponCode() async {
    Map<String, String> bodyParams = {
      'coupon_type': type.value,
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.discountList), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false).then(
      (value) {
        if (value != null) {
          DiscountListModel model = DiscountListModel.fromJson(value);
          if (model.success == "Failed" || model.success == "failed") {
            return;
          } else {
            discountList.value = model.data ?? [];
          }
        }
      },
    );
  }

  String getRandomImage() {
    final random = Random();
    return imageAssets[random.nextInt(imageAssets.length)];
  }
}
