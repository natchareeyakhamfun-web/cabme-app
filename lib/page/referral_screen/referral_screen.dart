import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/referral_controller.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../themes/app_them_data.dart';
import '../../utils/dark_theme_provider.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ReferralController(),
        builder: (controller) {
          return Scaffold(
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Container(
                    width: Responsive.width(100, context),
                    height: Responsive.height(100, context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/referandearn.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        AppBar(
                          title: Text(
                            'Refer and Earn'.tr,
                            textAlign: TextAlign.center,
                            style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                          ),
                          backgroundColor: Colors.transparent,
                          centerTitle: false,
                          titleSpacing: 0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              SvgPicture.asset("assets/images/refer_earn.svg"),
                              Text(
                                'Refer & Earn',
                                style: AppThemeData.boldTextStyle(fontSize: 24, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Earn rewards by inviting your friends to CabME'.tr,
                                style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                  'referralEarning'.trParams({
                                    'amount': Constant().amountShow(
                                      amount: controller.referralAmount.toString(),
                                    ),
                                  }),
                                textAlign: TextAlign.center,
                                style: AppThemeData.semiBoldTextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Text(
                                'Your Referral Code:'.tr,
                                textAlign: TextAlign.center,
                                style: AppThemeData.semiBoldTextStyle(
                                  fontSize: 16,
                                  color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RoundedButtonFill(
                                title: "${controller.referralCode}".tr,
                                height: 5.5,
                                width: 40,
                                fontSizes: 20,
                                color: AppThemeData.primaryHover,
                                textColor: AppThemeData.neutral900,
                                isRight: true,
                                isCenter: true,
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SvgPicture.asset("assets/icons/file-copy-line.svg"),
                                ),
                                onPress: () async {
                                  FocusScope.of(context).unfocus();
                                  Clipboard.setData(ClipboardData(text: controller.referralCode.toString()));
                                  ShowToastDialog.showToast("Referral code copied to clipboard".tr);
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          );
        });
  }
}
