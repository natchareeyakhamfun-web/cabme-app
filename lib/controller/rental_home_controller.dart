import 'dart:convert';
import 'dart:developer';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/model/payment_setting_model.dart';
import 'package:cabme/model/rental_package_model.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:location/location.dart';

class RentalHomeController extends GetxController {
  final RxBool isLoading = true.obs;

  // Controllers
  late GoogleMapController mapController;
  final flutterMap.MapController mapOsmController = flutterMap.MapController();
  final Rx<TextEditingController> couponCodeTextEditController = TextEditingController().obs;

  final RxString bottomSheetType = 'location'.obs; // location,preferences,payment,conformRide

  // Text Controllers
  final Rx<TextEditingController> sourceTextEditController = TextEditingController().obs;

// Map Markers & Routes
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxList<flutterMap.Marker> osmMarker = <flutterMap.Marker>[].obs;
  final RxList<latlong.LatLng> routePoints = <latlong.LatLng>[].obs;

  // Location
  final Rx<Location> currentLocation = Location().obs;
  final Rx<LatLng> currentPosition = LatLng(23.0225, 72.5714).obs;

  // Journey
  final Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
  final Rx<latlong.LatLng> departureLatLongOsm = latlong.LatLng(0.0, 0.0).obs;

  RxList<VehicleData> vehicleList = <VehicleData>[].obs;
  Rx<VehicleData> selectedVehicle = VehicleData().obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<PaymentSettingModel> paymentSettingModel = PaymentSettingModel().obs;
  RxString selectedPaymentMethod = "".obs;

  RxList<RentalPackageData> rentalPackageList = <RentalPackageData>[].obs;
  Rx<RentalPackageData> selectedRentalPackage = RentalPackageData().obs;

  RxList<DiscountData> discountList = <DiscountData>[].obs;
  Rx<DiscountData> selectedDiscount = DiscountData().obs;

  Rx<DateTime> pickUpDateTime = DateTime.now().obs;
  Rx<TextEditingController> pickUpDateTimeController = TextEditingController().obs;

  @override
  void onInit() {
    initData();
    userModel.value = Constant.getUserData();

    super.onInit();
  }

  Future<void> initData() async {
    await setIcons();
    if (Constant.selectedMapType == 'osm') {
      mapOsmController; // already initialized
      if (Constant.currentLocation != null) {
        setDepartureMarker(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
      }
    }

    await getVehicle();
    // await getCouponCode();
    paymentSettingModel.value = Constant.getPaymentSetting();
    selectedPaymentMethod.value = paymentSettingModel.value.myWallet!.libelle.toString();
    isLoading.value = false;
    update();
  }

  RxString subTotalBeforeRideAmount = "0.0".obs;
  RxString discountBeforeRideAmount = "0.0".obs;
  RxString totalBeforeRideAmount = "0.0".obs;

  RxString subTotal = "0.0".obs;
  RxString discount = "0.0".obs;
  RxString taxAmount = "0.0".obs;
  RxString totalAmount = "0.0".obs;

  void calculateAmountBeforeRide() {
    subTotalBeforeRideAmount.value = selectedRentalPackage.value.baseFare.toString();
    if (selectedDiscount.value.id != null) {
      discountBeforeRideAmount.value = Constant.calculateDiscount(amount: subTotalBeforeRideAmount.value, offerModel: selectedDiscount.value).toString();
    }
    totalBeforeRideAmount.value = (double.parse(subTotalBeforeRideAmount.value) - double.parse(discountBeforeRideAmount.value)).toString();
    update();
  }

  Future<void> bookRide() async {
    final value = Constant.getGatewayValue(
      key: selectedPaymentMethod.value,
      property: "id_payment_method",
      model: paymentSettingModel.value,
    );

    Map<String, String> fields = {
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'lat_source': Constant.selectedMapType == 'google' ? departureLatLong.value.latitude.toString() : departureLatLongOsm.value.latitude.toString(),
      'lng_source': Constant.selectedMapType == 'google' ? departureLatLong.value.longitude.toString() : departureLatLongOsm.value.longitude.toString(),
      'id_payment': value.toString(),
      'depart_name': sourceTextEditController.value.text,
      'id_rental_package': selectedRentalPackage.value.id.toString(),
      'id_vehicle_type': selectedVehicle.value.id.toString(),
      'amount': selectedRentalPackage.value.baseFare.toString(),
      'discount_id': selectedDiscount.value.id ?? '',
      'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
      "start_date": DateFormat('yyyy-MM-dd').format(pickUpDateTime.value),
      "start_time": DateFormat('HH:mm').format(pickUpDateTime.value),
      "end_date": DateFormat('yyyy-MM-dd').format(pickUpDateTime.value.add(Duration(hours: int.parse(selectedRentalPackage.value.includedHours.toString())))),
      "end_time": DateFormat('HH:mm').format(pickUpDateTime.value.add(Duration(hours: int.parse(selectedRentalPackage.value.includedHours.toString())))),
    };

    await API.handleApiRequest(request: () => http.post(Uri.parse(API.rentalRegister), headers: API.headers, body: jsonEncode(fields)), showLoader: true).then(
      (value) {
        if (value != null) {
          if (value['success'] == "failed" || value['success'] == "Failed") {
            ShowToastDialog.showToast(value['message']);
            return null;
          } else {
            Get.back();
            ShowToastDialog.showToast("Rental ride booked successfully");
          }
        }
      },
    );
  }

  Future<void> pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: pickUpDateTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // Pick Time
    TimeOfDay? time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(pickUpDateTime.value),
    );

    if (time == null) return;

    pickUpDateTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    pickUpDateTimeController.value.text = '${DateFormat('dd-MMM-yyyy ').format(pickUpDateTime.value)} ${DateFormat('hh:mm a').format(pickUpDateTime.value)}';
  }

  Future<void> getRentalPackage({bool? isReDirect}) async {
    Map<String, String> request = {
      'vehicleTypeId': selectedVehicle.value.id.toString(),
    };
    print("==>$request");
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.getRentalPackages), body: jsonEncode(request), headers: API.headers), showLoader: true).then((value) {
      if (value != null) {
        RentalPackageModel model = RentalPackageModel.fromJson(value);
        if (model.success == "success") {
          rentalPackageList.value = model.data ?? [];
          if (rentalPackageList.isEmpty) {
            ShowToastDialog.showToast('No rental packages available');
          } else {
            if (isReDirect == true) {
              bottomSheetType.value = "packageBottom";
            }
          }
        }
      }
    }).catchError((error) {
      log('Error fetching rental packages: $error');
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    update();
  }

  void setDepartureMarker(double lat, double long) {
    if (Constant.selectedMapType == 'osm') {
      _setOsmMarker(lat, long, isDeparture: true);
    } else {
      _setGoogleMarker(lat, long, isDeparture: true);
    }
  }

  void _setOsmMarker(double lat, double lng, {required bool isDeparture}) {
    final marker = flutterMap.Marker(
      point: latlong.LatLng(lat, lng),
      width: 40,
      height: 40,
      child: isDeparture ? departureIconOsm! : destinationIconOsm!,
    );
    if (isDeparture) {
      departureLatLongOsm.value = latlong.LatLng(lat, lng);
    }
    osmMarker.add(marker);
  }

  void _setGoogleMarker(double lat, double lng, {required bool isDeparture}) {
    final LatLng pos = LatLng(lat, lng);
    final markerId = MarkerId(isDeparture ? 'Departure' : 'Destination');
    final icon = isDeparture ? departureIcon! : destinationIcon!;
    final title = isDeparture ? 'Departure'.tr : 'Destination'.tr;

    if (isDeparture) {
      departureLatLong.value = pos;
    }
    // Remove only the matching departure/destination marker
    markers.removeWhere((marker) => marker.markerId == markerId);

    // Add new marker
    markers.add(Marker(markerId: markerId, position: pos, icon: icon, infoWindow: InfoWindow(title: title)));

    mapController.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
  }

  Future<void> animateToSource(double lat, double long) async {
    mapOsmController.move(latlong.LatLng(lat, long), 12);
  }

  // Icons
  BitmapDescriptor? departureIcon, destinationIcon, taxiIcon, stopIcon;
  Widget? departureIconOsm, destinationIconOsm, taxiIconOsm, stopIconOsm;

  Future<void> setIcons() async {
    try {
      if (Constant.selectedMapType == 'osm') {
        departureIconOsm = Image.asset("assets/icons/pickup.png", width: 30, height: 30);
        destinationIconOsm = Image.asset("assets/icons/dropoff.png", width: 30, height: 30);
        taxiIconOsm = Image.asset("assets/icons/ic_taxi.png", width: 30, height: 30);
        stopIconOsm = Image.asset("assets/icons/location.png", width: 26, height: 26);
      } else {
        const config = ImageConfiguration(size: Size(48, 48));
        departureIcon = await BitmapDescriptor.fromAssetImage(config, "assets/icons/pickup.png");
        destinationIcon = await BitmapDescriptor.fromAssetImage(config, "assets/icons/dropoff.png");
        taxiIcon = await BitmapDescriptor.fromAssetImage(config, "assets/icons/ic_taxi.png");
        stopIcon = await BitmapDescriptor.fromAssetImage(config, "assets/icons/location.png");
      }
    } catch (e) {
      print('Error loading icons: $e');
    }
  }

  Future getVehicle() async {
    await API.handleApiRequest(request: () => http.get(Uri.parse(API.getVehicleCategoryRental), headers: API.headers), showLoader: false).then(
      (value) {
        if (value != null) {
          VehicleCategoryModel model = VehicleCategoryModel.fromJson(value);
          vehicleList.value = model.data ?? [];
          if (vehicleList.isNotEmpty) {
            selectedVehicle.value = vehicleList.first;
            getRentalPackage();
          } else {
            ShowToastDialog.showToast('No vehicles available');
          }
        }
      },
    );
  }

  void removeSource() {
    // Clear departure location and related data
    departureLatLongOsm.value = latlong.LatLng(0.0, 0.0);
    departureLatLong.value = const LatLng(0.0, 0.0);
    sourceTextEditController.value.clear();

    // Remove marker
    if (Constant.selectedMapType == 'osm') {
      osmMarker.removeWhere((marker) => marker.point == departureLatLongOsm.value);
    } else {
      markers.removeWhere((marker) => marker.markerId.value == 'Departure');
    }

    update();
  }

  Future<void> searchPlaceNameGoogle() async {
    final lat = departureLatLong.value.latitude;
    final lng = departureLatLong.value.longitude;

    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constant.kGoogleApiKey}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'];
          sourceTextEditController.value.text = formattedAddress;
        }
      } else {
        log("Google API Error: ${data['status']}");
      }
    } else {
      log("HTTP Error: ${response.statusCode}");
    }
  }
}
