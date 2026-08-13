import 'package:cabme/constant/constant.dart';
import 'package:cabme/controller/parcel_home_controller.dart';
import 'package:cabme/model/banner_model.dart';
import 'package:cabme/model/parcel_category_model.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:cabme/themes/responsive.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cabme/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'book_parcel_screen.dart';

class ParcelHomeScreen extends StatelessWidget {
  const ParcelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ParcelHomeController(),
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
              titleSpacing: 0,
              title: Text(
                "Parcel Service",
                style: AppThemeData.semiBoldTextStyle(fontSize: 18,color: themeChange.getThem()? AppThemeData.neutralDark900 : AppThemeData.neutral900),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BannerView(
                          controller: controller,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'What you want to send?'.tr,
                          textAlign: TextAlign.center,
                          style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ListView.separated(
                          itemCount: controller.parcelCategoryList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            ParcelCategoryData parcelCategoryData = controller.parcelCategoryList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(BookParcelScreen(), arguments: {"parcelCategory": parcelCategoryData});
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    NetworkImageWidget(
                                      imageUrl: parcelCategoryData.image.toString(),
                                      width: 40,
                                      height: 40,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${parcelCategoryData.title}'.tr,
                                            textAlign: TextAlign.center,
                                            style: AppThemeData.semiBoldTextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.neutralDark900 : AppThemeData.neutral900),
                                          ),
                                          Text(
                                            '${parcelCategoryData.description}'.tr,
                                            textAlign: TextAlign.start,
                                            style: AppThemeData.mediumTextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.neutralDark500 : AppThemeData.neutral500),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Divider(
                                color: themeChange.getThem() ? AppThemeData.neutralDark200 : AppThemeData.neutral200,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}

class BannerView extends StatelessWidget {
  final ParcelHomeController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: 180,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: controller.pageController.value,
        scrollDirection: Axis.horizontal,
        itemCount: controller.bannerList.length,
        padEnds: false,
        pageSnapping: true,
        allowImplicitScrolling: true,
        onPageChanged: (value) {
          controller.currentPage.value = value;
        },
        itemBuilder: (BuildContext context, int index) {
          BannerModelData bannerModel = controller.bannerList[index];
          return InkWell(
            onTap: () async {},
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Stack(
                  children: [
                    NetworkImageWidget(
                      imageUrl: bannerModel.image.toString(),
                      fit: BoxFit.cover,
                      width: Responsive.width(100, context),
                      height: Responsive.width(100, context),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bannerModel.title.tr,
                            textAlign: TextAlign.start,
                            style: AppThemeData.boldTextStyle(fontSize: 18, color: themeChange.getThem() ? AppThemeData.neutral50 : AppThemeData.neutral50),
                          ),
                          Text(
                            bannerModel.description.tr,
                            textAlign: TextAlign.start,
                            style: AppThemeData.regularTextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.neutral200 : AppThemeData.neutral200),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
