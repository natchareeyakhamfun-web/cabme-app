import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/controller/dashboard_controller.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../themes/app_them_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DashboardController(),
        builder: (controller) {
          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvoked: (didPop) {
              final now = DateTime.now();
              if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                controller.currentBackPressTime = now;
                controller.canPopNow.value = false;
                ShowToastDialog.showToast("Double press to exit");
                return;
              } else {
                controller.canPopNow.value = true;
              }
            },
            child: Scaffold(
              body: controller.pageList[controller.selectedIndex.value],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                showSelectedLabels: true,
                selectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                currentIndex: controller.selectedIndex.value,
                backgroundColor: themeChange.getThem() ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
                selectedItemColor: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                unselectedItemColor: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
                onTap: (int index) {
                  controller.selectedIndex.value = index;
                },
                items: [
                  navigationBarItem(
                    themeChange,
                    index: 0,
                    assetIcon: "assets/icons/ic_home.svg",
                    label: 'Home'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 1,
                    assetIcon: "assets/icons/ic_booking.svg",
                    label: 'Booking'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 2,
                    assetIcon: "assets/icons/ic_wallet.svg",
                    label: 'Wallet'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 3,
                    assetIcon: "assets/icons/ic_user.svg",
                    label: 'Profile'.tr,
                    controller: controller,
                  ),
                ],
              ),
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange, {required int index, required String label, required String assetIcon, required DashboardController controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          assetIcon,
          height: 22,
          width: 22,
          colorFilter: ColorFilter.mode(
              controller.selectedIndex.value == index
                  ? themeChange.getThem()
                      ? AppThemeData.neutral50
                      : AppThemeData.neutral900
                  : themeChange.getThem()
                      ? AppThemeData.neutralDark500
                      : AppThemeData.neutral500,
              BlendMode.srcIn),
        ),
      ),
      label: label,
    );
  }
}
