import 'dart:async';
import 'dart:convert';
import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/service/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignUpController extends GetxController {
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumber = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> countryISOCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> conformPasswordController = TextEditingController().obs;
  Rx<TextEditingController> referralCodeController = TextEditingController().obs;

  RxBool isPasswordShow = true.obs;
  RxBool isConformPasswordShow = true.obs;

  RxString loginType = "".obs;

  @override
  void onInit() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      loginType.value = argumentData['login_type'];
      if (loginType.value == "phoneNumber") {
        phoneNumber.value.text = '${argumentData['phoneNumber']}';
        countryCodeController.value.text = '${argumentData['countryCode']}';
        countryISOCodeController.value.text = '${argumentData['countryISOCode']}';
      } else {
        emailController.value.text = argumentData['email'] ?? "";
        firstNameController.value.text = argumentData['firstName'] ?? "";
        lastNameController.value.text = argumentData['lastname'] ?? "";
      }
    }
    super.onInit();
  }

  Future<UserModel?> signUp(Map<String, String> bodyParams) async {
    UserModel? userModel;
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.userSignUP), headers: API.authheader, body: jsonEncode(bodyParams)), showLoader: true).then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed" || value['success'] == 'failed') {
            ShowToastDialog.showToast(value['message']);
            return null;
          } else {
            ShowToastDialog.closeLoader();
            userModel = UserModel.fromJson(value);
          }
        }
      },
    );
    return userModel;
  }
}
