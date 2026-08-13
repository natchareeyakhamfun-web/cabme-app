import 'dart:io';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/book_parcel_controller.dart';
import 'package:cabme/model/book_parcel_model.dart';
import 'package:cabme/page/parcel_service_screen/parcel_cart_screen.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/utils.dart';
import 'package:cabme/widget/osm_map/map_picker_page.dart';
import 'package:cabme/widget/place_picker/location_picker_screen.dart';
import 'package:cabme/widget/place_picker/selected_location_model.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../themes/app_them_data.dart';
import '../../themes/text_field_widget.dart';

class BookParcelScreen extends StatelessWidget {
  const BookParcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookParcelController(),
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
                "Send ${controller.parcelCategory.value.title}".tr,
                style: AppThemeData.semiBoldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: DottedBorder(
                              options: RectDottedBorderOptions(dashPattern: const [3, 3], strokeWidth: 1, color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300),
                              child: Container(
                                width: Responsive.width(100, context),
                                decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100, borderRadius: BorderRadius.circular(18)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.accentDarkLight : AppThemeData.accentLight, borderRadius: BorderRadius.circular(50)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset("assets/icons/ic_upload.svg"),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Upload Parcel Image".tr,
                                        style: AppThemeData.mediumTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Take a clear picture of your parcel or choose an image from your gallery to ensure smooth delivery.".tr,
                                        textAlign: TextAlign.center,
                                        style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      RoundedButtonFill(
                                        title: "Click to Upload".tr,
                                        height: 5,
                                        color: AppThemeData.accentDark,
                                        textColor: AppThemeData.neutral100,
                                        width: 40,
                                        onPress: () async {
                                          controller.onCameraClick(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sender Information'.tr,
                                textAlign: TextAlign.center,
                                style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (Constant.selectedMapType == 'osm') {
                                    final result = await Get.to(() => MapPickerPage());
                                    if (result != null) {
                                      controller.senderLocationController.value.text = '';
                                      final firstPlace = result;
                                      final lat = firstPlace.coordinates.latitude;
                                      final lng = firstPlace.coordinates.longitude;
                                      final address = firstPlace.address;
                                      controller.senderLocationController.value.text = address.toString();
                                      controller.departureLatLongOsm.value = latlong.LatLng(lat, lng);
                                    }
                                  } else {
                                    Get.to(LocationPickerScreen())!.then(
                                      (value) async {
                                        if (value != null) {
                                          SelectedLocationModel selectedLocationModel = value;

                                          controller.senderLocationController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                          controller.departureLatLong.value = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                        }
                                      },
                                    );
                                  }
                                },
                                child: TextFieldWidget(
                                  controller: controller.senderLocationController.value,
                                  hintText: 'Sender Location'.tr,
                                  title: 'Sender Location'.tr,
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: SvgPicture.asset("assets/icons/ic_sender.svg"),
                                  ),
                                  enable: controller.senderLocationController.value.text.isEmpty ? false : true,
                                  suffix: controller.senderLocationController.value.text.isEmpty
                                      ? null
                                      : InkWell(
                                          onTap: () async {
                                            if (Constant.selectedMapType == 'osm') {
                                              final result = await Get.to(() => MapPickerPage());
                                              if (result != null) {
                                                controller.senderLocationController.value.text = '';
                                                final firstPlace = result;
                                                final lat = firstPlace.coordinates.latitude;
                                                final lng = firstPlace.coordinates.longitude;
                                                final address = firstPlace.address;
                                                controller.senderLocationController.value.text = address.toString();
                                                controller.departureLatLongOsm.value = latlong.LatLng(lat, lng);
                                              }
                                            } else {
                                              Get.to(LocationPickerScreen())!.then(
                                                (value) async {
                                                  if (value != null) {
                                                    SelectedLocationModel selectedLocationModel = value;

                                                    controller.senderLocationController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                                    controller.departureLatLong.value = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                                  }
                                                },
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              'Change'.tr,
                                              textAlign: TextAlign.center,
                                              style: AppThemeData.boldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              TextFieldWidget(
                                controller: controller.senderNameController.value,
                                hintText: 'Enter sender name'.tr,
                                title: 'Name'.tr,
                                prefix: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  child: SvgPicture.asset("assets/icons/ic_user.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn)),
                                ),
                              ),
                              TextFieldWidget(
                                controller: controller.senderMobileNumberController.value,
                                hintText: '1234 5678 89',
                                title: 'Mobile Number',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                ],
                                prefix: CountryCodePicker(
                                  onInit: (value) {
                                    controller.senderCountryCodeController.value.text = value?.dialCode ?? Constant.defaultCountryCode ?? '';
                                    controller.senderCountryISOCodeController.value.text = value?.code ?? Constant.defaultCountryCode ?? '';
                                  },
                                  onChanged: (value) {
                                    controller.senderCountryCodeController.value.text = value.dialCode.toString();
                                    controller.senderCountryISOCodeController.value.text = value.code ?? Constant.defaultCountryCode ?? '';
                                  },
                                  dialogTextStyle: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                  dialogBackgroundColor: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                  initialSelection: controller.senderCountryISOCodeController.value.text,
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
                              InkWell(
                                onTap: () {
                                  controller.pickDateTime(isPickUp: true);
                                },
                                child: TextFieldWidget(
                                  controller: controller.senderDataAndTimeController.value,
                                  hintText: 'Select date and time'.tr,
                                  title: 'Date and Time'.tr,
                                  enable: false,
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_date.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Parcel Height and Weight'.tr,
                                      style: AppThemeData.semiBoldTextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.neutralDark700 : AppThemeData.neutral700,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            hint: Text("Height (ft)".tr),
                                            initialValue: controller.selectedParcelHeight.value,
                                            onChanged: (String? newValue) {
                                              controller.selectedParcelHeight.value = newValue!;
                                            },
                                            items: controller.parcelHeight.map((String reason) {
                                              return DropdownMenuItem<String>(
                                                value: reason,
                                                child: Text("$reason ft."),
                                              );
                                            }).toList(),
                                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontFamily: AppThemeData.medium),
                                            decoration: InputDecoration(
                                              filled: true,
                                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                              fillColor: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                              disabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.primaryDarkDefault : AppThemeData.primaryDefault, width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            hint: Text("Weight (kg)".tr),
                                            initialValue: controller.selectedParcelWeight.value,
                                            onChanged: (String? newValue) {
                                              controller.selectedParcelWeight.value = newValue!;
                                            },
                                            items: controller.parcelWeight.map((String reason) {
                                              return DropdownMenuItem<String>(
                                                value: reason,
                                                child: Text("$reason Kg"),
                                              );
                                            }).toList(),
                                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900, fontFamily: AppThemeData.medium),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
                                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                              disabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.primaryDarkDefault : AppThemeData.primaryDefault, width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.neutralDark300 : AppThemeData.neutral300, width: 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                              TextFieldWidget(
                                controller: controller.noteController.value,
                                hintText: 'Enter Notes'.tr,
                                title: 'Notes (Optional)'.tr,
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
                                'Receiver Information'.tr,
                                textAlign: TextAlign.center,
                                style: AppThemeData.boldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (Constant.selectedMapType == 'osm') {
                                    final result = await Get.to(() => MapPickerPage());
                                    if (result != null) {
                                      controller.receiverLocationController.value.text = '';
                                      final firstPlace = result;
                                      final lat = firstPlace.coordinates.latitude;
                                      final lng = firstPlace.coordinates.longitude;
                                      final address = firstPlace.address;
                                      controller.receiverLocationController.value.text = address.toString();
                                      controller.destinationLatLongOsm.value = latlong.LatLng(lat, lng);
                                    }
                                  } else {
                                    Get.to(LocationPickerScreen())!.then(
                                      (value) async {
                                        if (value != null) {
                                          SelectedLocationModel selectedLocationModel = value;

                                          controller.receiverLocationController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                          controller.destinationLatLong.value = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                        }
                                      },
                                    );
                                  }
                                },
                                child: TextFieldWidget(
                                  controller: controller.receiverLocationController.value,
                                  hintText: 'Select Receiver Location'.tr,
                                  title: 'Receiver Location'.tr,
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: SvgPicture.asset("assets/icons/ic_recevier.svg"),
                                  ),
                                  enable: controller.receiverLocationController.value.text.isEmpty ? false : true,
                                  suffix: controller.receiverLocationController.value.text.isEmpty
                                      ? null
                                      : InkWell(
                                          onTap: () async {
                                            if (Constant.selectedMapType == 'osm') {
                                              final result = await Get.to(() => MapPickerPage());
                                              if (result != null) {
                                                controller.receiverLocationController.value.text = '';
                                                final firstPlace = result;
                                                final lat = firstPlace.coordinates.latitude;
                                                final lng = firstPlace.coordinates.longitude;
                                                final address = firstPlace.address;
                                                controller.receiverLocationController.value.text = address.toString();
                                                controller.destinationLatLongOsm.value = latlong.LatLng(lat, lng);
                                              }
                                            } else {
                                              Get.to(LocationPickerScreen())!.then(
                                                (value) async {
                                                  if (value != null) {
                                                    SelectedLocationModel selectedLocationModel = value;

                                                    controller.receiverLocationController.value.text = Utils.formatAddress(selectedLocation: selectedLocationModel);
                                                    controller.destinationLatLong.value = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                                  }
                                                },
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              'Change'.tr,
                                              textAlign: TextAlign.center,
                                              style: AppThemeData.boldTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.accentDefault : AppThemeData.accentDefault),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              TextFieldWidget(
                                controller: controller.receiverNameController.value,
                                hintText: 'Enter receiver name'.tr,
                                title: 'Name'.tr,
                                prefix: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  child: SvgPicture.asset("assets/icons/ic_user.svg",
                                      colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn)),
                                ),
                              ),
                              TextFieldWidget(
                                controller: controller.receiverMobileNumberController.value,
                                hintText: '1234 5678 89',
                                title: 'Mobile Number'.tr,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                ],
                                prefix: CountryCodePicker(
                                  onInit: (value) {
                                    controller.receiverCountryCodeController.value.text = value?.dialCode ?? Constant.defaultCountryCode ?? '';
                                    controller.receiverCountryISOCodeController.value.text = value?.code ?? Constant.defaultCountryCode ?? '';
                                  },
                                  onChanged: (value) {
                                    controller.receiverCountryCodeController.value.text = value.dialCode.toString();
                                    controller.receiverCountryISOCodeController.value.text = value.code ?? Constant.defaultCountryCode ?? '';
                                  },
                                  dialogTextStyle: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                  dialogBackgroundColor: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                                  initialSelection: controller.receiverCountryISOCodeController.value.text,
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
                              InkWell(
                                onTap: () {
                                  controller.pickDateTime(isPickUp: false);
                                },
                                child: TextFieldWidget(
                                  controller: controller.receiverDataAndTimeController.value,
                                  hintText: 'Select date and time'.tr,
                                  title: 'Date and Time',
                                  enable: false,
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: SvgPicture.asset("assets/icons/ic_date.svg",
                                        colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500, BlendMode.srcIn)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 45, left: 16, right: 16, top: 10),
              child: RoundedButtonFill(
                title: "Confirm".tr,
                height: 5.5,
                color: AppThemeData.primaryDefault,
                textColor: AppThemeData.neutral900,
                onPress: () async {
                  FocusScope.of(context).unfocus();
                  if (controller.senderLocationController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please select sender location".tr);
                  } else if (controller.senderNameController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter sender name".tr);
                  } else if (controller.senderMobileNumberController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter sender mobile number".tr);
                  } else if (controller.senderDataAndTimeController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please select date and time".tr);
                  } else if (controller.selectedParcelHeight.value == null) {
                    ShowToastDialog.showToast("Please select parcel height".tr);
                  } else if (controller.selectedParcelWeight.value == null) {
                    ShowToastDialog.showToast("Please select parcel weight".tr);
                  } else if (controller.receiverLocationController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please select receiver location".tr);
                  } else if (controller.receiverNameController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter receiver name".tr);
                  } else if (controller.receiverMobileNumberController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter receiver mobile number".tr);
                  } else if (controller.receiverDataAndTimeController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please select receiver date and time".tr);
                  } else {
                    if (Constant.selectedMapType == 'google') {
                      await controller.fetchGoogleDistanceAndDuration(origin: controller.departureLatLong.value, destination: controller.destinationLatLong.value);
                    } else {
                      await controller.fetchOsmDistanceAndDuration(origin: controller.departureLatLongOsm.value, destination: controller.destinationLatLongOsm.value);
                    }

                    BookParcelModel bookParcelModel = BookParcelModel();
                    bookParcelModel.userId = Preferences.getInt(Preferences.userId).toString();
                    bookParcelModel.senderName = controller.senderNameController.value.text;
                    bookParcelModel.receiverName = controller.receiverNameController.value.text;

                    bookParcelModel.sourceAdrs = controller.senderLocationController.value.text;
                    bookParcelModel.destinationAdrs = controller.receiverLocationController.value.text;

                    bookParcelModel.sourceCity = controller.senderLocationController.value.text;
                    bookParcelModel.destinationCity = controller.receiverLocationController.value.text;

                    bookParcelModel.senderPhone = controller.senderCountryCodeController.value.text + controller.senderMobileNumberController.value.text;
                    bookParcelModel.receiverPhone = controller.receiverCountryCodeController.value.text + controller.receiverMobileNumberController.value.text;

                    bookParcelModel.lat1 = Constant.selectedMapType == 'google' ? controller.departureLatLong.value.latitude.toString() : controller.departureLatLongOsm.value.latitude.toString();
                    bookParcelModel.lng1 = Constant.selectedMapType == 'google' ? controller.departureLatLong.value.longitude.toString() : controller.departureLatLongOsm.value.longitude.toString();

                    bookParcelModel.lat2 = Constant.selectedMapType == 'google' ? controller.destinationLatLong.value.latitude.toString() : controller.destinationLatLongOsm.value.latitude.toString();
                    bookParcelModel.lng2 =
                        Constant.selectedMapType == 'google' ? controller.destinationLatLong.value.longitude.toString() : controller.destinationLatLongOsm.value.longitude.toString();

                    bookParcelModel.distance = controller.distance.value.toString();
                    bookParcelModel.distanceUnit = Constant.distanceUnit;

                    bookParcelModel.duration = controller.duration.value;
                    bookParcelModel.parcelDimension = controller.selectedParcelHeight.value;
                    bookParcelModel.parcelWeight = controller.selectedParcelWeight.value;

                    bookParcelModel.parcelDate = DateFormat('dd-MMM-yyyy').format(controller.pickUpDateTime.value);
                    bookParcelModel.parcelTime = DateFormat('hh:mm a').format(controller.pickUpDateTime.value);

                    bookParcelModel.receiveDate = DateFormat('dd-MMM-yyyy').format(controller.dropOfDateTime.value);
                    bookParcelModel.receiveTime = DateFormat('hh:mm a').format(controller.dropOfDateTime.value);

                    bookParcelModel.note = controller.noteController.value.text;
                    bookParcelModel.parcelType = controller.parcelCategory.value.id;

                    Get.to(ParcelCartScreen(), arguments: {"bookParcelModel": bookParcelModel, "parcelCategory": controller.parcelCategory.value, "parcelImages": controller.parcelImages});
                  }
                },
              ),
            ),
          );
        });
  }
}
