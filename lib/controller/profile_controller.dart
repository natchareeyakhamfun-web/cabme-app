import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';

class ProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;
  InAppReview inAppReview = InAppReview.instance;

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  void getUserData() {
    isLoading.value = true;
    userModel.value = Constant.getUserData();
    isLoading.value = false;
  }

  Future<void> logout() async {
    Map<String, String> bodyParams = {
      'user_id': userModel.value.userData!.id.toString(),
      'user_cat': "customer",
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.logout), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true).then(
      (value) {
        if (value != null) {
          if (value['success'] == "Success" || value['success'] == "success") {
            Preferences.clearKeyData(Preferences.user);
            Preferences.clearKeyData(Preferences.accesstoken);
            Preferences.clearKeyData(Preferences.isLogin);
            Preferences.clearKeyData(Preferences.user);
            Preferences.clearKeyData(Preferences.userId);
            Get.offAll(const LoginScreen());
            ShowToastDialog.showToast("Logout Successfully".tr);
          }
        }
      },
    );
  }

  Future<void> deleteCustomer() async {
    Map<String, String> bodyParams = {
      'user_id': userModel.value.userData!.id.toString(),
      'user_cat': "customer",
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.deleteUser), body: jsonEncode(bodyParams), headers: API.headers), showLoader: true).then(
      (value) async {
        if (value != null) {
          if (value['success'] == "failed" || value['success'] == "Failed") {
            return null;
          } else {
            Preferences.clearKeyData(Preferences.isLogin);
            Preferences.clearKeyData(Preferences.user);
            Preferences.clearKeyData(Preferences.userId);
            Preferences.clearKeyData(Preferences.accesstoken);
            Get.offAll(const LoginScreen());
            ShowToastDialog.showToast(value['message']);
          }
        }
      },
    );
  }
}
