import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/parcel_cart_controller.dart';
import 'package:cabme/model/razorpay_gen_orderid_model.dart';
import 'package:cabme/model/tax_model.dart';
import 'package:cabme/page/coupon_code_list/coupon_code_list_screen.dart';
import 'package:cabme/service/rozorpayConroller.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/themes/text_field_widget.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../themes/app_them_data.dart';

class ParcelCartScreen extends StatelessWidget {
  const ParcelCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ParcelCartController(),
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
                "Confirm Parcel",
                style: AppThemeData.semiBoldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Timeline.tileBuilder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                theme: TimelineThemeData(
                                  nodePosition: 0,
                                  // indicatorPosition: 0,
                                ),
                                builder: TimelineTileBuilder.connected(
                                  contentsAlign: ContentsAlign.basic,
                                  indicatorBuilder: (context, index) {
                                    return index == 0 ? SvgPicture.asset("assets/icons/ic_sender.svg") : SvgPicture.asset("assets/icons/ic_recevier.svg");
                                  },
                                  connectorBuilder: (context, index, connectorType) {
                                    return DashedLineConnector(
                                      color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
                                      gap: 3,
                                    );
                                  },
                                  contentsBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                      child: index == 0
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${controller.bookParcelModel.value.senderName}",
                                                  style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                ),
                                                Text(
                                                  "${controller.bookParcelModel.value.sourceAdrs}",
                                                  style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${controller.bookParcelModel.value.receiverName}",
                                                  style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                ),
                                                Text(
                                                  "${controller.bookParcelModel.value.destinationAdrs}",
                                                  style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                                ),
                                              ],
                                            ),
                                    );
                                  },
                                  itemCount: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "About Parcel Details".tr,
                            style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Distance",
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                        ),
                                      ),
                                      Text(
                                        "${double.parse(controller.bookParcelModel.value.distance.toString()).toStringAsFixed(2)} ${controller.bookParcelModel.value.distanceUnit}",
                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Weight (KG)",
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                        ),
                                      ),
                                      Text(
                                        "${controller.bookParcelModel.value.parcelWeight} Kg.",
                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Size (ft)",
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                        ),
                                      ),
                                      Text(
                                        "${controller.bookParcelModel.value.parcelDimension} ft.",
                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Visibility(
                                    visible: controller.parcelImages.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: SizedBox(
                                        height: 100,
                                        width: Responsive.width(100, context),
                                        child: ListView.builder(
                                          itemCount: controller.parcelImages.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: Container(
                                                width: 100,
                                                height: 100.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: FileImage(File(controller.parcelImages[index].path)),
                                                  ),
                                                ),
                                                child: InkWell(
                                                    onTap: () {
                                                      controller.parcelImages.removeAt(index);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_circle,
                                                      size: 30,
                                                    )),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Apply Coupon Code".tr,
                                      textAlign: TextAlign.start,
                                      style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(CouponCodeListScreen(), arguments: {"type": "Parcel"})!.then(
                                        (value) {
                                          if (value != null) {
                                            controller.selectedDiscount.value = value['discount'];
                                            controller.couponCodeTextEditController.value.text = controller.selectedDiscount.value.code.toString();
                                            controller.calculateAmount();
                                          }
                                        },
                                      );
                                    },
                                    child: Text(
                                      "View Coupons".tr,
                                      textAlign: TextAlign.center,
                                      style: AppThemeData.mediumTextStyle(
                                          fontSize: 14, color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault, decoration: TextDecoration.underline),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFieldWidget(
                                      controller: controller.couponCodeTextEditController.value,
                                      hintText: 'Enter Code',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  RoundedButtonFill(
                                    title: "Apply".tr,
                                    height: 5,
                                    width: 20,
                                    color: AppThemeData.primaryDefault,
                                    textColor: AppThemeData.neutral900,
                                    onPress: () async {
                                      if (controller.discountList.where((p0) => p0.code!.toLowerCase() == controller.couponCodeTextEditController.value.text.toLowerCase()).isNotEmpty) {
                                        controller.selectedDiscount.value =
                                            controller.discountList.firstWhere((p0) => p0.code!.toLowerCase() == controller.couponCodeTextEditController.value.text.toLowerCase());
                                        controller.calculateAmount();
                                        ShowToastDialog.showToast("Discount applied".tr);
                                      } else {
                                        ShowToastDialog.showToast("Please enter valid coupon code".tr);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: BoxDecoration(
                              border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Payment Details",
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                  Divider(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Shipping Cost",
                                          style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          Constant().amountShow(amount: controller.subTotal.value.toString()),
                                          textAlign: TextAlign.end,
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Discount'.tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.discount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    itemCount: Constant.taxList.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      TaxModel taxModel = Constant.taxList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${taxModel.libelle} (${taxModel.value} ${taxModel.type == "Fixed" ? "${Constant.currency}" : "%"})'.tr,
                                                textAlign: TextAlign.start,
                                                style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                              ),
                                            ),
                                            Text(
                                              Constant()
                                                  .amountShow(
                                                      amount: Constant().calculateTax(amount: (controller.subTotal.value - controller.discount.value).toString(), taxModel: taxModel).toString())
                                                  .tr,
                                              textAlign: TextAlign.start,
                                              style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Total Payable Amount",
                                          style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          Constant().amountShow(amount: controller.totalAmount.value.toString()),
                                          textAlign: TextAlign.end,
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Payment Method'.tr,
                                      textAlign: TextAlign.start,
                                      style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => paymentBottomSheet(themeChange, controller),
                                      );
                                    },
                                    child: Text(
                                      'Change'.tr,
                                      textAlign: TextAlign.center,
                                      style: AppThemeData.boldTextStyle(
                                          fontSize: 16, color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                    border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200)),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      controller.paymentSettingModel.value.myWallet!.libelle == controller.selectedPaymentMethod.value
                                          ? "assets/images/ic_wallet_image.png"
                                          : controller.paymentSettingModel.value.strip!.libelle == controller.selectedPaymentMethod.value
                                              ? "assets/images/stripe.png"
                                              : controller.paymentSettingModel.value.payPal!.libelle == controller.selectedPaymentMethod.value
                                                  ? "assets/images/paypal.png"
                                                  : controller.paymentSettingModel.value.payStack!.libelle == controller.selectedPaymentMethod.value
                                                      ? "assets/images/paystack.png"
                                                      : controller.paymentSettingModel.value.mercadopago!.libelle == controller.selectedPaymentMethod.value
                                                          ? "assets/images/mercado-pago.png"
                                                          : controller.paymentSettingModel.value.flutterWave!.libelle == controller.selectedPaymentMethod.value
                                                              ? "assets/images/flutterwave_logo.png"
                                                              : controller.paymentSettingModel.value.payFast!.libelle == controller.selectedPaymentMethod.value
                                                                  ? "assets/images/payfast.png"
                                                                  : controller.paymentSettingModel.value.razorpay!.libelle == controller.selectedPaymentMethod.value
                                                                      ? "assets/images/razorpay.png"
                                                                      : controller.paymentSettingModel.value.xendit!.libelle == controller.selectedPaymentMethod.value
                                                                          ? "assets/images/xendit.png"
                                                                          : controller.paymentSettingModel.value.orangePay!.libelle == controller.selectedPaymentMethod.value
                                                                              ? "assets/images/orangeMoney.png"
                                                                              : "assets/images/midtrans.png",
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(
                                      width: 22,
                                    ),
                                    Text(
                                      controller.selectedPaymentMethod.value.tr,
                                      textAlign: TextAlign.start,
                                      style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
              child: RoundedButtonFill(
                title: "Book Parcel".tr,
                height: 5.5,
                color: AppThemeData.primaryDefault,
                textColor: AppThemeData.neutral900,
                onPress: () async {
                  if (controller.selectedPaymentMethod.value.isEmpty) {
                    ShowToastDialog.showToast("Please select payment method".tr);
                  } else {
                    if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.myWallet!.libelle) {
                      double walletBalance = double.tryParse(controller.userModel.value.userData!.amount!) ?? 0.0;
                      double totalAmount = controller.totalAmount.value;

                      if (walletBalance < 0) {
                        ShowToastDialog.showToast("Your wallet has a negative balance.".tr);
                        return;
                      } else if (walletBalance < totalAmount) {
                        ShowToastDialog.showToast("Your wallet balance is not sufficient.".tr);
                        return;
                      }
                      controller.bookParcelRide();
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.strip!.libelle) {
                      Stripe.publishableKey = controller.paymentSettingModel.value.strip?.key ?? '';
                      Stripe.merchantIdentifier = 'Cabme';
                      await Stripe.instance.applySettings();
                      controller.stripeMakePayment(amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.strip!.libelle) {
                      RazorPayController()
                          .createOrderRazorPay(amount: double.parse(controller.totalAmount.value.toString()).toStringAsFixed(2), razorpayModel: controller.paymentSettingModel.value.razorpay)
                          .then((value) {
                        if (value == null) {
                          Get.back();
                          ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
                        } else {
                          CreateRazorPayOrderModel result = value;
                          controller.openCheckout(amount: controller.totalAmount.value, orderId: result.id);
                        }
                      });
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.payPal!.libelle) {
                      controller.paypalPaymentSheet(double.parse(controller.totalAmount.value.toString()).toString(), context);
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.payStack!.libelle) {
                      controller.payStackPayment(controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.flutterWave!.libelle) {
                      controller.flutterWaveInitiatePayment(context: context, amount: double.parse(controller.totalAmount.value.toString()).toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.payFast!.libelle) {
                      controller.payFastPayment(context: context, amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.mercadopago!.libelle) {
                      controller.mercadoPagoMakePayment(
                        context: context,
                        amount: double.parse(controller.totalAmount.value.toString()).toString(),
                      );
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.xendit!.libelle) {
                      controller.xenditPayment(context, double.parse(controller.totalAmount.value.toString()));
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.orangePay!.libelle) {
                      controller.orangeMakePayment(amount: double.parse(controller.totalAmount.value.toString()).toStringAsFixed(2), context: context);
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.midtrans!.libelle) {
                      controller.midtransMakePayment(amount: controller.totalAmount.value.toString(), context: context);
                    } else {
                      ShowToastDialog.showToast("Please select payment method");
                    }
                  }
                },
              ),
            ),
          );
        });
  }

  DraggableScrollableSheet paymentBottomSheet(themeChange, ParcelCartController controller) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      // Start height
      minChildSize: 0.8,
      // Minimum height
      maxChildSize: 0.8,
      // Maximum height
      expand: false,
      // ✅ Prevents full-screen takeover
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    controller: scrollController,
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 5,
                            color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                          ),
                        ),
                      ),
                      Text(
                        'Select payment method'.tr,
                        textAlign: TextAlign.center,
                        style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: controller.paymentSettingModel.value.myWallet != null && controller.paymentSettingModel.value.myWallet!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.myWallet!.libelle.toString(), themeChange, "assets/images/ic_wallet_image.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.strip != null && controller.paymentSettingModel.value.strip!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.strip!.libelle.toString(), themeChange, "assets/images/stripe.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.payPal != null && controller.paymentSettingModel.value.payPal!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.payPal!.libelle.toString(), themeChange, "assets/images/paypal.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.payStack != null && controller.paymentSettingModel.value.payStack!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.payStack!.libelle.toString(), themeChange, "assets/images/paystack.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.mercadopago != null && controller.paymentSettingModel.value.mercadopago!.isEnabled == "true",
                            child: cardDecoration(controller, "Mercado Pago", themeChange, "assets/images/mercado-pago.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.flutterWave != null && controller.paymentSettingModel.value.flutterWave!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.flutterWave!.libelle.toString(), themeChange, "assets/images/flutterwave_logo.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.payFast != null && controller.paymentSettingModel.value.payFast!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.payFast!.libelle.toString(), themeChange, "assets/images/payfast.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.razorpay != null && controller.paymentSettingModel.value.razorpay!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.razorpay!.libelle.toString(), themeChange, "assets/images/razorpay.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.xendit != null && controller.paymentSettingModel.value.xendit!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.xendit!.libelle.toString(), themeChange, "assets/images/xendit.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.orangePay != null && controller.paymentSettingModel.value.orangePay!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.orangePay!.libelle.toString(), themeChange, "assets/images/orangeMoney.png"),
                          ),
                          Visibility(
                            visible: controller.paymentSettingModel.value.midtrans != null && controller.paymentSettingModel.value.midtrans!.isEnabled == "true",
                            child: cardDecoration(controller, controller.paymentSettingModel.value.midtrans!.libelle.toString(), themeChange, "assets/images/midtrans.png"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: RoundedButtonFill(
                    title: "Confirm".tr,
                    height: 5.5,
                    color: AppThemeData.primaryDefault,
                    textColor: AppThemeData.neutral900,
                    onPress: () async {
                      FocusScope.of(context).unfocus();
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Obx cardDecoration(ParcelCartController controller, String value, themeChange, String image) {
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () {
              controller.selectedPaymentMethod.value = value;
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Image.asset(
                    image,
                    width: value == controller.paymentSettingModel.value.myWallet!.libelle || value == controller.paymentSettingModel.value.cash!.libelle ? 30 : 40,
                    height: value == controller.paymentSettingModel.value.myWallet!.libelle || value == controller.paymentSettingModel.value.cash!.libelle ? 30 : 40,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                value == controller.paymentSettingModel.value.myWallet!.libelle
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Wallet",
                            style: AppThemeData.semiBoldTextStyle(color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontSize: 16),
                          ),
                          Text(
                            'balanceWithAmount'.trParams({
                              'amount': Constant().amountShow(
                                amount: controller.userModel.value.userData!.amount.toString(),
                              ),
                            }),
                            style: AppThemeData.semiBoldTextStyle(color: themeChange.getThem() ? AppThemeData.secondary200 : AppThemeData.secondary200, fontSize: 12),
                          ),
                        ],
                      )
                    : Text(
                        value,
                        style: AppThemeData.semiBoldTextStyle(color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontSize: 16),
                      ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                Radio(
                  value: value.toString(),
                  groupValue: controller.selectedPaymentMethod.value,
                  activeColor: themeChange.getThem() ? AppThemeData.primaryDefault : AppThemeData.primaryDefault,
                  onChanged: (value) {
                    controller.selectedPaymentMethod.value = value.toString();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
