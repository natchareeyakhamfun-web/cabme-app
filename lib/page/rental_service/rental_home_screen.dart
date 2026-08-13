import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/rental_home_controller.dart';
import 'package:cabme/model/rental_package_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:cabme/page/coupon_code_list/coupon_code_list_screen.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/themes/text_field_widget.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:cabme/utils/utils.dart';
import 'package:cabme/widget/osm_map/map_picker_page.dart';
import 'package:cabme/widget/place_picker/location_picker_screen.dart';
import 'package:cabme/widget/place_picker/selected_location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../themes/app_them_data.dart';

class RentalHomeScreen extends StatelessWidget {
  const RentalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RentalHomeController(),
        builder: (controller) {
          return Scaffold(
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Stack(
                    children: [
                      Constant.selectedMapType == "osm"
                          ? // OSM Map
                          flutterMap.FlutterMap(
                              mapController: controller.mapOsmController,
                              options: flutterMap.MapOptions(
                                initialCenter: latlong.LatLng(41.4219057, -102.0840772),
                                initialZoom: 10,
                              ),
                              children: [
                                flutterMap.TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: Platform.isAndroid ? "com.cabme" : "com.cabme.ios",
                                ),
                                flutterMap.MarkerLayer(markers: controller.osmMarker),
                                if (controller.routePoints.isNotEmpty)
                                  flutterMap.PolylineLayer(
                                    polylines: [
                                      flutterMap.Polyline(
                                        points: controller.routePoints,
                                        strokeWidth: 5.0,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                              ],
                            )
                          : GoogleMap(
                              onMapCreated: (googleMapController) {
                                controller.mapController = googleMapController;

                                if (Constant.currentLocation != null) {
                                  controller.setDepartureMarker(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
                                  controller.searchPlaceNameGoogle();
                                }
                              },
                              initialCameraPosition: CameraPosition(
                                target: controller.currentPosition.value,
                                zoom: 14,
                              ),

                              myLocationEnabled: true,
                              zoomControlsEnabled: true,
                              zoomGesturesEnabled: true,
                              markers: controller.markers.toSet(), // reactive marker set
                            ),
                      Positioned(
                        top: 50,
                        left: Constant.isRtl ? null : 20,
                        right: Constant.isRtl ? 20 : null,
                        child: InkWell(
                          onTap: () {
                            if (controller.bottomSheetType.value == "packageBottom") {
                              controller.bottomSheetType.value = "location";
                            } else if (controller.bottomSheetType.value == "payment") {
                              controller.bottomSheetType.value = "packageBottom";
                            } else if (controller.bottomSheetType.value == "conformBooking") {
                              controller.bottomSheetType.value = "payment";
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/icons/ic_back.svg",
                                colorFilter: ColorFilter.mode(
                                    themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ),
                      controller.bottomSheetType.value == "location"
                          ? locationBottomSheet(themeChange, controller)
                          : controller.bottomSheetType.value == "packageBottom"
                              ? packageBottomSheet(themeChange, controller)
                              : controller.bottomSheetType.value == "payment"
                                  ? paymentBottomSheet(themeChange, controller)
                                  : conformRideBottomSheet(themeChange, controller)
                    ],
                  ),
          );
        });
  }

  Widget locationBottomSheet(DarkThemeProvider themeChange, RentalHomeController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        // Start height
        minChildSize: 0.35,
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
                          'Plan your ride'.tr,
                          textAlign: TextAlign.center,
                          style: AppThemeData.boldTextStyle(
                              fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            TextFieldWidget(
                              readOnly: true,
                              controller: controller.sourceTextEditController.value,
                              onPress: () async {
                                if (Constant.selectedMapType == 'osm') {
                                  final result = await Get.to(() => MapPickerPage());
                                  if (result != null) {
                                    controller.sourceTextEditController.value.text = '';
                                    final firstPlace = result;
                                    final lat = firstPlace.coordinates.latitude;
                                    final lng = firstPlace.coordinates.longitude;
                                    final address = firstPlace.address;
                                    controller.sourceTextEditController.value.text = address.toString();
                                    controller.setDepartureMarker(lat, lng);
                                    controller.mapOsmController.move(latlong.LatLng(lat, lng), 12);
                                  }
                                } else {
                                  Get.to(LocationPickerScreen())!.then(
                                    (value) async {
                                      if (value != null) {
                                        SelectedLocationModel selectedLocationModel = value;

                                        controller.sourceTextEditController.value.text =
                                            Utils.formatAddress(selectedLocation: selectedLocationModel);
                                        controller.setDepartureMarker(
                                            selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                      }
                                    },
                                  );
                                }
                              },
                              hintText: 'Your current location'.tr,
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: SvgPicture.asset("assets/icons/ic_source.svg"),
                              ),
                              suffix: controller.sourceTextEditController.value.text.isEmpty
                                  ? null
                                  : InkWell(
                                      onTap: () {
                                        controller.removeSource();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Vehicle'.tr,
                              textAlign: TextAlign.center,
                              style: AppThemeData.boldTextStyle(
                                  fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListView.separated(
                              itemCount: controller.vehicleList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                VehicleData vehicleData = controller.vehicleList[index];
                                return Obx(
                                  () => Container(
                                    decoration: vehicleData == controller.selectedVehicle.value
                                        ? BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                                          )
                                        : null,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: InkWell(
                                      onTap: () {
                                        controller.selectedVehicle.value = vehicleData;
                                      },
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: NetworkImageWidget(
                                              imageUrl: vehicleData.image.toString(),
                                              width: Responsive.width(16, context),
                                              height: Responsive.height(8, context),
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
                                                vehicleData.libelle.toString().tr,
                                                textAlign: TextAlign.start,
                                                style: AppThemeData.boldTextStyle(
                                                    fontSize: 16,
                                                    color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "Compact, Convenient, and Cost-Effective!".tr,
                                                textAlign: TextAlign.start,
                                                style: AppThemeData.mediumTextStyle(
                                                    fontSize: 12,
                                                    color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 80, top: 10),
                                  child: Divider(
                                    color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: RoundedButtonFill(
                      title: "Done".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();
                        if (controller.sourceTextEditController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please select source location".tr);
                        } else {
                          controller.getRentalPackage(isReDirect: true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget packageBottomSheet(DarkThemeProvider themeChange, RentalHomeController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: 0.30,
        // Start height
        minChildSize: 0.30,
        // Minimum height
        maxChildSize: 0.8,
        // Maximum height
        expand: true,
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
                                    'Select Preferences'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.pickDateTime();
                                  },
                                  child: controller.pickUpDateTimeController.value.text.isNotEmpty
                                      ? Text(
                                          controller.pickUpDateTimeController.value.text,
                                          textAlign: TextAlign.center,
                                          style: AppThemeData.mediumTextStyle(
                                              fontSize: 14,
                                              color: themeChange.getThem() ? AppThemeData.neutral700 : AppThemeData.neutral700),
                                        )
                                      : Text(
                                          'Select Date'.tr,
                                          textAlign: TextAlign.center,
                                          style: AppThemeData.mediumTextStyle(
                                              fontSize: 14,
                                              color: themeChange.getThem() ? AppThemeData.neutral700 : AppThemeData.neutral700),
                                        ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SvgPicture.asset("assets/icons/ic_date_picker.svg")
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ListView.separated(
                              itemCount: controller.rentalPackageList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                RentalPackageData rentalPackage = controller.rentalPackageList[index];
                                return Obx(
                                  () => Container(
                                    decoration: rentalPackage == controller.selectedRentalPackage.value
                                        ? BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                                          )
                                        : null,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: InkWell(
                                      onTap: () {
                                        controller.selectedRentalPackage.value = rentalPackage;
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                rentalPackage.title.toString().tr,
                                                textAlign: TextAlign.start,
                                                style: AppThemeData.boldTextStyle(
                                                    fontSize: 16,
                                                    color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                rentalPackage.description.toString().tr,
                                                textAlign: TextAlign.start,
                                                style: AppThemeData.mediumTextStyle(
                                                    fontSize: 12,
                                                    color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                              ),
                                            ],
                                          )),
                                          Text(
                                            Constant().amountShow(amount: rentalPackage.baseFare.toString()).tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.boldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.primaryDefault : AppThemeData.primaryDefault),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 80, top: 10),
                                  child: Divider(
                                    color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: RoundedButtonFill(
                      title: "Next".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();
                        if (controller.selectedRentalPackage.value.id == null) {
                          ShowToastDialog.showToast("Please select package".tr);
                        } else {
                          controller.bottomSheetType.value = "payment";
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget paymentBottomSheet(DarkThemeProvider themeChange, RentalHomeController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: 0.50,
        // Start height
        minChildSize: 0.50,
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
                          style: AppThemeData.boldTextStyle(
                              fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: controller.paymentSettingModel.value.myWallet != null &&
                                  controller.paymentSettingModel.value.myWallet!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.myWallet!.libelle.toString(),
                                  themeChange, "assets/images/ic_wallet_image.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.cash != null &&
                                  controller.paymentSettingModel.value.cash!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.cash!.libelle.toString(), themeChange,
                                  "assets/images/ic_cash.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.strip != null &&
                                  controller.paymentSettingModel.value.strip!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.strip!.libelle.toString(), themeChange,
                                  "assets/images/stripe.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.payPal != null &&
                                  controller.paymentSettingModel.value.payPal!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.payPal!.libelle.toString(),
                                  themeChange, "assets/images/paypal.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.payStack != null &&
                                  controller.paymentSettingModel.value.payStack!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.payStack!.libelle.toString(),
                                  themeChange, "assets/images/paystack.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.mercadopago != null &&
                                  controller.paymentSettingModel.value.mercadopago!.isEnabled == "true",
                              child: cardDecoration(controller, "Mercado Pago", themeChange, "assets/images/mercado-pago.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.flutterWave != null &&
                                  controller.paymentSettingModel.value.flutterWave!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.flutterWave!.libelle.toString(),
                                  themeChange, "assets/images/flutterwave_logo.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.payFast != null &&
                                  controller.paymentSettingModel.value.payFast!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.payFast!.libelle.toString(),
                                  themeChange, "assets/images/payfast.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.razorpay != null &&
                                  controller.paymentSettingModel.value.razorpay!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.razorpay!.libelle.toString(),
                                  themeChange, "assets/images/razorpay.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.xendit != null &&
                                  controller.paymentSettingModel.value.xendit!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.xendit!.libelle.toString(),
                                  themeChange, "assets/images/xendit.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.orangePay != null &&
                                  controller.paymentSettingModel.value.orangePay!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.orangePay!.libelle.toString(),
                                  themeChange, "assets/images/orangeMoney.png"),
                            ),
                            Visibility(
                              visible: controller.paymentSettingModel.value.midtrans != null &&
                                  controller.paymentSettingModel.value.midtrans!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.midtrans!.libelle.toString(),
                                  themeChange, "assets/images/midtrans.png"),
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
                        controller.calculateAmountBeforeRide();
                        controller.bottomSheetType.value = "conformBooking";
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget conformRideBottomSheet(DarkThemeProvider themeChange, RentalHomeController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        // Start height
        minChildSize: 0.85,
        // Minimum height
        maxChildSize: 0.85,
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
                          'Confirm Booking'.tr,
                          textAlign: TextAlign.center,
                          style: AppThemeData.boldTextStyle(
                              fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Your Preferences'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.bottomSheetType.value = "packageBottom";
                                  },
                                  child: Text(
                                    'Change'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.selectedRentalPackage.value.title.toString().tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    controller.selectedRentalPackage.value.description.toString().tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.mediumTextStyle(
                                        fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ],
                              ),
                            )
                          ],
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
                                    'Vehicle Type'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.bottomSheetType.value = "location";
                                  },
                                  child: Text(
                                    'Change'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: NetworkImageWidget(
                                      imageUrl: controller.selectedVehicle.value.image.toString(),
                                      width: Responsive.width(16, context),
                                      height: Responsive.height(8, context),
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
                                        controller.selectedVehicle.value.libelle.toString().tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.boldTextStyle(
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Compact, Convenient, and Cost-Effective!".tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.mediumTextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            )
                          ],
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
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(CouponCodeListScreen(), arguments: {"type": "Rental"})!.then(
                                      (value) {
                                        if (value != null) {
                                          controller.selectedDiscount.value = value['discount'];
                                          controller.couponCodeTextEditController.value.text =
                                              controller.selectedDiscount.value.code.toString();
                                          controller.calculateAmountBeforeRide();
                                        }
                                      },
                                    );
                                  },
                                  child: Text(
                                    "View Coupons".tr,
                                    textAlign: TextAlign.center,
                                    style: AppThemeData.mediumTextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault,
                                        decoration: TextDecoration.underline),
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
                                    hintText: 'Enter Code'.tr,
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
                                    if (controller.discountList
                                        .where((p0) =>
                                            p0.code!.toLowerCase() == controller.couponCodeTextEditController.value.text.toLowerCase())
                                        .isNotEmpty) {
                                      controller.selectedDiscount.value = controller.discountList.firstWhere((p0) =>
                                          p0.code!.toLowerCase() == controller.couponCodeTextEditController.value.text.toLowerCase());
                                      controller.calculateAmountBeforeRide();
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
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ride Cost:'.tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.semiBoldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.subTotalBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Coupon Discount'.tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.semiBoldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.discountBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Total Cost:'.tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.semiBoldTextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.totalBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: AppThemeData.warningDefault,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    "Tax Excluded — Final Fare Calculated After Your Trip.".tr,
                                    style: AppThemeData.mediumTextStyle(color: AppThemeData.warningDefault),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.bottomSheetType.value = "payment";
                                  },
                                  child: Text(
                                    'Change'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 14,
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
                                    controller.paymentSettingModel.value.cash!.libelle == controller.selectedPaymentMethod.value
                                        ? "assets/images/ic_cash.png"
                                        : controller.paymentSettingModel.value.myWallet!.libelle == controller.selectedPaymentMethod.value
                                            ? "assets/images/ic_cash.png"
                                            : controller.paymentSettingModel.value.strip!.libelle == controller.selectedPaymentMethod.value
                                                ? "assets/images/stripe.png"
                                                : controller.paymentSettingModel.value.payPal!.libelle ==
                                                        controller.selectedPaymentMethod.value
                                                    ? "assets/images/paypal.png"
                                                    : controller.paymentSettingModel.value.payStack!.libelle ==
                                                            controller.selectedPaymentMethod.value
                                                        ? "assets/images/paystack.png"
                                                        : controller.paymentSettingModel.value.mercadopago!.libelle ==
                                                                controller.selectedPaymentMethod.value
                                                            ? "assets/images/mercado-pago.png"
                                                            : controller.paymentSettingModel.value.flutterWave!.libelle ==
                                                                    controller.selectedPaymentMethod.value
                                                                ? "assets/images/flutterwave_logo.png"
                                                                : controller.paymentSettingModel.value.payFast!.libelle ==
                                                                        controller.selectedPaymentMethod.value
                                                                    ? "assets/images/payfast.png"
                                                                    : controller.paymentSettingModel.value.razorpay!.libelle ==
                                                                            controller.selectedPaymentMethod.value
                                                                        ? "assets/images/razorpay.png"
                                                                        : controller.paymentSettingModel.value.xendit!.libelle ==
                                                                                controller.selectedPaymentMethod.value
                                                                            ? "assets/images/xendit.png"
                                                                            : controller.paymentSettingModel.value.orangePay!.libelle ==
                                                                                    controller.selectedPaymentMethod.value
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
                                    style: AppThemeData.boldTextStyle(
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    child: RoundedButtonFill(
                      title: "Book ride".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();
                        controller.bookRide();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget cardDecoration(RentalHomeController controller, String value, themeChange, String image) {
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
                value == controller.paymentSettingModel.value.myWallet!.libelle
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Wallet".tr,
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
          Divider(
            color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
            height: 1,
          )
        ],
      ),
    );
  }
}
