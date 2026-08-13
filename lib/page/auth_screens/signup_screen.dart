import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/sign_up_controller.dart';
import 'package:cabme/page/dashboard_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../themes/app_them_data.dart';
import '../../themes/text_field_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<SignUpController>(
        init: SignUpController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Let’s get you started'.tr,
                      textAlign: TextAlign.center,
                      style: AppThemeData.boldTextStyle(fontSize: 22, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Start booking your rides in just a few taps.'.tr,
                      textAlign: TextAlign.center,
                      style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      controller: controller.firstNameController.value,
                      hintText: 'Enter First Name',
                      title: 'First Name',
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/ic_user.svg"),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.lastNameController.value,
                      hintText: 'Enter Last Name',
                      title: 'Last Name',
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/ic_user.svg"),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.emailController.value,
                      hintText: 'Enter Email Address',
                      title: 'Email Address',
                      enable: controller.loginType.value == "phoneNumber" ? true : false,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/ic_email_login.svg"),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.phoneNumber.value,
                      hintText: 'Enter Mobile Number',
                      title: 'Mobile Number',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      enable: controller.loginType.value == "phoneNumber" ? false : true,
                      prefix: CountryCodePicker(
                        onInit: (value) {
                          controller.countryCodeController.value.text = value?.dialCode ?? Constant.defaultCountryCode ?? '';
                          controller.countryISOCodeController.value.text = value?.code ?? Constant.defaultCountryCode ?? '';
                        },
                        onChanged: (value) {
                          controller.countryCodeController.value.text = value.dialCode.toString();
                          controller.countryISOCodeController.value.text = value.code ?? Constant.defaultCountryCode ?? '';
                        },
                        dialogTextStyle: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppThemeData.medium,
                        ),
                        dialogBackgroundColor: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                        initialSelection: controller.countryISOCodeController.value.text,
                        comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                        flagDecoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                        textStyle: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppThemeData.medium,
                        ),
                        searchDecoration: InputDecoration(
                          iconColor: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                        ),
                        searchStyle: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.passwordController.value,
                      hintText: 'Enter Password',
                      title: 'Password',
                      obscureText: controller.isPasswordShow.value,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/ic_lock_login.svg"),
                      ),
                      suffix: InkWell(
                        onTap: () {
                          if (controller.isPasswordShow.value) {
                            controller.isPasswordShow.value = false;
                          } else {
                            controller.isPasswordShow.value = true;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Obx(
                            () => controller.isPasswordShow.value ? SvgPicture.asset("assets/icons/ic_hide.svg") : SvgPicture.asset("assets/icons/ic_show.svg"),
                          ),
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.conformPasswordController.value,
                      hintText: 'Enter Confirm Password',
                      title: 'Confirm Password',
                      obscureText: controller.isConformPasswordShow.value,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/ic_lock_login.svg"),
                      ),
                      suffix: InkWell(
                        onTap: () {
                          if (controller.isConformPasswordShow.value) {
                            controller.isConformPasswordShow.value = false;
                          } else {
                            controller.isConformPasswordShow.value = true;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Obx(
                            () => controller.isConformPasswordShow.value ? SvgPicture.asset("assets/icons/ic_hide.svg") : SvgPicture.asset("assets/icons/ic_show.svg"),
                          ),
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      controller: controller.referralCodeController.value,
                      hintText: 'Referral Code (Optional)',
                      title: 'Referral Code',
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SvgPicture.asset("assets/icons/gift_line.svg"),
                      ),
                    ),
                    RoundedButtonFill(
                      title: "Create Account".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();
                        if (controller.firstNameController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter a first name");
                        } else if (controller.lastNameController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter a last name");
                        } else if (controller.emailController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter a email");
                        } else if (controller.phoneNumber.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter a phone number");
                        } else if (controller.passwordController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter a password");
                        } else if (controller.passwordController.value.text.trim() != controller.conformPasswordController.value.text.trim()) {
                          ShowToastDialog.showToast("Password and conform password not match");
                        } else {
                          Map<String, String> bodyParams = {
                            'firstname': controller.firstNameController.value.text.trim().toString(),
                            'lastname': controller.lastNameController.value.text.trim().toString(),
                            'phone': controller.phoneNumber.value.text.trim(),
                            'country_code': controller.countryCodeController.value.text.trim().toString(),
                            'country_iso_code': controller.countryISOCodeController.value.text.trim().toString(),
                            'email': controller.emailController.value.text.trim(),
                            'password': controller.passwordController.value.text,
                            'referral_code': controller.referralCodeController.value.text.toString(),
                            'login_type': controller.loginType.value,
                            'tonotify': 'yes',
                            'account_type': 'customer',
                          };
                          await controller.signUp(bodyParams).then((value) {
                            if (value != null) {
                              if (value.success == "success") {
                                Preferences.setInt(Preferences.userId, int.parse(value.userData!.id.toString()));
                                Preferences.setString(Preferences.user, jsonEncode(value));
                                Preferences.setString(Preferences.accesstoken, value.userData!.accesstoken.toString());
                                API.headers['accesstoken'] = value.userData!.accesstoken.toString();
                                Preferences.setBoolean(Preferences.isLogin, true);
                                ShowToastDialog.showToast("Signup successful!".tr);
                                Get.offAll(DashboardScreen());
                              } else {
                                ShowToastDialog.showToast(value.error);
                              }
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
