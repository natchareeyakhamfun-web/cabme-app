import 'dart:convert';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/model/parcel_category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;

class BookParcelController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> senderLocationController = TextEditingController().obs;
  Rx<TextEditingController> senderNameController = TextEditingController().obs;
  Rx<TextEditingController> senderMobileNumberController = TextEditingController().obs;
  Rx<TextEditingController> senderCountryCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> senderCountryISOCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> senderDataAndTimeController = TextEditingController().obs;
  Rx<TextEditingController> noteController = TextEditingController().obs;

  Rx<TextEditingController> receiverLocationController = TextEditingController().obs;
  Rx<TextEditingController> receiverNameController = TextEditingController().obs;
  Rx<TextEditingController> receiverMobileNumberController = TextEditingController().obs;
  Rx<TextEditingController> receiverCountryCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> receiverCountryISOCodeController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> receiverDataAndTimeController = TextEditingController().obs;

  RxnString selectedParcelHeight = RxnString();
  RxnString selectedParcelWeight = RxnString();

  RxDouble distance = 0.0.obs;
  RxString duration = "".obs;
  RxDouble subTotal = 0.0.obs;

  RxList<XFile> parcelImages = <XFile>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<ParcelCategoryData> parcelCategory = ParcelCategoryData().obs;

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parcelCategory.value = argumentData['parcelCategory'];
    }
    isLoading.value = false;
    update();
  }

  Rx<DateTime> pickUpDateTime = DateTime.now().obs;
  Rx<DateTime> dropOfDateTime = DateTime.now().obs;

  // Journey
  final Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
  final Rx<LatLng> destinationLatLong = const LatLng(0.0, 0.0).obs;
  final Rx<latlong.LatLng> departureLatLongOsm = latlong.LatLng(0.0, 0.0).obs;
  final Rx<latlong.LatLng> destinationLatLongOsm = latlong.LatLng(0.0, 0.0).obs;

  Future<void> pickDateTime({bool isPickUp = true}) async {
    DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: isPickUp == true ? pickUpDateTime.value : dropOfDateTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // Pick Time
    TimeOfDay? time = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(isPickUp == true ? pickUpDateTime.value : dropOfDateTime.value),
    );

    if (time == null) return;

    if (isPickUp) {
      pickUpDateTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      senderDataAndTimeController.value.text = '${DateFormat('dd-MMM-yyyy ').format(pickUpDateTime.value)} ${DateFormat('hh:mm a').format(pickUpDateTime.value)}';
    } else {
      dropOfDateTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);

      receiverDataAndTimeController.value.text = '${DateFormat('dd-MMM-yyyy ').format(dropOfDateTime.value)} ${DateFormat('hh:mm a').format(dropOfDateTime.value)}';
    }
  }

  Future<void> fetchGoogleDistanceAndDuration({required LatLng origin, required LatLng destination}) async {
    if (origin.latitude == 0.0 || destination.latitude == 0.0) return;

    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=${Constant.kGoogleApiKey}');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final leg = data['routes'][0]['legs'][0];

        final distanceValue = leg['distance']['value']; // in meters
        final durationValue = leg['duration']['value']; // in seconds

        // Distance
        if (Constant.distanceUnit == "KM") {
          distance.value = distanceValue / 1000.0;
        } else {
          distance.value = distanceValue / 1609.34;
        }

        // Duration
        final hours = durationValue ~/ 3600;
        final minutes = ((durationValue % 3600) / 60).round();
        duration.value = '${hours}h ${minutes}m';
      } else {
        print("Google API error: ${data['status']}");
      }
    } catch (e) {
      print("Google simple route error: $e");
    }
  }

  Future<void> fetchOsmDistanceAndDuration({required latlong.LatLng origin, required latlong.LatLng destination}) async {
    final coordinates = '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/$coordinates?overview=false');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final dist = route['distance'];
        final dur = route['duration'];

        // Distance
        if (Constant.distanceUnit == "KM") {
          distance.value = dist / 1000.0;
        } else {
          distance.value = dist / 1609.34;
        }

        // Duration
        final hours = dur ~/ 3600;
        final minutes = ((dur % 3600) / 60).round();
        duration.value = '${hours}h ${minutes}m';
        print('Distance: ${distance.value} ${Constant.distanceUnit}');
        print('Duration: ${duration.value}');
        print('Selected Parcel Weight: ${selectedParcelWeight.value}');
        print('Selected Parcel Weight: ${selectedParcelWeight.value}');
      } else {
        print("OSRM API error: ${data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("OSRM simple route error: $e");
    }
  }

  void onCameraClick(context) {
    final action = CupertinoActionSheet(
      message: Text(
        'Add your parcel image.'.tr,
        style: const TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            await ImagePicker().pickMultiImage().then((value) {
              for (var element in value) {
                parcelImages.add(element);
              }
            });
          },
          child: Text('Choose image from gallery'.tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
            if (photo != null) {
              parcelImages.add(photo);
            }
          },
          child: Text('Take a picture'.tr),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel'.tr,
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  RxList<String> parcelHeight = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "60"
  ].obs;

  RxList<String> parcelWeight = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "60"
  ].obs;
}
