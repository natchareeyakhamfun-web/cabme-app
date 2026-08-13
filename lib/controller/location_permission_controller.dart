import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:cabme/page/dashboard_screen.dart';
import 'package:cabme/page/localization_screens/localization_screen.dart';
import 'package:cabme/page/on_boarding_screen.dart';
import 'package:cabme/themes/round_button_fill.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../themes/app_them_data.dart';

class LocationPermissionController extends GetxController {
  Future<void> requestPermission() async {
    ShowToastDialog.showLoader("Please wait");
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      ShowToastDialog.closeLoader();
      _showEnableGPSDialog();
      return;
    } else {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Constant.currentLocation = await Utils.getCurrentLocation();
        ShowToastDialog.closeLoader();
        if (Preferences.getString(Preferences.languageCodeKey).toString().isEmpty) {
          Get.offAll(LocalizationScreens(intentType: "main"));
        } else {
          if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey)) {
            if (Preferences.getBoolean(Preferences.isLogin) == false) {
              Get.offAll(LoginScreen());
            } else {
              Get.offAll(DashboardScreen());
            }
          } else {
            Get.offAll(OnBoardingScreen());
          }
        }
      } else {
        ShowToastDialog.closeLoader();
        _showPermissionDeniedDialog();
      }
    }
  }

  /// Show Permission Denied Dialog
  void _showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Permission Required",
      middleText: "We need your location to show nearby businesses and ensure accurate results. Please allow access when prompted.",
      barrierDismissible: false,
      confirm: RoundedButtonFill(
        onPress: () async {
          Get.back(); // Close dialog
          await Geolocator.openAppSettings();
          Future.delayed(Duration(seconds: 3), () async {
            await requestPermission(); // Recheck when returning from settings
          });
        },
        title: 'Allow Location',
        width: 40,
        height: 5,
        color: AppThemeData.primaryDefault,
      ),
    );
  }

  /// Show Dialog to Enable GPS
  void _showEnableGPSDialog() {
    Get.defaultDialog(
      title: "Enable GPS",
      middleText: "GPS is required for this app. Please enable location services.",
      barrierDismissible: false,
      confirm: RoundedButtonFill(
        onPress: () async {
          Get.back(); // Close dialog
          await Geolocator.openLocationSettings();
          Future.delayed(Duration(seconds: 3), () {
            requestPermission(); // Recheck when returning from settings
          });
        },
        title: 'Enable GPS',
        width: 40,
        height: 5,
        color: AppThemeData.primaryDefault,
      ),
    );
  }
}
