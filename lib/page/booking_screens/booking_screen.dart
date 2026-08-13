import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/booking_controller.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/model/parcel_bokking_model.dart';
import 'package:cabme/model/rental_booking_model.dart';
import 'package:cabme/page/add_complaints/add_complaints_screen.dart';
import 'package:cabme/page/booking_details_screens/booking_details_screen.dart';
import 'package:cabme/page/booking_screens/parcel_details_screen.dart';
import 'package:cabme/page/chats_screen/conversation_screen.dart';
import 'package:cabme/page/home_screens/ride_payment_screen.dart';
import 'package:cabme/page/live_tracking_screen/live_tracking_screen.dart';
import 'package:cabme/page/rating_screen/rating_screen.dart';
import 'package:cabme/page/rental_service/rental_details_screen.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../themes/app_them_data.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingController(),
        builder: (controller) {
          return DefaultTabController(
            length: 4, // Number of tabs
            child: Scaffold(
              backgroundColor: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral200,
              appBar: AppBar(
                backgroundColor: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral200,
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Text(
                  "Bookings".tr,
                  style: AppThemeData.semiBoldTextStyle(
                      fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                ),
                bottom: TabBar(
                  isScrollable: true,
                  // Set to true if many tabs
                  labelColor: themeChange.getThem() ? AppThemeData.primaryDark : AppThemeData.primaryDark,
                  unselectedLabelColor: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700,
                  indicatorColor: themeChange.getThem() ? AppThemeData.primaryDark : AppThemeData.primaryDark,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  tabs: [
                    Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text('New'.tr),
                    )),
                    Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text('Ongoing'.tr),
                    )),
                    Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text('Completed'.tr),
                    )),
                    Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text('Cancelled'.tr),
                    )),
                  ],
                ),
                actions: [
                  CompositedTransformTarget(
                    link: controller.layerLink,
                    child: InkWell(
                      key: controller.overlayKey,
                      onTap: () {
                        showOverlay(context, controller);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SvgPicture.asset(
                          "assets/icons/ic_filter.svg",
                          colorFilter: ColorFilter.mode(
                              themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: controller.isLoading.value
                  ? Constant.loader(context)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: controller.bookingType.value == "Ride Booking"
                          ? TabBarView(
                              children: [
                                newBookingWidget(themeChange, controller, controller.newList),
                                newBookingWidget(themeChange, controller, controller.onGoingList),
                                newBookingWidget(themeChange, controller, controller.completedList),
                                newBookingWidget(themeChange, controller, controller.cancelledList),
                              ],
                            )
                          : controller.bookingType.value == "Parcel Delivery"
                              ? TabBarView(
                                  children: [
                                    newParcelBookingWidget(themeChange, controller, controller.newParcelList),
                                    newParcelBookingWidget(themeChange, controller, controller.onGoingParcelList),
                                    newParcelBookingWidget(themeChange, controller, controller.completedParcelList),
                                    newParcelBookingWidget(themeChange, controller, controller.cancelledParcelList),
                                  ],
                                )
                              : TabBarView(children: [
                                  rentalBookingWidget(themeChange, controller, controller.newRentalList),
                                  rentalBookingWidget(themeChange, controller, controller.onGoingRentalList),
                                  rentalBookingWidget(themeChange, controller, controller.completedRentalList),
                                  rentalBookingWidget(themeChange, controller, controller.cancelledRentalList),
                                ]),
                    ),
            ),
          );
        });
  }

  Widget newBookingWidget(DarkThemeProvider themeChange, BookingController controller, List<BookingData> list) {
    return list.isEmpty
        ? Constant.showEmptyView(message: "Booking not Found".tr)
        : RefreshIndicator(
            onRefresh: () => controller.getBookingList(),
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                BookingData bookingData = list[index];
                List<Stops> locationData = <Stops>[];
                locationData.add(
                    Stops(location: bookingData.departName, latitude: bookingData.latitudeDepart, longitude: bookingData.longitudeDepart));
                if (bookingData.stops != null) {
                  locationData
                      .addAll(bookingData.stops!.map((e) => Stops(location: e.location, latitude: e.latitude, longitude: e.longitude)));
                }
                locationData.add(Stops(
                    location: bookingData.destinationName, latitude: bookingData.latitudeArrivee, longitude: bookingData.longitudeArrivee));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.to(BookingDetailsScreen(), arguments: {"bookingModel": bookingData})!.then(
                          (value) {
                            if (value != null) {
                              if (value == true) {
                                controller.getBookingList();
                              }
                            }
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            bookingData.statut == RideStatus.newRide || bookingData.statut == RideStatus.canceled
                                ? Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: 100,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: themeChange.getThem() ? AppThemeData.successLight : AppThemeData.successLight),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                            child: Center(
                                              child: Text(
                                                "${bookingData.statut}",
                                                style: AppThemeData.semiBoldTextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
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
                                                  : locationData.length - 1 == index
                                                      ? SvgPicture.asset("assets/icons/ic_recevier.svg")
                                                      : Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                              color: AppThemeData.neutral900, borderRadius: BorderRadius.circular(40)),
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
                                                color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                                                gap: 4,
                                              );
                                            },
                                            contentsBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                child: Text(
                                                  "${locationData[index].location}",
                                                  style: AppThemeData.mediumTextStyle(
                                                      fontSize: 14,
                                                      color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                ),
                                              );
                                            },
                                            itemCount: locationData.length,
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
                                                imageUrl:
                                                    bookingData.driver == null ? '' : bookingData.driver!.vehicleDetails!.image.toString(),
                                                width: 105,
                                                height: 100,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 5,
                                              left: 6,
                                              right: 6,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: themeChange.getThem() ? AppThemeData.successLight : AppThemeData.successLight),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                  child: Center(
                                                    child: Text(
                                                      "${bookingData.statut}",
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
                                      Expanded(
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
                                                        Text(
                                                          bookingData.creer.toString(),
                                                          textAlign: TextAlign.center,
                                                          style: AppThemeData.mediumTextStyle(
                                                              fontSize: 12,
                                                              color: themeChange.getThem()
                                                                  ? AppThemeData.neutralDark700
                                                                  : AppThemeData.neutral700),
                                                        ),
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                        bookingData.statut == RideStatus.newRide
                                                            ? Text(
                                                                '${bookingData.driver == null ? "N/A" : bookingData.driver!.vehicleDetails!.type}'
                                                                    .tr,
                                                                textAlign: TextAlign.center,
                                                                style: AppThemeData.boldTextStyle(
                                                                    fontSize: 16,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData.neutralDark900
                                                                        : AppThemeData.neutral900),
                                                              )
                                                            : Text(
                                                                (bookingData.driver == null
                                                                        ? "N/A"
                                                                        : '${bookingData.driver!.prenom} ${bookingData.driver!.nom}')
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
                                                              bookingData.driver == null
                                                                  ? "N/A"
                                                                  : bookingData.driver!.vehicleDetails!.brand.toString().tr,
                                                              textAlign: TextAlign.center,
                                                              style: AppThemeData.mediumTextStyle(
                                                                  fontSize: 12,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData.neutralDark700
                                                                      : AppThemeData.neutral700),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                              child: Icon(
                                                                Icons.circle_sharp,
                                                                size: 8,
                                                              ),
                                                            ),
                                                            Text(
                                                              bookingData.driver == null
                                                                  ? "N/A"
                                                                  : bookingData.driver!.vehicleDetails!.model.toString().tr,
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
                                                    child: bookingData.statut == RideStatus.confirmed ||
                                                            bookingData.statut == RideStatus.onRide
                                                        ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Constant.makePhoneCall(bookingData.driver!.phone!);
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
                                                                    "receiverId": bookingData.driver!.id,
                                                                    "orderId": bookingData.id,
                                                                    "receiverName":
                                                                        "${bookingData.driver!.prenom} ${bookingData.driver!.nom}",
                                                                    "receiverPhoto": bookingData.driver!.image
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
                                              Constant.shouldShowRideOtp(bookingData)
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
                                                          bookingData.otp!.tr,
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
                                bookingData.statut == RideStatus.confirmed || bookingData.statut == RideStatus.onRide
                                    ?  Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(LiveTrackingScreen(), arguments: {"orderModel": bookingData});
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
                                                    color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                bookingData.statut == RideStatus.onRide
                                    ? SizedBox()
                                    : Expanded(
                                        child: Column(
                                          children: [
                                            SvgPicture.asset("assets/icons/ic_show_details.svg"),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'View Details'.tr,
                                              textAlign: TextAlign.center,
                                              style: AppThemeData.semiBoldTextStyle(
                                                  fontSize: 12,
                                                  color: themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                            )
                                          ],
                                        ),
                                      ),
                                bookingData.statut == RideStatus.onRide
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(RidePaymentScreen(), arguments: {"bookingModel": bookingData, "type": "ride"})!.then(
                                              (value) {
                                                if (value == true) {
                                                  controller.getBookingList();
                                                }
                                              },
                                            );
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
                                                    color:
                                                        themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                bookingData.statut == RideStatus.newRide || bookingData.statut == RideStatus.confirmed
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.cancelRequest(bookingData);
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
                                                    color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                bookingData.statut == RideStatus.onRide
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            controller.sosRequest(bookingData);
                                          },
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/sos.svg",
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'SOS'.tr,
                                                textAlign: TextAlign.center,
                                                style: AppThemeData.semiBoldTextStyle(
                                                    fontSize: 12,
                                                    color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                bookingData.statut == RideStatus.completed
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(RatingScreen(), arguments: {"bookingType": "ride", "bookingModel": bookingData})!.then(
                                              (value) {
                                                if (value != null) {
                                                  if (value == true) {
                                                    controller.getBookingList();
                                                  }
                                                }
                                              },
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_rating_icon.svg",
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Add Rating'.tr,
                                                textAlign: TextAlign.center,
                                                style: AppThemeData.semiBoldTextStyle(
                                                    fontSize: 12,
                                                    color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                bookingData.statut == RideStatus.completed
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(AddComplaintsScreen(), arguments: {"bookingModel": bookingData, "bookingType": "ride"})!
                                                .then(
                                              (value) {
                                                if (value != null) {
                                                  if (value == true) {
                                                    controller.getBookingList();
                                                  }
                                                }
                                              },
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/complain.svg",
                                                height: 30,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Complain'.tr,
                                                textAlign: TextAlign.center,
                                                style: AppThemeData.semiBoldTextStyle(
                                                    fontSize: 12,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.primaryDarkDark
                                                        : AppThemeData.primaryDarkDark),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget newParcelBookingWidget(DarkThemeProvider themeChange, BookingController controller, List<ParcelBookingData> list) {
    return list.isEmpty
        ? Constant.showEmptyView(message: "Parcel booking not found".tr)
        : RefreshIndicator(
            onRefresh: () => controller.getBookingList(),
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ParcelBookingData parcelBookingData = list[index];
                return InkWell(
                  onTap: () {
                    Get.to(ParcelDetailsScreen(), arguments: {"parcelBookingData": parcelBookingData});
                  },
                  child: Container(
                    width: Responsive.width(100, context),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadows: [
                        BoxShadow(
                          color: themeChange.getThem() ? AppThemeData.neutralDark200 : Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      : index == 1
                                          ? SvgPicture.asset("assets/icons/ic_recevier.svg")
                                          : SizedBox();
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
                                      index == 0 ? "${parcelBookingData.source}" : "${parcelBookingData.destination}",
                                      style: AppThemeData.mediumTextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                    ),
                                  );
                                },
                                itemCount: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            parcelBookingData.driver == null
                                ? SizedBox()
                                : NetworkImageWidget(
                                    imageUrl: parcelBookingData.driver!.image.toString(),
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                  ),
                            SizedBox(
                              width: 10,
                            ),
                            parcelBookingData.driver != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${parcelBookingData.driver!.prenom} ${parcelBookingData.driver!.nom}'.tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.boldTextStyle(
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width: 75,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: themeChange.getThem() ? AppThemeData.successLight : AppThemeData.successLight),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          child: Row(
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
                                                "${parcelBookingData.driver!.averageRating}",
                                                style: AppThemeData.mediumTextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox()
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ic_amount.svg",
                                    colorFilter: ColorFilter.mode(
                                        themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    Constant().amountShow(amount: controller.calculateParcelTotalAmountBooking(parcelBookingData)).tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(
                                        fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/ic_date.svg",
                                    colorFilter: ColorFilter.mode(
                                        themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${parcelBookingData.receiveDate}  '.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(
                                        fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  NetworkImageWidget(
                                    imageUrl: parcelBookingData.parcelTypeImage.toString(),
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${parcelBookingData.parcelType}'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(
                                        fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SvgPicture.asset("assets/icons/ic_show_details.svg"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'View Details'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppThemeData.semiBoldTextStyle(
                                        fontSize: 12,
                                        color: themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                  )
                                ],
                              ),
                            ),
                            parcelBookingData.status == RideStatus.newRide
                                ? Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        controller.cancelParcelRequest(parcelBookingData);
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
                                                color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            parcelBookingData.status == RideStatus.completed
                                ? Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(AddComplaintsScreen(),
                                                arguments: {"parcelBookingData": parcelBookingData, "bookingType": "parcel"})!
                                            .then(
                                          (value) {
                                            if (value != null) {
                                              if (value == true) {
                                                controller.getBookingList();
                                              }
                                            }
                                          },
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/complain.svg",
                                            height: 30,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Complain'.tr,
                                            textAlign: TextAlign.center,
                                            style: AppThemeData.semiBoldTextStyle(
                                                fontSize: 12,
                                                color: themeChange.getThem() ? AppThemeData.primaryDarkDark : AppThemeData.primaryDarkDark),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget rentalBookingWidget(DarkThemeProvider themeChange, BookingController controller, List<RentalBookingData> list) {
    return list.isEmpty
        ? Constant.showEmptyView(message: "Rental Booking not Found")
        : RefreshIndicator(
            onRefresh: () => controller.getBookingList(),
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                RentalBookingData bookingData = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.to(RentalDetailsScreen(), arguments: {"rentalBookingData": bookingData});
                      },
                      child: Column(
                        children: [
                          bookingData.status == RideStatus.newRide
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          border: Border.all(
                                              color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.timer_sharp),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Awaiting Driver".tr,
                                                style: AppThemeData.semiBoldTextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Rental Package:".tr,
                                        style: AppThemeData.boldTextStyle(
                                            fontSize: 14,
                                            color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                      Text(
                                        "${bookingData.packageDetails!.title}",
                                        style: AppThemeData.boldTextStyle(
                                            fontSize: 18,
                                            color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month,
                                              color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Date:".tr,
                                              style: AppThemeData.boldTextStyle(
                                                  fontSize: 14,
                                                  color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                            ),
                                          ),
                                          Text(
                                            "${bookingData.startDate}",
                                            style: AppThemeData.boldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.timer_outlined,
                                              color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Time:".tr,
                                              style: AppThemeData.boldTextStyle(
                                                  fontSize: 14,
                                                  color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                            ),
                                          ),
                                          Text(
                                            "${bookingData.startTime}",
                                            style: AppThemeData.boldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ],
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
                                                return SvgPicture.asset("assets/icons/ic_sender.svg");
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
                                                    "${bookingData.departName}",
                                                    style: AppThemeData.mediumTextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                  ),
                                                );
                                              },
                                              itemCount: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "You’ll be notified once a driver is assigned to your booking.".tr,
                                        textAlign: TextAlign.center,
                                        style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: AppThemeData.primaryDark),
                                      )
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      bookingData.status == RideStatus.newRide || bookingData.status == RideStatus.canceled
                                          ? Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 120,
                                                      child: Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(8),
                                                            child: NetworkImageWidget(
                                                              imageUrl: bookingData.vehicleImage.toString(),
                                                              width: 105,
                                                              height: 100,
                                                              fit: BoxFit.fill,
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
                                                                    "${bookingData.status}",
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
                                                      width: 10,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 20),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${bookingData.packageDetails!.title}'.tr,
                                                            textAlign: TextAlign.start,
                                                            style: AppThemeData.boldTextStyle(
                                                                fontSize: 16,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData.neutralDark700
                                                                    : AppThemeData.neutral700),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            '${bookingData.startDate} ${bookingData.endDate}'.tr,
                                                            textAlign: TextAlign.start,
                                                            style: AppThemeData.mediumTextStyle(
                                                                fontSize: 14,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData.neutralDark700
                                                                    : AppThemeData.neutral700),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 14,
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
                                                        return SvgPicture.asset("assets/icons/ic_sender.svg");
                                                      },
                                                      connectorBuilder: (context, index, connectorType) {
                                                        return DashedLineConnector(
                                                          color:
                                                              themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                                                          gap: 4,
                                                        );
                                                      },
                                                      contentsBuilder: (context, index) {
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                          child: Text(
                                                            "${bookingData.departName}",
                                                            style: AppThemeData.mediumTextStyle(
                                                                fontSize: 14,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData.neutralDark900
                                                                    : AppThemeData.neutral900),
                                                          ),
                                                        );
                                                      },
                                                      itemCount: 1,
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
                                                          imageUrl: bookingData.vehicleImage.toString(),
                                                          width: 105,
                                                          height: 100,
                                                          fit: BoxFit.fill,
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
                                                                "${bookingData.status}",
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
                                                Expanded(
                                                  child: bookingData.driver == null
                                                      ? SizedBox()
                                                      : Padding(
                                                          padding: const EdgeInsets.only(top: 5),
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
                                                                        bookingData.status == RideStatus.newRide
                                                                            ? Text(
                                                                                '${bookingData.driver!.vehicleDetails!.type}'.tr,
                                                                                textAlign: TextAlign.center,
                                                                                style: AppThemeData.boldTextStyle(
                                                                                    fontSize: 16,
                                                                                    color: themeChange.getThem()
                                                                                        ? AppThemeData.neutralDark900
                                                                                        : AppThemeData.neutral900),
                                                                              )
                                                                            : Text(
                                                                                '${bookingData.driver!.prenom} ${bookingData.driver!.nom}'
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
                                                                              bookingData.driver!.vehicleDetails!.brand.toString().tr,
                                                                              textAlign: TextAlign.center,
                                                                              style: AppThemeData.mediumTextStyle(
                                                                                  fontSize: 12,
                                                                                  color: themeChange.getThem()
                                                                                      ? AppThemeData.neutralDark700
                                                                                      : AppThemeData.neutral700),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                              child: Icon(
                                                                                Icons.circle_sharp,
                                                                                size: 8,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              bookingData.driver!.vehicleDetails!.model.toString().tr,
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
                                                                    child: bookingData.status == RideStatus.confirmed ||
                                                                            bookingData.status == RideStatus.onRide
                                                                        ? Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Constant.makePhoneCall(bookingData.driver!.phone!);
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
                                                                                    "receiverId": bookingData.driver!.id,
                                                                                    "orderId": bookingData.id,
                                                                                    "receiverName":
                                                                                        "${bookingData.driver!.prenom} ${bookingData.driver!.nom}",
                                                                                    "receiverPhoto": bookingData.driver!.image
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
                                                              Constant.shouldRentalShowRideOtp(bookingData)
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
                                                                          bookingData.otp!.tr,
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
                                                              Row(
                                                                children: [
                                                                  Icon(Icons.calendar_month,
                                                                      color: themeChange.getThem()
                                                                          ? AppThemeData.neutralDark700
                                                                          : AppThemeData.neutral700),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Date:".tr,
                                                                      style: AppThemeData.boldTextStyle(
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.neutralDark700
                                                                              : AppThemeData.neutral700),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "${bookingData.startDate}",
                                                                    style: AppThemeData.boldTextStyle(
                                                                        fontSize: 16,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.neutralDark700
                                                                            : AppThemeData.neutral700),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(Icons.timer_outlined,
                                                                      color: themeChange.getThem()
                                                                          ? AppThemeData.neutralDark700
                                                                          : AppThemeData.neutral700),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Time:".tr,
                                                                      style: AppThemeData.boldTextStyle(
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.neutralDark700
                                                                              : AppThemeData.neutral700),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "${bookingData.startTime}",
                                                                    style: AppThemeData.boldTextStyle(
                                                                        fontSize: 16,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.neutralDark700
                                                                            : AppThemeData.neutral700),
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
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SvgPicture.asset("assets/icons/ic_show_details.svg",
                                        color: themeChange.getThem() ? AppThemeData.infoDefault : AppThemeData.infoDefault),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'View Details'.tr,
                                      textAlign: TextAlign.center,
                                      style: AppThemeData.semiBoldTextStyle(
                                          fontSize: 12, color: themeChange.getThem() ? AppThemeData.infoDefault : AppThemeData.infoDefault),
                                    )
                                  ],
                                ),
                              ),
                              bookingData.status == RideStatus.onRide
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (bookingData.completeKm == "0") {
                                            ShowToastDialog.showToast(
                                                "You are not able to pay now untile driver will not added a kilometer".tr);
                                          } else {
                                            Get.to(RidePaymentScreen(), arguments: {"rentalBookingModel": bookingData, "type": "rental"})!
                                                .then(
                                              (value) {
                                                if (value == true) {
                                                  controller.getBookingList();
                                                }
                                              },
                                            );
                                          }
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
                                                  color: themeChange.getThem() ? AppThemeData.successDefault : AppThemeData.successDefault),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              bookingData.status == RideStatus.newRide || bookingData.status == RideStatus.confirmed
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.cancelRentalRequest(bookingData);
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
                                                  color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              bookingData.status == RideStatus.completed
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(AddComplaintsScreen(),
                                                  arguments: {"rentalBookingData": bookingData, "bookingType": "rental"})!
                                              .then(
                                            (value) {
                                              if (value != null) {
                                                if (value == true) {
                                                  controller.getBookingList();
                                                }
                                              }
                                            },
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/complain.svg",
                                              height: 30,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Complain'.tr,
                                              textAlign: TextAlign.center,
                                              style: AppThemeData.semiBoldTextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      themeChange.getThem() ? AppThemeData.primaryDarkDark : AppThemeData.primaryDarkDark),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
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

  void showOverlay(BuildContext context, BookingController controller) {
    final OverlayState overlayState = Overlay.of(context);
    final RenderBox renderBox = controller.overlayKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => entry.remove(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 10,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.types.map((type) {
                      bool selected = controller.bookingType.value == type;
                      return GestureDetector(
                        onTap: () {
                          controller.selectType(type);
                          controller.getBookingList();
                          entry.remove();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  type.tr,
                                  style: TextStyle(
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected ? Colors.amber : Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: selected ? Colors.amber : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(entry);
  }
}
