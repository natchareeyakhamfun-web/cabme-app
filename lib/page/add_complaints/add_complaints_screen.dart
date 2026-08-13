import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/add_complain_controller.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/themes/text_field_widget.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddComplaintsScreen extends StatelessWidget {
  const AddComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddComplainController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                controller.bookingType.value == "ride"
                    ? controller.bookingData.value.complaint == true
                        ? "Edit Complain"
                        : 'Add Complain'.tr
                    : controller.bookingType.value == "rental"
                        ? controller.rentalBookingData.value.complaint == true
                            ? "Edit Complain"
                            : 'Add Complain'.tr
                        : controller.parcelBookingData.value.complaint == true
                            ? "Edit Complain"
                            : 'Add Complain'.tr,
                textAlign: TextAlign.center,
                style: AppThemeData.boldTextStyle(
                    fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
              titleSpacing: 0,
              centerTitle: false,
              actions: [
                checkStatus(controller) == true?Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RoundedButtonFill(
                    title: controller.bookingType.value == "ride"
                        ? controller.bookingData.value.complainDetails!.status!.capitalizeString()
                        : controller.bookingType.value == "rental"
                            ? controller.rentalBookingData.value.complainDetails!.status!.capitalizeString()
                            : controller.parcelBookingData.value.complainDetails!.status!.capitalizeString(),
                    height: 4,
                    width: 25,
                    color: controller.bookingType.value == "ride"
                        ? controller.bookingData.value.complainDetails!.status! == "initiated"
                            ? AppThemeData.accentDefault
                            : controller.bookingData.value.complainDetails!.status! == "processing"
                                ? AppThemeData.warningDefault
                                : AppThemeData.successDefault
                        : controller.bookingType.value == "rental"
                            ? controller.rentalBookingData.value.complainDetails!.status! == "initiated"
                                ? AppThemeData.accentDefault
                                : controller.rentalBookingData.value.complainDetails!.status! == "processing"
                                    ? AppThemeData.warningDefault
                                    : AppThemeData.successDefault
                            : controller.parcelBookingData.value.complainDetails!.status! == "initiated"
                                ? AppThemeData.accentDefault
                                : controller.parcelBookingData.value.complainDetails!.status! == "processing"
                                    ? AppThemeData.warningDefault
                                    : AppThemeData.successDefault,
                    textColor: AppThemeData.neutral50,
                    onPress: () async {},
                  ),
                ):SizedBox(),
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TextFieldWidget(
                          controller: controller.titleController.value,
                          hintText: 'Enter Subject'.tr,
                          title: 'Subject'.tr,
                        ),
                        TextFieldWidget(
                          controller: controller.descriptionController.value,
                          hintText: 'Enter Description'.tr,
                          title: 'Description'.tr,
                          maxLine: 10,
                          radius: 10,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        checkStatus(controller) == false
                            ? RoundedButtonFill(
                                title: "Submit complain".tr,
                                height: 5.5,
                                color: AppThemeData.primaryDefault,
                                textColor: AppThemeData.neutral900,
                                onPress: () async {
                                  FocusScope.of(context).unfocus();
                                  if (controller.titleController.value.text.isEmpty) {
                                    ShowToastDialog.showToast('Please enter the title'.tr);
                                  } else if (controller.descriptionController.value.text.isEmpty) {
                                    ShowToastDialog.showToast('Please enter the description'.tr);
                                  } else {
                                    controller.submitComplain();
                                  }
                                },
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
          );
        });
  }

  bool checkStatus(AddComplainController controller) {
    return controller.bookingType.value == "ride"
        ? controller.bookingData.value.complaint == true
        : controller.bookingType.value == "rental"
            ? controller.rentalBookingData.value.complaint == true
            : controller.parcelBookingData.value.complaint == true;
  }
}
