// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/otp_controller.dart';
import 'package:cabme/page/auth_screens/signup_screen.dart';
import 'package:cabme/page/dashboard_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OTPController>(
        init: OTPController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back)),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify your number'.tr,
                    textAlign: TextAlign.start,
                    style: AppThemeData.boldTextStyle(fontSize: 22, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Enter the 6-digit code'.tr,
                    textAlign: TextAlign.start,
                    style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Pinput(
                    scrollPadding: EdgeInsets.zero,
                    controller: controller.otpController.value,
                    defaultPinTheme: PinTheme(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      height: 55,
                      width: 55,
                      textStyle: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(50),
                        color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                        border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 0.8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    length: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: RoundedButtonFill(
                      title: "Verify".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();

                        if (controller.otpController.value.text.length == 6) {
                          ShowToastDialog.showLoader("Verify OTP".tr);
                          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: controller.verificationId.toString(), smsCode: controller.otpController.value.text);
                          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                            Map<String, String> bodyParams = {
                              'phone': controller.phoneNumber.value,
                              'country_iso_code': controller.countryISOCode.value,
                              'country_code': controller.countryCode.value,
                              'user_cat': "customer",
                              'login_type': "phoneNumber"
                            };
                            await controller.phoneNumberIsExit(bodyParams).then((value) async {
                              if (value != null) {
                                if (value == true) {
                                  Map<String, String> bodyParams = {
                                    'phone': controller.phoneNumber.value,
                                    'country_iso_code': controller.countryISOCode.value,
                                    'country_code': controller.countryCode.value,
                                    'user_cat': "customer",
                                    'login_type': "phoneNumber",
                                  };
                                  await controller.getDataByPhoneNumber(bodyParams).then((value) {
                                    if (value != null) {
                                      if (value.success == "success") {
                                        ShowToastDialog.closeLoader();

                                        Preferences.setInt(Preferences.userId, int.parse(value.userData!.id.toString()));
                                        Preferences.setString(Preferences.user, jsonEncode(value));
                                        Preferences.setString(Preferences.accesstoken, value.userData!.accesstoken.toString());
                                        API.headers['accesstoken'] = value.userData!.accesstoken.toString();

                                        Preferences.setBoolean(Preferences.isLogin, true);
                                        Get.offAll(DashboardScreen());
                                      } else {
                                        ShowToastDialog.showToast(value.error);
                                      }
                                    }
                                  });
                                } else if (value == false) {
                                  ShowToastDialog.closeLoader();
                                  Get.to(SignupScreen(), arguments: {
                                    'phoneNumber': controller.phoneNumber.value,
                                    'countryISOCode': controller.countryISOCode.value,
                                    'countryCode': controller.countryCode.value,
                                    'login_type': "phoneNumber",
                                  });
                                }
                              }
                            });
                          }).catchError((error) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Code is Invalid");
                          });
                        } else {
                          ShowToastDialog.showToast("Please Enter OTP");
                        }
                      },
                    ),
                  ),
                  Center(
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        text: 'Didn’t Received OTP '.tr,
                        style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                        children: <TextSpan>[
                          TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = () => controller.resendOTP(),
                            text: 'Send Again'.tr,
                            style: AppThemeData.mediumTextStyle(
                              fontSize: 14,
                              color: themeChange.getThem() ? AppThemeData.infoDarkDefault : AppThemeData.infoDefault,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
