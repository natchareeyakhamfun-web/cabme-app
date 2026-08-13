import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/model/settings_model.dart';
import 'package:cabme/page/auth_screens/login_screen.dart';
import 'package:cabme/page/dashboard_screen.dart';
import 'package:cabme/page/localization_screens/localization_screen.dart';
import 'package:cabme/page/location_permission_screen/location_permission_screen.dart';
import 'package:cabme/page/maintenance_mode_screen/maintenance_mode_screen.dart';
import 'package:cabme/page/on_boarding_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/service/pusher_service.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
    String? isMaintenanceMode = await getSettingsData();
    if (isMaintenanceMode == 'true') {
      Get.offAll(() => MaintenanceModeScreen());
      return;
    } else {
      bool isLocationPermission = await _checkLocationPermission();
      if (isLocationPermission) {
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
        Get.offAll(const LocationPermissionScreen());
      }
    }
  }

  Future<String?> getSettingsData() async {
    String? isCustomerMaintenanceMode = 'false';
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.settings), headers: API.authheader), showLoader: false).then(
      (value) async {
        if (value != null) {
          SettingsModel model = SettingsModel.fromJson(value);
          Constant.liveTrackingMapType = model.data?.mapType ?? "";
          Constant.selectedMapType = model.data?.mapForApplication != null ? '${model.data?.mapForApplication?.toLowerCase()}' : '';
          AppThemeData.primaryDefault = Color(int.parse(model.data!.websiteColor!.replaceFirst("#", "0xff")));
          Constant.distanceUnit = model.data!.deliveryDistance!;
          Constant.driverRadius = model.data!.driverRadios!;
          Constant.appVersion = model.data!.appVersion.toString();
          Constant.decimal = model.data!.decimalDigit!;
          Constant.driverLocationUpdate = model.data!.driverLocationUpdate!;
          // Constant.deliverChargeParcel = model.data!.deliveryChargeParcel!;
          Constant.activeServices = model.data!.activeServices!;
          // Constant.parcelPerWeightCharge = model.data!.parcelPerWeightCharge!;
          Constant.allTaxList = model.data!.tax!;
          Constant.currency = model.data!.currency!;
          Constant.symbolAtRight = model.data?.symbolAtRight == 'true' ? true : false;
          Constant.kGoogleApiKey = model.data!.googleMapApiKey!;
          Constant.contactUsEmail = model.data!.contactUsEmail!;
          Constant.contactUsAddress = model.data!.contactUsAddress!;
          Constant.contactUsPhone = model.data!.contactUsPhone!;
          Constant.rideOtp = model.data!.showRideOtp!;
          Constant.senderId = model.data!.senderId!;
          Constant.jsonNotificationFileURL = model.data!.serviceJson!;
          Constant.homeScreenType = model.data!.homeScreenType; //OlaHome
          log("HomeScreenType :: ${Constant.homeScreenType} || MapTYpe :: ${Constant.selectedMapType}");
          Constant.defaultCountryCode = model.data!.defaultCountryCode;
          Constant.pusherApiKey = model.data!.pusherSettings!.pusherKey;
          Constant.cluster = model.data!.pusherSettings!.pusherCluster;
          isCustomerMaintenanceMode = model.data!.isCustomerMaintenanceMode;
          await PusherService().init(
            apiKey: Constant.pusherApiKey!,
            cluster: Constant.cluster!,
          );
          return isCustomerMaintenanceMode;
        }
      },
    );
    return isCustomerMaintenanceMode;
  }

  Future<bool> _checkLocationPermission() async {
    bool isLocationEnable;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled == false) {
      isLocationEnable = false;
    } else {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        isLocationEnable = true;
      } else {
        isLocationEnable = false;
      }
    }

    return isLocationEnable;
  }
}
