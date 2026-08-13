import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/book_ride_controller.dart';
import 'package:cabme/model/booking_request_model.dart';
import 'package:cabme/model/tax_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:cabme/page/chats_screen/conversation_screen.dart';
import 'package:cabme/page/coupon_code_list/coupon_code_list_screen.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:cabme/utils/utils.dart';
import 'package:cabme/widget/fare_bump_content.dart';
import 'package:cabme/widget/osm_map/map_picker_page.dart';
import 'package:cabme/widget/place_picker/location_picker_screen.dart';
import 'package:cabme/widget/place_picker/selected_location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:timelines_plus/timelines_plus.dart';
import '../../themes/app_them_data.dart';
import '../../themes/text_field_widget.dart';

class BookRideScreen extends StatelessWidget {
  const BookRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookRideController(),
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
                              polylines: Set<Polyline>.of(controller.polyLines.values),
                              markers: controller.markers.toSet(), // reactive marker set
                            ),
                      Positioned(
                        top: 50,
                        left: Constant.isRtl ? null : 20,
                        right: Constant.isRtl ? 20 : null,
                        child: InkWell(
                          onTap: () {
                            if (controller.bottomSheetType.value == "preferences") {
                              controller.bottomSheetType.value = "location";
                            } else if (controller.bottomSheetType.value == "payment") {
                              controller.bottomSheetType.value = "preferences";
                            } else if (controller.bottomSheetType.value == "conformRide") {
                              controller.bottomSheetType.value = "payment";
                            } else if (controller.bottomSheetType.value == "waitingDriver" || controller.bottomSheetType.value == "driverDetails") {
                              Get.back(result: true);
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50, borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/icons/ic_back.svg",
                                colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ),
                      controller.bottomSheetType.value == "location"
                          ? locationBottomSheet(themeChange, controller)
                          : controller.bottomSheetType.value == "preferences"
                              ? preferencesBottomSheet(themeChange, controller)
                              : controller.bottomSheetType.value == "payment"
                                  ? paymentBottomSheet(themeChange, controller)
                                  : controller.bottomSheetType.value == "conformRide"
                                      ? conformRideBottomSheet(themeChange, controller)
                                      : controller.bottomSheetType.value == "driverDetails"
                                          ? driverDetailsBottomSheet(themeChange, controller)
                                          : waitingRideBottomSheet(themeChange, controller)
                    ],
                  ),
          );
        });
  }

  Widget locationBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
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
                          style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFieldWidget(
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
                                        }
                                      } else {
                                        Get.to(LocationPickerScreen())!.then(
                                          (value) async {
                                            if (value != null) {
                                              SelectedLocationModel selectedLocationModel = value;

                                              controller.sourceTextEditController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                              controller.setDepartureMarker(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                            }
                                          },
                                        );
                                      }
                                    },
                                    hintText: 'Your current location',
                                    prefix: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: SvgPicture.asset("assets/icons/ic_source.svg"),
                                    ),
                                    suffix: controller.sourceTextEditController.value.text.isEmpty
                                        ? null
                                        : InkWell(
                                            onTap: () {
                                              print("====>");
                                              controller.removeSource();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Icon(Icons.close),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Obx(
                                  () => controller.multiStopList.isNotEmpty
                                      ? SizedBox()
                                      : Container(
                                          decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutralDark50, borderRadius: BorderRadius.circular(30)),
                                          child: InkWell(
                                            onTap: () {
                                              controller.addStops();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.add,
                                                color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                              ),
                                            ),
                                          ),
                                        ),
                                )
                              ],
                            ),
                            Obx(
                              () => ReorderableListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  for (int index = 0; index < controller.multiStopList.length; index += 1)
                                    Container(
                                      key: ValueKey(controller.multiStopList[index]),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFieldWidget(
                                              onPress: () async {
                                                if (Constant.selectedMapType == 'osm') {
                                                  final result = await Get.to(() => MapPickerPage());
                                                  if (result != null) {
                                                    final firstPlace = result;
                                                    final lat = firstPlace.coordinates.latitude;
                                                    final lng = firstPlace.coordinates.longitude;
                                                    controller.multiStopList[index].latitude = '${lat ?? '0'}';
                                                    controller.multiStopList[index].longitude = '${lng ?? '0'}';
                                                    final address = firstPlace.address;
                                                    controller.multiStopList[index].editingController.text = address.toString();
                                                    controller.setStopMarker(lat, lng, index);
                                                  }
                                                } else {
                                                  Get.to(LocationPickerScreen())!.then(
                                                    (value) async {
                                                      if (value != null) {
                                                        SelectedLocationModel selectedLocationModel = value;

                                                        controller.multiStopList[index].editingController.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                                        controller.multiStopList[index].latitude = selectedLocationModel.latLng!.latitude.toString();
                                                        controller.multiStopList[index].longitude = selectedLocationModel.latLng!.longitude.toString();
                                                        controller.setStopMarker(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude, index);
                                                      }
                                                    },
                                                  );
                                                }
                                              },
                                              readOnly: true,
                                              suffix: InkWell(
                                                onTap: () {
                                                  controller.removeStop(index);
                                                  controller.markers.remove("Stop $index");
                                                  controller.getDirections();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Icon(Icons.close),
                                                ),
                                              ),
                                              prefix: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(color: AppThemeData.neutral900, borderRadius: BorderRadius.circular(40)),
                                                  child: Center(
                                                    child: Text(
                                                      String.fromCharCode(index + 65),
                                                      style: TextStyle(fontSize: 16, fontFamily: AppThemeData.regular, color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              hintText: "Where do you want to stop?".tr,
                                              controller: controller.multiStopList[index].editingController,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          controller.multiStopList.length - 1 == index
                                              ? Container(
                                                  decoration:
                                                      BoxDecoration(color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutralDark50, borderRadius: BorderRadius.circular(30)),
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.addStops();
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                    ),
                                ],
                                onReorder: (int oldIndex, int newIndex) {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final AddStopModelTwo item = controller.multiStopList.removeAt(oldIndex);
                                  controller.multiStopList.insert(newIndex, item);
                                },
                              ),
                            ),
                            TextFieldWidget(
                              controller: controller.destinationTextEditController.value,
                              hintText: 'Where to?',
                              readOnly: true,
                              onPress: () async {
                                if (Constant.selectedMapType == 'osm') {
                                  final result = await Get.to(() => MapPickerPage());
                                  if (result != null) {
                                    controller.destinationTextEditController.value.text = '';
                                    final firstPlace = result;
                                    final lat = firstPlace.coordinates.latitude;
                                    final lng = firstPlace.coordinates.longitude;
                                    final address = firstPlace.address;
                                    controller.destinationTextEditController.value.text = address.toString();
                                    controller.setDestinationMarker(lat, lng);
                                  }
                                } else {
                                  Get.to(LocationPickerScreen())!.then(
                                    (value) async {
                                      if (value != null) {
                                        SelectedLocationModel selectedLocationModel = value;

                                        controller.destinationTextEditController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                        controller.setDestinationMarker(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                      }
                                    },
                                  );
                                }
                              },
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: SvgPicture.asset("assets/icons/ic_destination.svg"),
                              ),
                              suffix: controller.destinationTextEditController.value.text.isEmpty
                                  ? null
                                  : InkWell(
                                      onTap: () {
                                        controller.removeDestination();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                            ),
                          ],
                        ),
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
                          ShowToastDialog.showToast("Please select source location");
                        } else if (controller.destinationTextEditController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please select destination location");
                        } else if (controller.multiStopList.isNotEmpty && controller.multiStopList.any((stop) => stop.editingController.text.trim().isEmpty)) {
                          ShowToastDialog.showToast("Please fill all stop locations");
                        } else {
                          await controller.getVehicle();
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

  Widget preferencesBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
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
                          'Select your preferences'.tr,
                          textAlign: TextAlign.center,
                          style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              height: 14,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total distance'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ),
                                Text(
                                  "${controller.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}".tr,
                                  textAlign: TextAlign.start,
                                  style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trip Options'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Passenger'.tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Row(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  if (controller.passenger.value > 1) {
                                                    controller.passenger.value -= 1;
                                                  } else {
                                                    ShowToastDialog.showToast("Passenger count cannot be less than 1.");
                                                  }
                                                },
                                                child: Icon(Icons.remove, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Obx(
                                                () => Text(
                                                  controller.passenger.value.toString(),
                                                  textAlign: TextAlign.start,
                                                  style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  controller.passenger.value += 1;
                                                },
                                                child: Icon(Icons.add, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Children'.tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: Row(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  if (controller.children.value > 0) {
                                                    controller.children.value -= 1;
                                                  } else {
                                                    ShowToastDialog.showToast("Children count cannot be less than zero");
                                                  }
                                                },
                                                child: Icon(Icons.remove, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Obx(
                                                () => Text(
                                                  controller.children.value.toString(),
                                                  textAlign: TextAlign.start,
                                                  style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  controller.children.value += 1;
                                                },
                                                child: Icon(Icons.add, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                          ],
                                        ),
                                      ),
                                    )
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
                                Text(
                                  'Select Vehicle'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
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
                                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Compact, Convenient, and Cost-Effective!".tr,
                                                    textAlign: TextAlign.start,
                                                    style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                                  ),
                                                ],
                                              )),
                                              Column(
                                                children: [
                                                  Text(
                                                    Constant().amountShow(amount: "${vehicleData.baseFare}").tr,
                                                    textAlign: TextAlign.center,
                                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                                  ),
                                                  Text(
                                                    controller.duration.toString().tr,
                                                    textAlign: TextAlign.center,
                                                    style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                                  ),
                                                ],
                                              )
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
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: RoundedButtonFill(
                      title: "Select Payment Method".tr,
                      height: 5.5,
                      color: AppThemeData.primaryDefault,
                      textColor: AppThemeData.neutral900,
                      onPress: () async {
                        FocusScope.of(context).unfocus();
                        if (controller.selectedVehicle.value.id == null) {
                          ShowToastDialog.showToast("Please select vehicle type");
                        } else {
                          controller.bottomSheetType.value = "payment";
                          controller.calculateAmountBeforeRide();
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

  Widget paymentBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
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
                              visible: controller.paymentSettingModel.value.cash != null && controller.paymentSettingModel.value.cash!.isEnabled == "true",
                              child: cardDecoration(controller, controller.paymentSettingModel.value.cash!.libelle.toString(), themeChange, "assets/images/ic_cash.png"),
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
                        controller.bottomSheetType.value = "conformRide";
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

  Widget conformRideBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
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
                          'Confirm your trip'.tr,
                          textAlign: TextAlign.center,
                          style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
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
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip Options'.tr,
                              textAlign: TextAlign.center,
                              style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Passenger'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              if (controller.passenger.value > 1) {
                                                controller.passenger.value -= 1;
                                              } else {
                                                ShowToastDialog.showToast("Passenger count cannot be less than 1.");
                                              }
                                            },
                                            child: Icon(Icons.remove, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Obx(
                                            () => Text(
                                              controller.passenger.value.toString(),
                                              textAlign: TextAlign.start,
                                              style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              controller.passenger.value += 1;
                                            },
                                            child: Icon(Icons.add, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Children'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              if (controller.children.value > 0) {
                                                controller.children.value -= 1;
                                              } else {
                                                ShowToastDialog.showToast("Children count cannot be less than zero");
                                              }
                                            },
                                            child: Icon(Icons.remove, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Obx(
                                            () => Text(
                                              controller.children.value.toString(),
                                              textAlign: TextAlign.start,
                                              style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              controller.children.value += 1;
                                            },
                                            child: Icon(Icons.add, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700)),
                                      ],
                                    ),
                                  ),
                                )
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
                                    'Vehicle Type'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.bottomSheetType.value = "preferences";
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
                              height: 14,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                border: Border.all(color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200),
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
                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Compact, Convenient, and Cost-Effective!".tr,
                                        textAlign: TextAlign.start,
                                        style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                      ),
                                    ],
                                  )),
                                  Column(
                                    children: [
                                      Text(
                                        Constant().amountShow(amount: "${controller.calculateTripPrice(controller.selectedVehicle.value)}").tr,
                                        textAlign: TextAlign.center,
                                        style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                      Text(
                                        controller.duration.toString().tr,
                                        textAlign: TextAlign.center,
                                        style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                      ),
                                    ],
                                  )
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
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(CouponCodeListScreen(), arguments: {"type": "Ride"})!.then(
                                      (value) {
                                        if (value != null) {
                                          controller.selectedDiscount.value = value['discount'];
                                          controller.couponCodeTextEditController.value.text = controller.selectedDiscount.value.code.toString();
                                          controller.calculateAmountBeforeRide();
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
                                      controller.calculateAmountBeforeRide();
                                      ShowToastDialog.showToast("Discount applied");
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
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.subTotalBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
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
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.discountBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.errorDefault : AppThemeData.errorDefault),
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
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                          ),
                                        ),
                                        Text(
                                          Constant().amountShow(amount: controller.totalBeforeRideAmount.value.toString()).tr,
                                          textAlign: TextAlign.start,
                                          style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
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
                                    style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
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
                                        fontSize: 16, color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault, decoration: TextDecoration.underline),
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
                        final value = Constant.getGatewayValue(
                          key: controller.selectedPaymentMethod.value,
                          property: "id_payment_method",
                          model: controller.paymentSettingModel.value,
                        );

                        List<StopModel> stopsList = [];
                        for (var i = 0; i < controller.multiStopList.length; i++) {
                          stopsList.add(StopModel(
                              latitude: controller.multiStopList[i].latitude.toString(),
                              longitude: controller.multiStopList[i].longitude.toString(),
                              location: controller.multiStopList[i].editingController.text.toString()));
                        }

                        BookingRequestModel bookingRequestModel = BookingRequestModel(
                          userId: controller.userModel.value.userData!.id.toString(),
                          latitudeDepart: Constant.selectedMapType == 'osm' ? controller.departureLatLongOsm.value.latitude.toString() : controller.departureLatLong.value.latitude.toString(),
                          longitudeDepart: Constant.selectedMapType == 'osm' ? controller.departureLatLongOsm.value.longitude.toString() : controller.departureLatLong.value.longitude.toString(),
                          latitudeArrivee: Constant.selectedMapType == 'osm' ? controller.destinationLatLongOsm.value.latitude.toString() : controller.destinationLatLong.value.latitude.toString(),
                          longitudeArrivee: Constant.selectedMapType == 'osm' ? controller.destinationLatLongOsm.value.longitude.toString() : controller.destinationLatLong.value.longitude.toString(),
                          departName: controller.sourceTextEditController.value.text,
                          destinationName: controller.destinationTextEditController.value.text,
                          duration: controller.duration.toString(),
                          totalPeople: controller.passenger.value.toString(),
                          totalChildren: controller.children.value.toString(),
                          stops: stopsList,
                          distance: controller.distance.toStringAsFixed(int.parse(Constant.decimal.toString())),
                          distanceUnit: Constant.distanceUnit,
                          subTotal: controller.calculateTripPrice(controller.selectedVehicle.value).toStringAsFixed(int.parse(Constant.decimal.toString())),
                          idPaymentMethod: value,
                          discountId: controller.selectedDiscount.value.id,
                          vehicleTypeId: controller.selectedVehicle.value.id.toString(),
                          surgeMultiplier: controller.selectedVehicle.value.surgeMultiplier,
                        );

                        // log(jsonEncode(bookingRequestModel.toJson()));
                        controller.bookRide(bookingRequestModel);
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

  Widget waitingRideBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
    final bool showBump = controller.showFareBumpOption.value;
    final double sheetSize = showBump ? 0.65 : 0.45;
    final bool isDark = themeChange.getThem();
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: sheetSize,
        minChildSize: sheetSize,
        maxChildSize: sheetSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    controller: scrollController,
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 8),
                      showBump ? _fareBumpContent(context, themeChange, controller) : _searchingContent(context, themeChange),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: RoundedButtonFill(
                    title: "Cancel Ride".tr,
                    height: 5.5,
                    color: AppThemeData.errorDefault,
                    textColor: AppThemeData.neutral50,
                    onPress: () async {
                      controller.cancelRequest();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchingContent(BuildContext context, DarkThemeProvider themeChange) {
    final bool isDark = themeChange.getThem();
    return Column(
      children: [
        Image.asset("assets/images/wating_driver.gif", height: 180),
        const SizedBox(height: 4),
        Text(
          'Waiting for Driver'.tr,
          textAlign: TextAlign.center,
          style: AppThemeData.semiBoldTextStyle(
            fontSize: 18,
            color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please hold on while we find a driver for your ride.'.tr,
          textAlign: TextAlign.center,
          style: AppThemeData.mediumTextStyle(
            fontSize: 14,
            color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _fareBumpContent(BuildContext context, DarkThemeProvider themeChange, BookRideController controller) {
    final double currentAmount = double.tryParse(controller.bookingModel.value.data?.montant?.toString() ?? "0") ?? 0.0;
    return FareBumpContent(
      currentAmount: currentAmount,
      presetAmounts: controller.fareBumpAmounts,
      onIncrease: (bump) => controller.increaseFare(bump),
      onKeepWaiting: () {
        controller.showFareBumpOption.value = false;
        controller.startNoDriverTimer();
      },
    );
  }

  Widget driverDetailsBottomSheet(DarkThemeProvider themeChange, BookRideController controller) {
    return Positioned.fill(
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        // Start height
        minChildSize: 0.7,
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
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: NetworkImageWidget(
                                imageUrl: controller.bookingModel.value.data!.driver!.vehicleDetails!.image.toString(),
                                width: Responsive.width(12, context),
                                height: Responsive.height(6, context),
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
                                    '${controller.bookingModel.value.data!.driver!.prenom} ${controller.bookingModel.value.data!.driver!.nom}'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  ),
                                  Text(
                                    '${controller.bookingModel.value.data!.driver!.vehicleDetails!.brand} • ${controller.bookingModel.value.data!.driver!.vehicleDetails!.model}'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Constant.makePhoneCall(controller.bookingModel.value.data!.driver!.phone!);
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
                                  "receiverId": controller.bookingModel.value.data!.driver!.id,
                                  "orderId": controller.bookingModel.value.data!.id,
                                  "receiverName": "${controller.bookingModel.value.data!.driver!.prenom} ${controller.bookingModel.value.data!.driver!.nom}",
                                  "receiverPhoto": controller.bookingModel.value.data!.driver!.image
                                });
                              },
                              child: SvgPicture.asset(
                                "assets/icons/ic_chat_details.svg",
                                width: 36,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${controller.bookingModel.value.data!.duree}'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(fontSize: 24, color: themeChange.getThem() ? AppThemeData.warningDarkDefault : AppThemeData.warningDefault),
                                  ),
                                  Text(
                                    'Durations'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    Constant().amountShow(amount: controller.totalAmount.value).tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.boldTextStyle(fontSize: 24, color: themeChange.getThem() ? AppThemeData.warningDarkDefault : AppThemeData.warningDefault),
                                  ),
                                  Text(
                                    'Trip Price'.tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text(
                            'Trip Details'.tr,
                            textAlign: TextAlign.start,
                            style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                          ),
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
                        Divider(color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Ride Cost:'.tr,
                                  textAlign: TextAlign.start,
                                  style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                ),
                              ),
                              Text(
                                Constant().amountShow(amount: controller.subTotal.value).tr,
                                textAlign: TextAlign.start,
                                style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
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
                                  'Discount'.tr,
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
                        ListView.builder(
                          itemCount: controller.bookingModel.value.data!.tax!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            TaxModel taxModel = controller.bookingModel.value.data!.tax![index];
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
                                                .calculateTax(amount: (double.parse(controller.subTotal.value) - double.parse(controller.discount.value)).toString(), taxModel: taxModel)
                                                .toString())
                                        .tr,
                                    textAlign: TextAlign.start,
                                    style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total Cost:'.tr,
                                  textAlign: TextAlign.start,
                                  style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                                ),
                              ),
                              Text(
                                Constant().amountShow(amount: controller.totalAmount.value).tr,
                                textAlign: TextAlign.start,
                                style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Payment Method:'.tr,
                                textAlign: TextAlign.start,
                                style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                              ),
                            ),
                            Text(
                              '${controller.bookingModel.value.data!.paymentMethod}'.tr,
                              textAlign: TextAlign.start,
                              style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: RoundedButtonFill(
                      title: "Cancel Ride".tr,
                      height: 5.5,
                      color: AppThemeData.errorDefault,
                      textColor: AppThemeData.neutral50,
                      onPress: () async {
                        controller.cancelRequest();
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

  Widget cardDecoration(BookRideController controller, String value, themeChange, String image) {
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
          Divider(
            color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
            height: 1,
          )
        ],
      ),
    );
  }
}
