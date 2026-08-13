import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/controller/booking_details_controller.dart';
import 'package:cabme/model/tax_model.dart';
import 'package:cabme/page/chats_screen/conversation_screen.dart';
import 'package:cabme/page/home_screens/ride_payment_screen.dart';
import 'package:cabme/page/live_tracking_screen/live_tracking_screen.dart';
import 'package:cabme/page/rating_screen/rating_screen.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:cabme/widget/map_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../themes/app_them_data.dart';
import '../../themes/round_button_fill.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingDetailsController(),
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
                controller.bookingModel.value.bookingNumber ?? "#${controller.bookingModel.value.id}",
                style: AppThemeData.semiBoldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: Responsive.height(20, context),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: MapView(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                    return index == 0
                                        ? SvgPicture.asset("assets/icons/ic_sender.svg")
                                        : controller.locationData.length - 1 == index
                                            ? SvgPicture.asset("assets/icons/ic_recevier.svg")
                                            : Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(color: AppThemeData.neutral900, borderRadius: BorderRadius.circular(40)),
                                                child: Center(
                                                  child: Text(
                                                    String.fromCharCode(index - 1 + 65),
                                                    style: TextStyle(fontSize: 14, fontFamily: AppThemeData.regular, color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50),
                                                  ),
                                                ),
                                              );
                                  },
                                  connectorBuilder: (context, index, connectorType) {
                                    return DashedLineConnector(
                                      color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                                      gap: 4,
                                    );
                                  },
                                  contentsBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Text(
                                        "${controller.locationData[index].location}",
                                        style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                    );
                                  },
                                  itemCount: controller.locationData.length,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          controller.bookingModel.value.statut == RideStatus.canceled
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
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
                                            "Driver and Cab Details".tr,
                                            style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                          ),
                                          Divider(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                          controller.bookingModel.value.statut == RideStatus.newRide
                                              ? Text(
                                                  "Waiting for driver to accept...".tr,
                                                  style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.successDarkDark : AppThemeData.successDefault),
                                                )
                                              : controller.bookingModel.value.driver == null
                                                  ? SizedBox()
                                                  : Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                          child: Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: NetworkImageWidget(
                                                                  imageUrl: controller.bookingModel.value.driver == null ? "" : controller.bookingModel.value.driver!.vehicleDetails!.image.toString(),
                                                                  width: 55,
                                                                  height: 55,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      (controller.bookingModel.value.driver == null
                                                                              ? ""
                                                                              : '${controller.bookingModel.value.driver!.prenom} ${controller.bookingModel.value.driver!.nom}')
                                                                          .tr,
                                                                      textAlign: TextAlign.start,
                                                                      style: AppThemeData.boldTextStyle(
                                                                          fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Container(
                                                                      width: 70,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(30),
                                                                          color: themeChange.getThem() ? AppThemeData.successLight : AppThemeData.successLight),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                                        child: Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.star_half,
                                                                              size: 14,
                                                                              color: themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              "${controller.bookingModel.value.driver == null ? "0.0" : controller.bookingModel.value.driver!.averageRating}",
                                                                              style: AppThemeData.mediumTextStyle(
                                                                                  fontSize: 14, color: themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              controller.bookingModel.value.statut == RideStatus.confirmed || controller.bookingModel.value.statut == RideStatus.onRide
                                                                  ? Row(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () {
                                                                            Constant.makePhoneCall(controller.bookingModel.value.driver!.phone!);
                                                                          },
                                                                          child: SvgPicture.asset(
                                                                            "assets/icons/ic_phone_dial.svg",
                                                                            width: 36,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: 10,
                                                                        ),
                                                                        InkWell(
                                                                          onTap: () {
                                                                            Get.to(ConversationScreen(), arguments: {
                                                                              "receiverId": controller.bookingModel.value.driver!.id,
                                                                              "orderId": controller.bookingModel.value.id,
                                                                              "receiverName": "${controller.bookingModel.value.driver!.prenom} ${controller.bookingModel.value.driver!.nom}",
                                                                              "receiverPhoto": controller.bookingModel.value.driver!.image
                                                                            });
                                                                          },
                                                                          child: SvgPicture.asset(
                                                                            "assets/icons/ic_chat_details.svg",
                                                                            width: 36,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox()
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Get.to(RatingScreen(), arguments: {"bookingType": "ride", "bookingModel": controller.bookingModel.value})!.then(
                                                                (value) {
                                                                  if (value != null) {
                                                                    if (value == true) {
                                                                      controller.getPusherBookingData();
                                                                    }
                                                                  }
                                                                },
                                                              );
                                                            },
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Icon(Icons.add, color: themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark),
                                                                Text(
                                                                  "Add Ratings".tr,
                                                                  style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                        ],
                                      ),
                                    ),
                                  ),
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
                                    "Booking Details".tr,
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                  Divider(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Booking Date and Time:".tr,
                                          style: AppThemeData.mediumTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          controller.bookingModel.value.creer.toString(),
                                          style: AppThemeData.boldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
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
                                    "Payment Details".tr,
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                  Divider(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Ride Cost".tr,
                                          style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          Constant().amountShow(amount: (double.parse(controller.subTotal.value) - double.parse(controller.bumpAmount.value)).toString()),
                                          textAlign: TextAlign.end,
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (double.parse(controller.bumpAmount.value) > 0 && controller.bumpAmount.value != "null")
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Increased fare rate".tr,
                                            style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            Constant().amountShow(amount: controller.bumpAmount.value.toString()),
                                            textAlign: TextAlign.end,
                                            style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (double.parse(controller.bumpAmount.value) > 0 && controller.bumpAmount.value != "null")
                                    SizedBox(
                                      height: 10,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Discount ${controller.bookingModel.value.discountType == null ? "" : controller.bookingModel.value.discountType!.type.toString() == "Percentage" ? " (${controller.bookingModel.value.discountType!.value}%)" : Constant().amountShow(amount: controller.bookingModel.value.discountType!.value)}'
                                                .tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.discount.value).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                        ),
                                      ],
                                    ),
                                  ),
                                  controller.bookingModel.value.tax != null
                                      ? ListView.builder(
                                          itemCount: controller.bookingModel.value.tax!.length,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            TaxModel taxModel = controller.bookingModel.value.tax![index];
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
                                                            amount: Constant()
                                                                .calculateTax(
                                                                    amount: ((double.parse(controller.subTotal.value)) - (double.parse(controller.discount.value))).toString(), taxModel: taxModel)
                                                                .toString())
                                                        .tr,
                                                    textAlign: TextAlign.start,
                                                    style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Total Payable Amount".tr,
                                          style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          Constant().amountShow(amount: controller.totalAmount.value),
                                          textAlign: TextAlign.end,
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.accentDark : AppThemeData.accentDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Payment Method:".tr,
                                          style: AppThemeData.mediumTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${controller.bookingModel.value.paymentMethod}",
                                          textAlign: TextAlign.end,
                                          style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 30),
              child: Row(
                children: [
                  controller.bookingModel.value.statut == RideStatus.onRide
                      ? Expanded(
                          child: RoundedButtonFill(
                            title: "Pay Now".tr,
                            height: 5.5,
                            color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault,
                            textColor: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50,
                            onPress: () async {
                              Get.to(RidePaymentScreen(), arguments: {"bookingModel": controller.bookingModel.value, "type": "ride"})!.then(
                                (value) {
                                  if (value == true) {
                                    controller.getPusherBookingData();
                                    Get.back(result: true);
                                  }
                                },
                              );
                            },
                          ),
                        )
                      : SizedBox(),
                  controller.bookingModel.value.statut == RideStatus.newRide || controller.bookingModel.value.statut == RideStatus.confirmed
                      ? Expanded(
                          child: RoundedButtonFill(
                            title: "Cancel Ride".tr,
                            height: 5.5,
                            color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault,
                            textColor: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50,
                            onPress: () async {
                              controller.cancelRequest();
                            },
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 10,
                  ),
                  controller.bookingModel.value.statut == RideStatus.confirmed || controller.bookingModel.value.statut == RideStatus.onRide
                      ? Expanded(
                          child: RoundedButtonFill(
                            title: "Track Ride".tr,
                            height: 5.5,
                            color: themeChange.getThem() ? AppThemeData.primaryDefault : AppThemeData.primaryDefault,
                            textColor: themeChange.getThem() ? AppThemeData.neutral900 : AppThemeData.neutral900,
                            onPress: () async {
                              Get.to(LiveTrackingScreen(), arguments: {"orderModel": controller.bookingModel.value});
                            },
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          );
        });
  }
}
