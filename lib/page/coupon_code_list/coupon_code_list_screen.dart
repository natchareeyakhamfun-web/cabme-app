import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/coupon_code_controller.dart';
import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../themes/app_them_data.dart';

class CouponCodeListScreen extends StatelessWidget {
  const CouponCodeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: CouponCodeController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(Icons.arrow_back),
              ),
              centerTitle: false,
              title: Text(
                "Coupons",
                style: AppThemeData.semiBoldTextStyle(fontSize: 18),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : controller.discountList.isEmpty
                    ? Constant.showEmptyView(message: "Discount is not available.")
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.discountList.length,
                          itemBuilder: (context, index) {
                            DiscountData discountData = controller.discountList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: Responsive.width(34, context),
                                        width: Responsive.width(100, context),
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              controller.getRandomImage(),
                                              height: Responsive.width(32, context),
                                              width: Responsive.width(100, context),
                                              fit: BoxFit.fill,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          (discountData.type == "Percentage"
                                                                  ? "${discountData.discount}%"
                                                                  : Constant().amountShow(amount: discountData.discount))
                                                              .tr,
                                                          textAlign: TextAlign.start,
                                                          style: AppThemeData.boldTextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'Validity till : ${discountData.expireAt}'.tr,
                                                        textAlign: TextAlign.center,
                                                        style: AppThemeData.semiBoldTextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${discountData.discription}'.tr,
                                                    textAlign: TextAlign.start,
                                                    style: AppThemeData.mediumTextStyle(
                                                      fontSize: 14,
                                                      color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color:
                                                              themeChange.getThem() ? AppThemeData.accentLight : AppThemeData.accentLight,
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                          child: Text(
                                                            "${discountData.code}",
                                                            style: AppThemeData.semiBoldTextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(ClipboardData(text: discountData.code.toString()));
                                                          ShowToastDialog.showToast("Coupon code copied");
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark,
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Icon(
                                                              Icons.copy,
                                                              size: 18,
                                                              color: AppThemeData.neutral50,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: RoundedButtonFill(
                                          title: "Apply Coupon".tr,
                                          height: 5,
                                          borderRadius: 10,
                                          color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                          textColor: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                                          onPress: () async {
                                            Get.back(result: {"discount": discountData});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          );
        });
  }
}
