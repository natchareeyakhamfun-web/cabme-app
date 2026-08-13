import 'package:cabme/service/notification_service.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    notificationInit();
    super.onInit();
  }

  NotificationService notificationService = NotificationService();

  void notificationInit() {
    notificationService.initInfo();
    isLoading.value = false;
  }
}
