import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/page/booking_screens/booking_screen.dart';
import 'package:cabme/page/profile_screen/profile_screen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/service/notification_service.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../page/home_screens/home_screen_one.dart';
import '../page/wallet_screen/wallet_screen.dart';

class DashboardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [].obs;
  Rx<UserModel> userModel = UserModel().obs;
  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    userModel.value = Constant.getUserData();
    pageList.value = [
      const HomeScreenOne(),
      const BookingScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];
    getCurrentLocation();
    getSettings();
    super.onInit();
  }

  Future<void> getCurrentLocation() async {
    Constant.currentLocation = await Utils.getCurrentLocation();
  }

  Future<void> getSettings() async {
    await getUserData();
    await updateToken();
    await getPaymentSettingData();
  }

  Future<void> getUserData() async {
    Map<String, String> bodyParams = {
      'phone': userModel.value.userData!.phone.toString(),
      'country_code': userModel.value.userData!.countryCode.toString(),
      'country_iso_code': userModel.value.userData!.countryISOCode.toString(),
      'user_cat': "customer",
      'email': userModel.value.userData!.email.toString(),
      'login_type': userModel.value.userData!.loginType.toString(),
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.getProfileByPhone), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true).then(
      (value) {
        if (value != null) {
          if (value != null) {
            if (value['success'] == "Failed" || value['success'] == "failed") {
              ShowToastDialog.showToast(value['error']);
              return null;
            } else {
              userModel.value = UserModel.fromJson(value);
              Preferences.setString(Preferences.user, jsonEncode(value));
            }
          }
        }
      },
    );
  }

  Future<void> updateToken() async {
    // use the returned token to send messages to users from your custom server
    String? token = await NotificationService.getToken();
    if (token != null) {
      updateFCMToken(token);
    }
  }

  Future updateFCMToken(String token) async {
    Map<String, dynamic> bodyParams = {'user_id': Preferences.getInt(Preferences.userId), 'fcm_id': token, 'device_id': "", 'user_cat': userModel.value.userData!.userCat};
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.updateToken), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false);
  }

  Future getPaymentSettingData() async {
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.paymentSetting), headers: API.headers), showLoader: false).then(
      (value) {
        if (value != null) {
          Preferences.setString(Preferences.paymentSetting, jsonEncode(value));
        }
      },
    );
  }
}
