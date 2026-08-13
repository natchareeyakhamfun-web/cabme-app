import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/model/banner_model.dart';
import 'package:cabme/page/booking_details_screens/booking_details_screen.dart';
import 'package:cabme/page/chats_screen/conversation_screen.dart';
import 'package:cabme/page/home_screens/book_ride_screen.dart';
import 'package:cabme/page/home_screens/ride_payment_screen.dart';
import 'package:cabme/page/live_tracking_screen/live_tracking_screen.dart';
import 'package:cabme/page/parcel_service_screen/parcel_home_screen.dart';
import 'package:cabme/page/rental_service/rental_home_screen.dart';
import 'package:cabme/widget/fare_bump_content.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../controller/home_one_controller.dart';
import '../../themes/app_them_data.dart';

class HomeScreenOne extends StatelessWidget {
  const HomeScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: HomeOneController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
              title: Text(
                'CabME'.tr,
                textAlign: TextAlign.center,
                style: AppThemeData.boldTextStyle(
                    fontSize: 22, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
              centerTitle: false,
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BannerView(
                            controller: controller,
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Suggestions'.tr,
                            textAlign: TextAlign.center,
                            style: AppThemeData.boldTextStyle(
                                fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.serviceList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                String name = controller.serviceList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: name == "ride"
                                      ? InkWell(
                                          onTap: () {
                                            Get.to(BookRideScreen())!.then(
                                              (value) {
                                                if (value == true) {
                                                  controller.getBooking();
                                                }
                                              },
                                            );
                                          },
                                          child: SizedBox(
                                            height: Responsive.width(100, context),
                                            child: Stack(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/images/ride_booking.svg",
                                                  fit: BoxFit.fill,
                                                ),
                                                Positioned(
                                                  left: 10,
                                                  top: 10,
                                                  right: 10,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Ride Booking'.tr,
                                                        textAlign: TextAlign.start,
                                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: AppThemeData.neutral900),
                                                      ),
                                                      Text(
                                                        'Book a Ride in Seconds'.tr,
                                                        textAlign: TextAlign.start,
                                                        maxLines: 2,
                                                        // ⬅️ allow up to 2 lines
                                                        softWrap: true,
                                                        // ⬅️ enable wrapping
                                                        overflow: TextOverflow.visible,
                                                        // ⬅️ don’t cut text
                                                        style: AppThemeData.mediumTextStyle(fontSize: 12, color: AppThemeData.neutral500),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : name == "parcel"
                                          ? SizedBox(
                                              height: Responsive.width(100, context),
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(ParcelHomeScreen());
                                                },
                                                child: Stack(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/images/parcel_delivery.svg",
                                                      fit: BoxFit.fill,
                                                    ),
                                                    Positioned(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10, // ⬅️ so text respects card width
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Parcel Delivery'.tr,
                                                            textAlign: TextAlign.start,
                                                            style: AppThemeData.boldTextStyle(fontSize: 16, color: AppThemeData.neutral900),
                                                          ),
                                                          Text(
                                                            'Send Parcels Door-to-Door'.tr,
                                                            textAlign: TextAlign.start,
                                                            maxLines: 2,
                                                            // ⬅️ allow up to 2 lines
                                                            softWrap: true,
                                                            // ⬅️ enable wrapping
                                                            overflow: TextOverflow.visible,
                                                            // ⬅️ don’t cut text
                                                            style:
                                                                AppThemeData.mediumTextStyle(fontSize: 12, color: AppThemeData.neutral500),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: Responsive.width(100, context),
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(RentalHomeScreen());
                                                },
                                                child: Stack(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/images/rental_car.svg",
                                                      fit: BoxFit.fill,
                                                    ),
                                                    Positioned(
                                                      left: 10,
                                                      top: 10,
                                                      right: 10,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Rent a Car'.tr,
                                                            textAlign: TextAlign.start,
                                                            style: AppThemeData.boldTextStyle(fontSize: 16, color: AppThemeData.neutral900),
                                                          ),
                                                          Text(
                                                            'Rent a Car by hours for your next trip.'.tr,
                                                            textAlign: TextAlign.start,
                                                            maxLines: 2,
                                                            // ⬅️ allow up to 2 lines
                                                            softWrap: true,
                                                            // ⬅️ enable wrapping
                                                            overflow: TextOverflow.visible,
                                                            // ⬅️ don’t cut text
                                                            style:
                                                                AppThemeData.mediumTextStyle(fontSize: 12, color: AppThemeData.neutral500),
                                                          ),
                                                        ],
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
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Recent Bookings'.tr,
                            textAlign: TextAlign.center,
                            style: AppThemeData.boldTextStyle(
                                fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await controller.getBooking(); // Make sure this method reloads bookings
                          },
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              Obx(
                                () => controller.bookingModel.value.data == null
                                    ? Constant.showEmptyView(message: "Recent bookings not found".tr)
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(BookingDetailsScreen(),
                                                      arguments: {"bookingModel": controller.bookingModel.value.data!})!
                                                  .then(
                                                (value) {
                                                  if (value == true) {
                                                    controller.getBooking();
                                                  }
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  controller.bookingModel.value.data!.statut == RideStatus.newRide ||
                                                          controller.bookingModel.value.data!.statut == RideStatus.canceled
                                                      ? Column(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Container(
                                                                width: 100,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(30),
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData.successLight
                                                                        : AppThemeData.successLight),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "${controller.bookingModel.value.data!.statut}",
                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.successDefault
                                                                              : AppThemeData.successDefault),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
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
                                                                    return index == 0
                                                                        ? SvgPicture.asset("assets/icons/ic_sender.svg")
                                                                        : controller.locationData.length - 1 == index
                                                                            ? SvgPicture.asset("assets/icons/ic_recevier.svg")
                                                                            : Container(
                                                                                width: 24,
                                                                                height: 24,
                                                                                decoration: BoxDecoration(
                                                                                    color: AppThemeData.neutral900,
                                                                                    borderRadius: BorderRadius.circular(40)),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    String.fromCharCode(index - 1 + 65),
                                                                                    style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        fontFamily: AppThemeData.regular,
                                                                                        color: themeChange.getThem()
                                                                                            ? AppThemeData.neutral50
                                                                                            : AppThemeData.neutral50),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                  },
                                                                  connectorBuilder: (context, index, connectorType) {
                                                                    return DashedLineConnector(
                                                                      color: themeChange.getThem()
                                                                          ? AppThemeData.neutralDark300
                                                                          : AppThemeData.neutral300,
                                                                      gap: 4,
                                                                    );
                                                                  },
                                                                  contentsBuilder: (context, index) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                                      child: Text(
                                                                        "${controller.locationData[index].location}",
                                                                        style: AppThemeData.mediumTextStyle(
                                                                            fontSize: 14,
                                                                            color: themeChange.getThem()
                                                                                ? AppThemeData.neutralDark900
                                                                                : AppThemeData.neutral900),
                                                                      ),
                                                                    );
                                                                  },
                                                                  itemCount: controller.locationData.length,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              height: 120,
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    child: NetworkImageWidget(
                                                                      imageUrl: controller
                                                                          .bookingModel.value.data!.driver!.vehicleDetails!.image
                                                                          .toString(),
                                                                      width: 105,
                                                                      height: 100,
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    bottom: 5,
                                                                    left: 6,
                                                                    right: 6,
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(30),
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.successLight
                                                                              : AppThemeData.successLight),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                                        child: Center(
                                                                          child: Text(
                                                                            "${controller.bookingModel.value.data!.statut}",
                                                                            style: AppThemeData.mediumTextStyle(
                                                                                fontSize: 12,
                                                                                color: themeChange.getThem()
                                                                                    ? AppThemeData.successDefault
                                                                                    : AppThemeData.successDefault),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 14,
                                                            ),
                                                            controller.bookingModel.value.data!.driver == null
                                                                ? SizedBox()
                                                                : Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 10),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    controller.bookingModel.value.data!.statut ==
                                                                                            RideStatus.newRide
                                                                                        ? Text(
                                                                                            '${controller.bookingModel.value.data!.driver!.vehicleDetails!.type}'
                                                                                                .tr,
                                                                                            textAlign: TextAlign.center,
                                                                                            style: AppThemeData.boldTextStyle(
                                                                                                fontSize: 16,
                                                                                                color: themeChange.getThem()
                                                                                                    ? AppThemeData.neutralDark900
                                                                                                    : AppThemeData.neutral900),
                                                                                          )
                                                                                        : Text(
                                                                                            '${controller.bookingModel.value.data!.driver!.prenom} ${controller.bookingModel.value.data!.driver!.nom}'
                                                                                                .tr,
                                                                                            textAlign: TextAlign.center,
                                                                                            style: AppThemeData.boldTextStyle(
                                                                                                fontSize: 16,
                                                                                                color: themeChange.getThem()
                                                                                                    ? AppThemeData.neutralDark900
                                                                                                    : AppThemeData.neutral900),
                                                                                          ),
                                                                                    SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    Row(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          controller.bookingModel.value.data!.driver!
                                                                                              .vehicleDetails!.brand
                                                                                              .toString()
                                                                                              .tr,
                                                                                          textAlign: TextAlign.center,
                                                                                          style: AppThemeData.mediumTextStyle(
                                                                                              fontSize: 12,
                                                                                              color: themeChange.getThem()
                                                                                                  ? AppThemeData.neutralDark700
                                                                                                  : AppThemeData.neutral700),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding:
                                                                                              const EdgeInsets.symmetric(horizontal: 5),
                                                                                          child: Icon(
                                                                                            Icons.circle_sharp,
                                                                                            size: 8,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          controller.bookingModel.value.data!.driver!
                                                                                              .vehicleDetails!.model
                                                                                              .toString()
                                                                                              .tr,
                                                                                          textAlign: TextAlign.center,
                                                                                          style: AppThemeData.semiBoldTextStyle(
                                                                                              fontSize: 12,
                                                                                              color: themeChange.getThem()
                                                                                                  ? AppThemeData.neutralDark700
                                                                                                  : AppThemeData.neutral700),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 20,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 10),
                                                                                child: controller.bookingModel.value.data!.statut ==
                                                                                            RideStatus.confirmed ||
                                                                                        controller.bookingModel.value.data!.statut ==
                                                                                            RideStatus.onRide
                                                                                    ? Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          InkWell(
                                                                                            onTap: () {
                                                                                              Constant.makePhoneCall(controller
                                                                                                  .bookingModel.value.data!.driver!.phone!);
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
                                                                                                "receiverId": controller
                                                                                                    .bookingModel.value.data!.driver!.id,
                                                                                                "orderId":
                                                                                                    controller.bookingModel.value.data!.id,
                                                                                                "receiverName":
                                                                                                    "${controller.bookingModel.value.data!.driver!.prenom} ${controller.bookingModel.value.data!.driver!.nom}",
                                                                                                "receiverPhoto": controller
                                                                                                    .bookingModel.value.data!.driver!.image
                                                                                              });
                                                                                            },
                                                                                            child: SvgPicture.asset(
                                                                                              "assets/icons/ic_chat_details.svg",
                                                                                              width: 36,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : SizedBox(),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Constant.shouldShowRideOtp(controller.bookingModel.value.data!)
                                                                              ? Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        'One time Pass'.tr,
                                                                                        textAlign: TextAlign.start,
                                                                                        style: AppThemeData.semiBoldTextStyle(
                                                                                            fontSize: 14,
                                                                                            color: themeChange.getThem()
                                                                                                ? AppThemeData.neutralDark700
                                                                                                : AppThemeData.neutral700),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      controller.bookingModel.value.data!.otp!.tr,
                                                                                      textAlign: TextAlign.start,
                                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                                          fontSize: 14,
                                                                                          color: themeChange.getThem()
                                                                                              ? AppThemeData.primaryDark
                                                                                              : AppThemeData.primaryDark),
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              : SizedBox(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      controller.bookingModel.value.data!.statut == RideStatus.confirmed ||
                                                              controller.bookingModel.value.data!.statut == RideStatus.onRide
                                                          ? Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Get.to(LiveTrackingScreen(),
                                                                      arguments: {"orderModel": controller.bookingModel.value.data});
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    SvgPicture.asset("assets/icons/road-map-line.svg"),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'Track Ride'.tr,
                                                                      textAlign: TextAlign.center,
                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                          fontSize: 12,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.accentDefault
                                                                              : AppThemeData.accentDefault),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                      controller.bookingModel.value.data!.statut == RideStatus.onRide
                                                          ? Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Get.to(RidePaymentScreen(), arguments: {
                                                                    "bookingModel": controller.bookingModel.value.data!,
                                                                    "type": "ride"
                                                                  })!.then((value) {
                                                                    if(value ==true){
                                                                      controller.getBooking();
                                                                    }
                                                                  });
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    SvgPicture.asset("assets/icons/ic_pay.svg"),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'Pay Now'.tr,
                                                                      textAlign: TextAlign.center,
                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                          fontSize: 12,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.successDefault
                                                                              : AppThemeData.successDefault),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                      controller.bookingModel.value.data!.statut == RideStatus.newRide
                                                          ? Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  final currentAmount = double.tryParse(
                                                                          controller.bookingModel.value.data!.montant
                                                                                  ?.toString() ??
                                                                              "0") ??
                                                                      0.0;
                                                                  showFareBumpBottomSheet(
                                                                    context,
                                                                    currentAmount: currentAmount,
                                                                    presetAmounts: controller.fareBumpAmounts,
                                                                    onIncrease: (bump) =>
                                                                        controller.increaseFare(bump),
                                                                  );
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    Icon(
                                                                      Icons.flash_on_rounded,
                                                                      size: 24,
                                                                      color: themeChange.getThem()
                                                                          ? AppThemeData.warningDarkDefault
                                                                          : AppThemeData.warningDefault,
                                                                    ),
                                                                    SizedBox(height: 5),
                                                                    Text(
                                                                      'Increase Fare'.tr,
                                                                      textAlign: TextAlign.center,
                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                          fontSize: 12,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.warningDarkDefault
                                                                              : AppThemeData.warningDefault),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                      controller.bookingModel.value.data!.statut == RideStatus.newRide ||
                                                              controller.bookingModel.value.data!.statut == RideStatus.confirmed
                                                          ? Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  controller.cancelRequest();
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    SvgPicture.asset("assets/icons/close-fill.svg"),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'Cancel'.tr,
                                                                      textAlign: TextAlign.center,
                                                                      style: AppThemeData.semiBoldTextStyle(
                                                                          fontSize: 12,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.errorDefault
                                                                              : AppThemeData.errorDefault),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox()
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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

class BannerView extends StatelessWidget {
  final HomeOneController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: 180,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: controller.pageController.value,
        scrollDirection: Axis.horizontal,
        itemCount: controller.bannerList.length,
        padEnds: false,
        pageSnapping: true,
        allowImplicitScrolling: true,
        onPageChanged: (value) {
          controller.currentPage.value = value;
        },
        itemBuilder: (BuildContext context, int index) {
          BannerModelData bannerModel = controller.bannerList[index];
          return InkWell(
            onTap: () async {},
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Stack(
                  children: [
                    NetworkImageWidget(
                      imageUrl: bannerModel.image.toString(),
                      fit: BoxFit.cover,
                      width: Responsive.width(100, context),
                      height: Responsive.width(100, context),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bannerModel.title.tr,
                            textAlign: TextAlign.start,
                            style: AppThemeData.boldTextStyle(
                                fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50),
                          ),
                          Text(
                            bannerModel.description.tr,
                            textAlign: TextAlign.start,
                            style: AppThemeData.regularTextStyle(
                                fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutral200 : AppThemeData.neutral200),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
