import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/model/admin_commission.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/model/language_model.dart';
import 'package:cabme/model/rental_booking_model.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:flutter/services.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/payment_setting_model.dart';
import 'package:cabme/model/tax_model.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/page/chats_screen/conversation_screen.dart';

import 'package:cabme/utils/Preferences.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class Constant {
  static String? pusherApiKey = "";
  static String? cluster = "";

  static String? kGoogleApiKey = "";
  static String? distanceUnit = "KM";
  static String? appVersion = "0.0";
  static String? decimal = "2";
  static String? currency = "\$";
  static String? driverRadius = "0";
  static bool symbolAtRight = false;
  static List<TaxModel> allTaxList = [];
  static List<TaxModel> taxList = [];
  static String liveTrackingMapType = "osm";
  static String selectedMapType = 'google'; // 'osm'
  static List<dynamic> activeServices = [];
  static String driverLocationUpdate = "10";
  static String deliverChargeParcel = "0";
  static String? parcelPerWeightCharge = "";
  static String? jsonNotificationFileURL = "";
  static String? senderId = "";
  static String? homeScreenType = "OlaHome"; //"OlaHome"; // "UberHome";
  static String globalUrl = "https://cabme.siswebapp.com/";

  static String placeholderUrl = 'https://cabme.siswebapp.com/assets/images/placeholder_image.jpg';

  static String? defaultCountryCode = 'IN';

  static String? contactUsEmail = "", contactUsAddress = "", contactUsPhone = "";
  static String? rideOtp = "yes";

  static String stripePublishablekey = "";

  static geolocator.Position? currentLocation;

  static CollectionReference conversation = FirebaseFirestore.instance.collection('conversation');
  static CollectionReference driverLocationUpdateCollection = FirebaseFirestore.instance.collection('driver_location_update');

  static String getUuid() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  static UserModel getUserData() {
    final String user = Preferences.getString(Preferences.user);
    Map<String, dynamic> userMap = jsonDecode(user);
    return UserModel.fromJson(userMap);
  }

  static LanguageData getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    return LanguageData.fromJson(userMap);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.statut == "yes") {
      if (taxModel.type == "Percentage") {
        taxAmount = (double.parse(amount.toString()) * double.parse(taxModel.value!.toString())) / 100;
      } else {
        taxAmount = double.parse(taxModel.value.toString());
      }
    }
    return taxAmount;
  }

  static String timestampToDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy hh:mm aa').format(dateTime);
  }

  static double calculateDiscount({String? amount, DiscountData? offerModel}) {
    double taxAmount = 0.0;
    if (offerModel != null) {
      if (offerModel.type == "Percentage" || offerModel.type == "percentage") {
        taxAmount = (double.parse(amount.toString()) * double.parse(offerModel.discount.toString())) / 100;
      } else {
        taxAmount = double.parse(offerModel.discount.toString());
      }
    }
    return taxAmount;
  }

  static double calculateDiscountOrder({String? amount, AdminCommission? offerModel}) {
    double taxAmount = 0.0;
    if (offerModel != null) {
      if (offerModel.type == "Percentage" || offerModel.type == "percentage") {
        taxAmount = (double.parse(amount.toString()) * double.parse(offerModel.value.toString())) / 100;
      } else {
        taxAmount = double.parse(offerModel.value.toString());
      }
    }
    return taxAmount;
  }

  static PaymentSettingModel getPaymentSetting() {
    final String user = Preferences.getString(Preferences.paymentSetting);
    if (user.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(user);
      return PaymentSettingModel.fromJson(userMap);
    }
    return PaymentSettingModel();
  }

  String amountShow({required String? amount}) {
    String amountdata = (amount == 'null' || amount == '' || amount == null || amount == '0') ? '0' : amount;
    if (amountdata == '0') {
      if (Constant.symbolAtRight == true) {
        return "0${Constant.currency ?? ''}";
      } else {
        return "${Constant.currency ?? ''}0";
      }
    } else {
      if (Constant.symbolAtRight == true) {
        return "${double.parse(amountdata.toString()).toStringAsFixed(Constant.decimal == null ? 2 : int.parse(Constant.decimal!))}${Constant.currency ?? ''}";
      } else {
        return "${Constant.currency ?? ''}${double.parse(amountdata.toString()).toStringAsFixed(Constant.decimal == null ? 2 : int.parse(Constant.decimal!))}";
      }
    }
  }

  bool hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static bool shouldShowRideOtp(BookingData bookingData) {
    if (Constant.rideOtp == "no") return false;
    return bookingData.statut == RideStatus.confirmed || bookingData.statut == RideStatus.onRide;
  }

  static bool get isRtl {
    final locale = Get.locale ?? Get.deviceLocale ?? const Locale('en');
    return Bidi.isRtlLanguage(locale.languageCode);
  }

  static bool shouldRentalShowRideOtp(RentalBookingData bookingData) {
    if (Constant.rideOtp == "no") return false;
    return bookingData.status == RideStatus.confirmed || bookingData.status == RideStatus.onRide;
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message, textAlign: TextAlign.center),
    );
  }

  static Widget loader(context, {Color? loadingcolor, Color? bgColor}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Center(
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor ?? (themeChange.getThem() ? AppThemeData.neutralDark100 : AppThemeData.neutral100),
          borderRadius: BorderRadius.circular(50),
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(loadingcolor ?? AppThemeData.primaryDefault),
          strokeWidth: 3,
        ),
      ),
    );
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static Future<void> launchMapURl(String? latitude, String? longLatitude) async {
    String appleUrl = 'https://maps.apple.com/?saddr=&daddr=$latitude,$longLatitude&directionsmode=driving';
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longLatitude';

    if (Platform.isIOS) {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        if (await canLaunch(googleUrl)) {
          await launch(googleUrl);
        } else {
          throw 'Could not open the map.';
        }
      }
    }
  }

  static Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('images/$uniqueID.png');

    UploadTask uploadTask = upload.putFile(image);

    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader('${'Uploading image'.tr} ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} KB');
    });
    // ignore: body_might_complete_normally_catch_error
    uploadTask.whenComplete(() {}).catchError((onError) {
      ShowToastDialog.closeLoader();
      log(onError.message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef = FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      final Uint8List thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        maxWidth: 200,
        quality: 75,
      );

      if (thumbnailBytes.isEmpty) {
        throw Exception("Failed to generate thumbnail.");
      }

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef = FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnailBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(videoUrl: Url(url: videoUrl.toString(), mime: metaData.contentType ?? 'video', videoThumbnail: thumbnailUrl), thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<File> compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path, quality: VideoQuality.DefaultQuality, deleteOrigin: false, includeAudio: true, frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<void> redirectMap({required String name, required double latitude, required double longLatitude}) async {
    if (Constant.liveTrackingMapType == "google") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.google);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.google,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google map is not installed");
      }
    } else if (Constant.liveTrackingMapType == "googleGo") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.googleGo);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.googleGo,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed");
      }
    } else if (Constant.liveTrackingMapType == "waze") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.waze);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.waze,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed");
      }
    } else if (Constant.liveTrackingMapType == "mapswithme") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.mapswithme);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.mapswithme,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed");
      }
    } else if (Constant.liveTrackingMapType == "yandexNavi") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.yandexNavi);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexNavi,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed");
      }
    } else if (Constant.liveTrackingMapType == "yandexMaps") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.yandexMaps);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexMaps,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed");
      }
    }
  }

  static String? getGatewayValue({required String key, required String property, required PaymentSettingModel model}) {
    final map = {
      model.strip!.libelle: model.strip,
      model.cash!.libelle: model.cash,
      model.myWallet!.libelle: model.myWallet,
      model.payFast!.libelle: model.payFast,
      model.payStack!.libelle: model.payStack,
      model.flutterWave!.libelle: model.flutterWave,
      model.razorpay!.libelle: model.razorpay,
      model.mercadopago!.libelle: model.mercadopago,
      model.payPal!.libelle: model.payPal,
      model.xendit!.libelle: model.xendit,
      model.orangePay!.libelle: model.orangePay,
      model.midtrans!.libelle: model.midtrans,
    };

    final matched = map[key];

    if (matched is PaymentGatewayConfig) {
      final value = matched.toJson()[property];
      return value;
    }

    print("Matched is NOT a PaymentGatewayConfig");
    return null;
  }

  static int getExtraMinutes({
    required DateTime startDate,
    required DateTime endDate,
    required String includedHours,
  }) {
    final double usedMinutes = double.parse(endDate.difference(startDate).inMinutes.toString());
    final double includedMinutes = double.parse(includedHours) * 60;
    if (usedMinutes > includedMinutes) {
      return (usedMinutes - includedMinutes).round();
    }
    return 0;
  }
}

class Url {
  String mime;

  String url;

  String? videoThumbnail;

  Url({this.mime = '', this.url = '', this.videoThumbnail});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '', videoThumbnail: parsedJson['videoThumbnail'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': mime, 'url': url, 'videoThumbnail': videoThumbnail};
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

abstract class PaymentGatewayConfig {
  Map<String, dynamic> toJson();
}
