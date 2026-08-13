import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/ride_payment_controller.dart';
import 'package:cabme/model/razorpay_gen_orderid_model.dart';
import 'package:cabme/service/rozorpayConroller.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../themes/app_them_data.dart';

class RidePaymentScreen extends StatelessWidget {
  const RidePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RidePaymentController(),
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
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Visibility(
                        visible: controller.paymentSettingModel.value.cash != null &&
                            controller.paymentSettingModel.value.cash!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.cash!.libelle.toString(),
                          themeChange,
                          "assets/icons/cash.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.myWallet != null &&
                            controller.paymentSettingModel.value.myWallet!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.myWallet!.libelle.toString(),
                          themeChange,
                          "assets/images/ic_wallet_image.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.strip != null &&
                            controller.paymentSettingModel.value.strip!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.strip!.libelle.toString(),
                          themeChange,
                          "assets/images/stripe.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payPal != null &&
                            controller.paymentSettingModel.value.payPal!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.payPal!.libelle.toString(),
                          themeChange,
                          "assets/images/paypal.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payStack != null &&
                            controller.paymentSettingModel.value.payStack!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.payStack!.libelle.toString(),
                          themeChange,
                          "assets/images/paystack.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.mercadopago != null &&
                            controller.paymentSettingModel.value.mercadopago!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          "Mercado Pago",
                          themeChange,
                          "assets/images/mercado-pago.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.flutterWave != null &&
                            controller.paymentSettingModel.value.flutterWave!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.flutterWave!.libelle.toString(),
                          themeChange,
                          "assets/images/flutterwave_logo.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.payFast != null &&
                            controller.paymentSettingModel.value.payFast!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.payFast!.libelle.toString(),
                          themeChange,
                          "assets/images/payfast.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.razorpay != null &&
                            controller.paymentSettingModel.value.razorpay!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.razorpay!.libelle.toString(),
                          themeChange,
                          "assets/images/razorpay.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.xendit != null &&
                            controller.paymentSettingModel.value.xendit!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.xendit!.libelle.toString(),
                          themeChange,
                          "assets/images/xendit.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.orangePay != null &&
                            controller.paymentSettingModel.value.orangePay!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.orangePay!.libelle.toString(),
                          themeChange,
                          "assets/images/orangeMoney.png",
                        ),
                      ),
                      Visibility(
                        visible: controller.paymentSettingModel.value.midtrans != null &&
                            controller.paymentSettingModel.value.midtrans!.isEnabled == "true",
                        child: cardDecoration(
                          controller,
                          controller.paymentSettingModel.value.midtrans!.libelle.toString(),
                          themeChange,
                          "assets/images/midtrans.png",
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: RoundedButtonFill(
                title: "Confirm".tr,
                height: 5.5,
                color: AppThemeData.primaryDefault,
                textColor: AppThemeData.neutral900,
                onPress: () async {
                  FocusScope.of(context).unfocus();

                  if (controller.selectedPaymentMethod.value.isEmpty) {
                    ShowToastDialog.showToast("Please select payment method");
                  } else {
                    if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.myWallet!.libelle) {
                      double walletBalance = double.tryParse(controller.userModel.value.userData!.amount!) ?? 0.0;
                      double totalAmount = double.parse(controller.totalAmount.value);

                      if (walletBalance < 0) {
                        ShowToastDialog.showToast("Your wallet has a negative balance.".tr);
                        return;
                      } else if (walletBalance < totalAmount) {
                        ShowToastDialog.showToast("Your wallet balance is not sufficient.".tr);
                        return;
                      }

                      controller.setAmount();
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.cash!.libelle) {
                      controller.changePaymentMethod();
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.strip!.libelle) {
                      Stripe.publishableKey = controller.paymentSettingModel.value.strip?.key ?? '';
                      Stripe.merchantIdentifier = 'Cabme';
                      await Stripe.instance.applySettings();
                      controller.stripeMakePayment(amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.razorpay!.libelle) {
                      RazorPayController()
                          .createOrderRazorPay(
                              amount: double.parse(controller.totalAmount.value.toString()).toStringAsFixed(2),
                              razorpayModel: controller.paymentSettingModel.value.razorpay)
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
                      // _paypalPayment();
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.payStack!.libelle) {
                      controller.payStackPayment(controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value == controller.paymentSettingModel.value.flutterWave!.libelle) {
                      controller.flutterWaveInitiatePayment(
                          context: context, amount: double.parse(controller.totalAmount.value.toString()).toString());
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
                      controller.orangeMakePayment(
                          amount: double.parse(controller.totalAmount.value.toString()).toStringAsFixed(2), context: context);
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

  Widget cardDecoration(RidePaymentController controller, String value, themeChange, String image) {
    return Obx(
      () => InkWell(
        onTap: () {
          controller.selectedPaymentMethod.value = value;
        },
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Image.asset(
                    image,
                    width: value == controller.paymentSettingModel.value.myWallet!.libelle ||
                            value == controller.paymentSettingModel.value.cash!.libelle
                        ? 30
                        : 40,
                    height: value == controller.paymentSettingModel.value.myWallet!.libelle ||
                            value == controller.paymentSettingModel.value.cash!.libelle
                        ? 30
                        : 40,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: value == controller.paymentSettingModel.value.myWallet!.libelle
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Wallet",
                              style: AppThemeData.semiBoldTextStyle(
                                  color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontSize: 16),
                            ),
                            Text(
                              'balanceWithAmount'.trParams({
                                'amount': Constant().amountShow(
                                  amount: controller.userModel.value.userData!.amount.toString(),
                                ),
                              }),
                              style: AppThemeData.semiBoldTextStyle(
                                  color: themeChange.getThem() ? AppThemeData.secondary200 : AppThemeData.secondary200, fontSize: 12),
                            ),
                          ],
                        )
                      : Text(
                          value,
                          style: AppThemeData.semiBoldTextStyle(
                              color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontSize: 16),
                        ),
                ),
                const SizedBox(
                  width: 10,
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
            Divider(
              color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
              height: 1,
            )
          ],
        ),
      ),
    );
  }
}
