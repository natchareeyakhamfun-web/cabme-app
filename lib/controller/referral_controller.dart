import 'dart:async';

import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ReferralController extends GetxController {
  RxBool isLoading = true.obs;
  RxString referralCode = "".obs;
  RxString referralAmount = "".obs;

  @override
  void onInit() {
    getReferralAmount();
    super.onInit();
  }

  Future<dynamic> getReferralAmount() async {
    await API
        .handleApiRequest(request: () => http.get(Uri.parse("${API.referralAmount}?id_user=${Preferences.getInt(Preferences.userId)}"), headers: API.headers), showLoader: false)
        .then(
      (value) {
        if (value != null) {
          if(value['success'] == 'Failed' || value['success'] == 'failed') {
            referralAmount.value = "0";
            referralCode.value = "";
          } else if (value['success'] == 'Success' || value['success'] == 'success') {
            referralAmount.value = value['data']['referral_amount'];
            referralCode.value = value['data']['referral_code'];
          }

        }
      },
    );

    isLoading.value = false;
  }
}
