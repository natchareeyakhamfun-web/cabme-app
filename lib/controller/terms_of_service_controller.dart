import 'dart:async';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/service/api.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TermsOfServiceController extends GetxController {
  var data = ''.obs;
  @override
  void onInit() {
    getTermsOfService();

    super.onInit();
  }

  Future<dynamic> getTermsOfService() async {
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.termsOfCondition), headers: API.headers), showLoader: false).then(
          (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            data.value = value['data']['terms'];
          }
        }
      },
    );
  }
}
