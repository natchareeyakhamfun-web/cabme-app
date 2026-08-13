import 'package:cabme/controller/splash_controller.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/responsive.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            width: Responsive.width(100, context),
            color: AppThemeData.primaryDefault,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/customer_logo.png",
                    width: 120,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to CabME'.tr,
                    textAlign: TextAlign.start,
                    style: AppThemeData.boldTextStyle(color: AppThemeData.neutral900, fontSize: 24),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'A modern way to ride, parcel & rent a car'.tr,
                    textAlign: TextAlign.start,
                    style: AppThemeData.regularTextStyle(color: AppThemeData.neutral500, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
