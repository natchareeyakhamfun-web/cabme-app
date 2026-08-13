import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/model/booking_request_model.dart';
import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/model/payment_setting_model.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/model/vehicle_category_model.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/service/pusher_service.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:location/location.dart';

import '../themes/app_them_data.dart';

class BookRideController extends GetxController {
  // Controllers
  late GoogleMapController mapController;
  final flutterMap.MapController mapOsmController = flutterMap.MapController();

  final RxString bottomSheetType = 'location'.obs; // location,preferences,payment,conformRide

  final RxInt passenger = 1.obs; // location,preferences,payment,conformRide
  final RxInt children = 0.obs; // location,preferences,payment,conformRide

  RxList<DiscountData> discountList = <DiscountData>[].obs;
  Rx<DiscountData> selectedDiscount = DiscountData().obs;

  RxList<VehicleData> vehicleList = <VehicleData>[].obs;
  Rx<VehicleData> selectedVehicle = VehicleData().obs;

  // Text Controllers
  final Rx<TextEditingController> sourceTextEditController = TextEditingController().obs;
  final Rx<TextEditingController> destinationTextEditController = TextEditingController().obs;

  final Rx<TextEditingController> couponCodeTextEditController = TextEditingController().obs;

  // Map Markers & Routes
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxList<flutterMap.Marker> osmMarker = <flutterMap.Marker>[].obs;
  final RxList<latlong.LatLng> routePoints = <latlong.LatLng>[].obs;

  // Location
  final Rx<Location> currentLocation = Location().obs;
  final Rx<LatLng> currentPosition = LatLng(23.0225, 72.5714).obs;

  // Journey
  final Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
  final Rx<LatLng> destinationLatLong = const LatLng(0.0, 0.0).obs;
  final Rx<latlong.LatLng> departureLatLongOsm = latlong.LatLng(0.0, 0.0).obs;
  final Rx<latlong.LatLng> destinationLatLongOsm = latlong.LatLng(0.0, 0.0).obs;

  final RxList<AddStopModelTwo> multiStopList = <AddStopModelTwo>[].obs;

  // UI
  final RxBool isLoading = true.obs;

  // final RxBool confirmWidgetVisible = false.obs;
  final RxDouble distance = 0.0.obs;
  final RxString duration = ''.obs;

  // Icons
  BitmapDescriptor? departureIcon, destinationIcon, taxiIcon, stopIcon;
  Widget? departureIconOsm, destinationIconOsm, taxiIconOsm, stopIconOsm;

  Rx<PaymentSettingModel> paymentSettingModel = PaymentSettingModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxString selectedPaymentMethod = "".obs;

  @override
  void onInit() {
    setData();
    super.onInit();
  }

  Future<void> setData() async {
    initData();
    userModel.value = Constant.getUserData();
    isLoading.value = false;
  }

  Future<void> initData() async {
    await setIcons();
    if (Constant.selectedMapType == 'osm') {
      mapOsmController; // already initialized
      if (Constant.currentLocation != null) {
        setDepartureMarker(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude);
        searchPlaceNameOSM();
      }
    }
    await getCouponCode();
    paymentSettingModel.value = Constant.getPaymentSetting();
    selectedPaymentMethod.value = paymentSettingModel.value.myWallet!.libelle.toString();
  }

  Rx<BookingModel> bookingModel = BookingModel().obs;
  RxList<Stops> locationData = <Stops>[].obs;

  // Fare-bump (shown when no driver accepts within timeout — Uber/Ola style)
  Timer? _noDriverTimer;
  final RxBool showFareBumpOption = false.obs;
  static const int _noDriverTimeoutSeconds = 60;
  final List<double> fareBumpAmounts = const [10, 20, 30];

  void startNoDriverTimer() {
    cancelNoDriverTimer();
    _noDriverTimer = Timer(const Duration(seconds: _noDriverTimeoutSeconds), () {
      showFareBumpOption.value = true;
    });
  }

  void cancelNoDriverTimer() {
    _noDriverTimer?.cancel();
    _noDriverTimer = null;
    showFareBumpOption.value = false;
  }

  Future<void> increaseFare(double bumpAmount) async {
    if (bookingModel.value.data == null) return;
    final currentAmount = double.tryParse(bookingModel.value.data!.montant.toString()) ?? 0.0;
    final newAmount = currentAmount + bumpAmount;
    final Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.data!.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'new_amount': newAmount.toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2),
      'bump_amount': bumpAmount.toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2),
    };
    await API
        .handleApiRequest(
      request: () => http.post(Uri.parse(API.increaseFare), headers: API.headers, body: jsonEncode(bodyParams)),
      showLoader: true,
    )
        .then((value) {
      if (value == null) return;
      if (value['success'] == 'Failed' || value['success'] == 'failed') {
        ShowToastDialog.showToast(value['message']?.toString() ?? 'Unable to update fare');
        return;
      }
      bookingModel.value.data!.montant = newAmount.toString();
      bookingModel.refresh();
      ShowToastDialog.showToast("Fare updated. Searching for a driver...");
      startNoDriverTimer();
    });
  }

  Future<void> getBookingData() async {
    PusherService().subscribeToRideEvent<BookingModel>(
      rideId: bookingModel.value.data!.id.toString(),
      event: 'updated',
      fromJson: BookingModel.fromJson,
      onData: (ride) {
        log("Live Ride Update for user: ${ride.data!.statut}");
        if (ride.data!.statut == RideStatus.confirmed && ride.data!.idConducteur != null && ride.data!.idConducteur!.isNotEmpty) {
          cancelNoDriverTimer();
          setBookingData(ride);
          calculateTotalAmount();
          bottomSheetType.value = 'driverDetails';
        } else if (ride.data!.statut == RideStatus.canceled) {
          cancelNoDriverTimer();
          ShowToastDialog.showToast("Ride canceled");
          Get.back();
        }
      },
    );
  }

  void setBookingData(BookingModel booking) {
    bookingModel.value = booking;
    if (booking.data != null) {
      if (booking.data!.statut == RideStatus.newRide ||
          booking.data!.statut == RideStatus.confirmed ||
          booking.data!.statut == RideStatus.onRide) {
        locationData.clear();

        locationData.add(
            Stops(location: booking.data!.departName, latitude: booking.data!.latitudeDepart, longitude: booking.data!.longitudeDepart));
        if (booking.data!.stops != null) {
          locationData.addAll(booking.data!.stops!.map((e) => Stops(location: e.location, latitude: e.latitude, longitude: e.longitude)));
        }
        locationData.add(Stops(
            location: booking.data!.destinationName, latitude: booking.data!.latitudeArrivee, longitude: booking.data!.longitudeArrivee));
      } else if (booking.data!.statut == RideStatus.canceled ||
          booking.data!.statut == RideStatus.completed ||
          booking.data!.statut == RideStatus.rejected) {
        bookingModel.value = BookingModel();
      }
    }
  }

  RxString subTotalBeforeRideAmount = "0.0".obs;
  RxString discountBeforeRideAmount = "0.0".obs;
  RxString totalBeforeRideAmount = "0.0".obs;

  RxString subTotal = "0.0".obs;
  RxString discount = "0.0".obs;
  RxString taxAmount = "0.0".obs;
  RxString totalAmount = "0.0".obs;

  void calculateTotalAmount() {
    taxAmount = "0.0".obs;
    subTotal.value = bookingModel.value.data!.montant.toString();

    if (bookingModel.value.data!.discountType != null) {
      discount.value =
          Constant.calculateDiscountOrder(amount: subTotal.value, offerModel: bookingModel.value.data!.discountType).toString();
    }
    for (var element in bookingModel.value.data!.tax!) {
      taxAmount.value = (double.parse(taxAmount.value) +
              Constant()
                  .calculateTax(amount: ((double.parse(subTotal.value)) - (double.parse(discount.value))).toString(), taxModel: element))
          .toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
    }

    totalAmount.value = ((double.parse(subTotal.value) - (double.parse(discount.value))) + double.parse(taxAmount.value))
        .toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
    update();
  }

  void calculateAmountBeforeRide() {
    subTotalBeforeRideAmount.value = calculateTripPrice(selectedVehicle.value).toString();
    if (selectedDiscount.value.id != null) {
      discountBeforeRideAmount.value =
          Constant.calculateDiscount(amount: subTotalBeforeRideAmount.value, offerModel: selectedDiscount.value).toString();
    }
    totalBeforeRideAmount.value = (double.parse(subTotalBeforeRideAmount.value) - double.parse(discountBeforeRideAmount.value)).toString();
    update();
  }

  Future<void> bookRide(BookingRequestModel bookingRequestModel) async {
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.rideBook), headers: API.headers, body: jsonEncode(bookingRequestModel.toJson())),
            showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "failed" || value['success'] == "Failed") {
            ShowToastDialog.showToast(value['message']);
            return null;
          } else {
            BookingModel bookingModelTemp = BookingModel.fromJson(value);
            if (bookingModelTemp.data != null) {
              bottomSheetType.value = 'waitingDriver';
              bookingModel.value = bookingModelTemp;
              getBookingData();
              startNoDriverTimer();
              ShowToastDialog.showToast("Ride booked successfully");
            }
          }
        }
      },
    );
  }

  Future getVehicle() async {
    Map<String, dynamic> bodyParams = {
      'latitude_depart':
          Constant.selectedMapType == 'osm' ? departureLatLongOsm.value.latitude.toString() : departureLatLong.value.latitude.toString(),
      'longitude_depart':
          Constant.selectedMapType == 'osm' ? departureLatLongOsm.value.longitude.toString() : departureLatLong.value.longitude.toString(),
      'latitude_arrivee': Constant.selectedMapType == 'osm'
          ? destinationLatLongOsm.value.latitude.toString()
          : destinationLatLong.value.latitude.toString(),
      'longitude_arrivee': Constant.selectedMapType == 'osm'
          ? destinationLatLongOsm.value.longitude.toString()
          : destinationLatLong.value.longitude.toString(),
      'distance': distance.value
    };
    print(bodyParams);
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.getVehicleCategory), headers: API.headers, body: jsonEncode(bodyParams)),
            showLoader: false)
        .then(
      (value) {
        if (value != null) {
          VehicleCategoryModel model = VehicleCategoryModel.fromJson(value);
          if (model.success == "Failed" || model.success == "failed") {
            ShowToastDialog.showToast(model.message ?? "No vehicles available for the selected route");
            return;
          } else {
            vehicleList.value = model.data ?? [];
            locationData.clear();
            locationData.add(Stops(location: sourceTextEditController.value.text, latitude: null, longitude: null));
            locationData
                .addAll(multiStopList.map((e) => Stops(location: e.editingController.text, latitude: e.latitude, longitude: e.longitude)));
            locationData.add(Stops(location: destinationTextEditController.value.text, latitude: null, longitude: null));

            bottomSheetType.value = "preferences";
          }
        }
      },
    );
  }

  Future<void> cancelRequest() async {
    Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.data!.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'reason': "Cancelled by user",
    };
    print(bodyParams);
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.setCancelledRequete), headers: API.headers, body: jsonEncode(bodyParams)),
            showLoader: true)
        .then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            cancelNoDriverTimer();
            ShowToastDialog.showToast("Ride cancelled successfully");
            Get.back();
          }
        }
      },
    );
  }

  Future getCouponCode() async {
    Map<String, String> bodyParams = {
      'coupon_type': "Ride",
    };
    await API
        .handleApiRequest(
            request: () => http.post(Uri.parse(API.discountList), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false)
        .then(
      (value) {
        if (value != null) {
          DiscountListModel model = DiscountListModel.fromJson(value);
          if (model.success == "Failed" || model.success == "failed") {
            return;
          } else {
            discountList.value = model.data ?? [];
          }
        }
      },
    );
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

  void setDestinationMarker(double lat, double lng) {
    if (Constant.selectedMapType == 'osm') {
      _setOsmMarker(lat, lng, isDeparture: false);
    } else {
      _setGoogleMarker(lat, lng, isDeparture: false);
    }
  }

  void setStopMarker(double lat, double lng, int index) {
    if (Constant.selectedMapType == 'osm') {
      // Add new stop marker without clearing
      osmMarker.add(flutterMap.Marker(
        point: latlong.LatLng(lat, lng),
        width: 40,
        height: 40,
        child: stopIconOsm!,
      ));

      getDirections(isStopMarker: true);
    } else {
      final markerId = MarkerId('Stop $index');

      markers.removeWhere((marker) => marker.markerId == markerId);
      markers.add(Marker(
        markerId: markerId,
        infoWindow: InfoWindow(title: 'Stop ${String.fromCharCode(index + 65)}'),
        position: LatLng(lat, lng),
        icon: stopIcon!,
      ));

      getDirections();
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
    } else {
      destinationLatLongOsm.value = latlong.LatLng(lat, lng);
    }
    osmMarker.add(marker);
    if (departureLatLongOsm.value.latitude != 0 && destinationLatLongOsm.value.latitude != 0) {
      getDirections();
    } else {
      animateToSource(lat, lng);
    }
  }

  void _setGoogleMarker(double lat, double lng, {required bool isDeparture}) {
    final LatLng pos = LatLng(lat, lng);
    final markerId = MarkerId(isDeparture ? 'Departure' : 'Destination');
    final icon = isDeparture ? departureIcon! : destinationIcon!;
    final title = isDeparture ? 'Departure'.tr : 'Destination'.tr;

    if (isDeparture) {
      departureLatLong.value = pos;
    } else {
      destinationLatLong.value = pos;
    }

    // Remove only the matching departure/destination marker
    markers.removeWhere((marker) => marker.markerId == markerId);

    // Add new marker
    markers.add(Marker(markerId: markerId, position: pos, icon: icon, infoWindow: InfoWindow(title: title)));

    // Re-add stop markers
    for (int i = 0; i < multiStopList.length; i++) {
      final lat = double.tryParse(multiStopList[i].latitude) ?? 0.0;
      final lng = double.tryParse(multiStopList[i].longitude) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        final stopMarkerId = MarkerId('Stop $i');
        markers.removeWhere((m) => m.markerId == stopMarkerId);
        markers.add(Marker(
          markerId: stopMarkerId,
          position: LatLng(lat, lng),
          icon: stopIcon!,
          infoWindow: InfoWindow(title: 'Stop ${String.fromCharCode(65 + i)}'),
        ));
      }
    }

    mapController.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));

    if (departureLatLong.value.latitude != 0 && destinationLatLong.value.latitude != 0) {
      getDirections();
    } else {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 14)));
    }
  }

  Future<void> getDirections({bool isStopMarker = false}) async {
    if (Constant.selectedMapType == 'osm') {
      final wayPoints = <latlong.LatLng>[];

      // Only add valid source
      if (departureLatLongOsm.value.latitude != 0.0 && departureLatLongOsm.value.longitude != 0.0) {
        wayPoints.add(departureLatLongOsm.value);
      }

      // Add valid stops
      for (final stop in multiStopList) {
        final lat = double.tryParse(stop.latitude) ?? 0;
        final lng = double.tryParse(stop.longitude) ?? 0;
        if (lat != 0 && lng != 0) {
          wayPoints.add(latlong.LatLng(lat, lng));
        }
      }

      // Only add valid destination
      if (destinationLatLongOsm.value.latitude != 0.0 && destinationLatLongOsm.value.longitude != 0.0) {
        wayPoints.add(destinationLatLongOsm.value);
      }

      if (!isStopMarker) osmMarker.clear();

      // Add stop markers
      for (final stop in multiStopList) {
        final lat = double.tryParse(stop.latitude) ?? 0;
        final lng = double.tryParse(stop.longitude) ?? 0;
        if (lat != 0 && lng != 0) {
          osmMarker.add(flutterMap.Marker(
            point: latlong.LatLng(lat, lng),
            width: 30,
            height: 30,
            child: stopIconOsm!,
          ));
        }
      }

      // Add source marker
      if (departureLatLongOsm.value.latitude != 0.0 && departureLatLongOsm.value.longitude != 0.0) {
        osmMarker.add(flutterMap.Marker(
          point: departureLatLongOsm.value,
          width: 40,
          height: 40,
          child: departureIconOsm!,
        ));
      }

      // Add destination marker
      if (destinationLatLongOsm.value.latitude != 0.0 && destinationLatLongOsm.value.longitude != 0.0) {
        osmMarker.add(flutterMap.Marker(
          point: destinationLatLongOsm.value,
          width: 40,
          height: 40,
          child: destinationIconOsm!,
        ));
      }

      if (wayPoints.length >= 2) {
        await fetchRouteWithWaypoints(wayPoints);
      }
    } else {
      // Google Maps path
      fetchGoogleRouteWithWaypoints();
    }
  }

  Future<void> fetchGoogleRouteWithWaypoints() async {
    if (departureLatLong.value.latitude == 0.0 || destinationLatLong.value.latitude == 0.0) return;

    final waypoints =
        multiStopList.where((e) => e.latitude.isNotEmpty && e.longitude.isNotEmpty).map((e) => '${e.latitude},${e.longitude}').join('|');

    final origin = '${departureLatLong.value.latitude},${departureLatLong.value.longitude}';
    final destination = '${destinationLatLong.value.latitude},${destinationLatLong.value.longitude}';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin&destination=$destination&waypoints=optimize:true|$waypoints'
      '&mode=driving&key=${Constant.kGoogleApiKey}',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      log("=======>$data");
      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final legs = route['legs'] as List;

        // Polyline
        final encodedPolyline = route['overview_polyline']['points'];
        final decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);
        final coordinates = decodedPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

        addPolyLine(coordinates);

        // Distance & Duration
        num totalDistance = 0;
        num totalDuration = 0;
        for (var leg in legs) {
          totalDistance += leg['distance']['value']!; // meters
          totalDuration += leg['duration']['value']!; // seconds
        }

        // Convert distance to KM or Miles
        if (Constant.distanceUnit == "KM") {
          distance.value = totalDistance / 1000.0;
        } else {
          distance.value = totalDistance / 1609.34;
        }

        // Format duration
        final hours = totalDuration ~/ 3600;
        final minutes = ((totalDuration % 3600) / 60).round();
        duration.value = '${hours}h ${minutes}m';
      } else {
        print('Google Directions API Error: ${data['status']}');
      }
    } catch (e) {
      print("Google route fetch error: $e");
    }
  }

  Future<void> fetchRouteWithWaypoints(List<latlong.LatLng> points) async {
    final coordinates = points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final geometry = decoded['routes'][0]['geometry']['coordinates'] as List;
        final dist = decoded['routes'][0]['distance'];
        final dur = decoded['routes'][0]['duration'];

        routePoints.clear();
        routePoints.addAll(geometry.map((coord) => latlong.LatLng(coord[1], coord[0])));

        if (Constant.distanceUnit == "KM") {
          distance.value = dist / 1000.00;
        } else {
          distance.value = dist / 1609.34;
        }

        final hours = dur ~/ 3600;
        final minutes = ((dur % 3600) / 60).round();
        duration.value = '${hours}h ${minutes}m';
      } else {
        print("Failed to get route: ${response.body}");
      }
    } catch (e) {
      print("Route fetch error: $e");
    }
  }

  Future<void> animateToSource(double lat, double long) async {
    final hasBothCoords = departureLatLongOsm.value.latitude != 0.0 && destinationLatLongOsm.value.latitude != 0.0;

    if (hasBothCoords) {
      await calculateZoomLevel(
        source: departureLatLongOsm.value,
        destination: destinationLatLongOsm.value,
      );
    } else {
      mapOsmController.move(latlong.LatLng(lat, long), 12);
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;

  void addPolyLine(List<LatLng> points) {
    final id = const PolylineId("poly");
    final polyline = Polyline(
      polylineId: id,
      color: AppThemeData.primaryDefault,
      points: points,
      width: 6,
      geodesic: true,
    );
    polyLines[id] = polyline;

    if (points.length >= 2) {
      updateCameraLocation(points.first, points.last, mapController);
    }
  }

  Future<void> calculateZoomLevel(
      {required latlong.LatLng source, required latlong.LatLng destination, double paddingFraction = 0.001}) async {
    final bounds = flutterMap.LatLngBounds.fromPoints([source, destination]);
    final screenSize = Size(Get.width, Get.height * 0.5);
    const double worldDimension = 256.0;
    const double maxZoom = 18.0;

    double latToRad(double lat) => math.log((1 + math.sin(lat * math.pi / 180)) / (1 - math.sin(lat * math.pi / 180))) / 2;

    double computeZoom(double screenPx, double worldPx, double fraction) => math.log(screenPx / worldPx / fraction) / math.ln2;

    final north = bounds.northEast.latitude;
    final south = bounds.southWest.latitude;
    final east = bounds.northEast.longitude;
    final west = bounds.southWest.longitude;

    final latDelta = (north - south).abs();
    final lngDelta = (east - west).abs();

    final center = bounds.center;

    if (latDelta < 1e-6 || lngDelta < 1e-6) {
      mapOsmController.move(center, maxZoom);
    } else {
      final latFraction = (latToRad(north) - latToRad(south)) / math.pi;
      final lngFraction = ((east - west + 360) % 360) / 360;

      final latZoom = computeZoom(screenSize.height, worldDimension, latFraction + paddingFraction);
      final lngZoom = computeZoom(screenSize.width, worldDimension, lngFraction + paddingFraction);

      final zoomLevel = math.min(latZoom, lngZoom).clamp(0.0, maxZoom);
      mapOsmController.move(center, zoomLevel);
    }
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination, GoogleMapController? mapController) async {
    if (mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(source.latitude, destination.latitude),
        math.min(source.longitude, destination.longitude),
      ),
      northeast: LatLng(
        math.max(source.latitude, destination.latitude),
        math.max(source.longitude, destination.longitude),
      ),
    );

    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 90);
    await checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    await mapController.animateCamera(cameraUpdate);
    final l1 = await mapController.getVisibleRegion();
    final l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      await checkCameraLocation(cameraUpdate, mapController);
    }
  }

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

  void clearMapDataIfLocationsRemoved() {
    final isSourceEmpty = departureLatLongOsm.value.latitude == 0.0 && departureLatLongOsm.value.longitude == 0.0;
    final isDestinationEmpty = destinationLatLongOsm.value.latitude == 0.0 && destinationLatLongOsm.value.longitude == 0.0;

    if (isSourceEmpty || isDestinationEmpty) {
      // Clear polylines
      polyLines.clear();

      // Clear OSM markers (if using OSM)
      osmMarker.clear();

      // Clear Google markers (if using Google Maps)
      markers.clear();

      // Clear route points (optional)
      routePoints.clear();

      // Reset distance and duration values
      distance.value = 0.0;
      duration.value = '';
    }
  }

  Future<void> addStops() async {
    multiStopList.add(AddStopModelTwo(editingController: TextEditingController(), latitude: "", longitude: ""));
    // multiStopList = List<AddStopModelTwo>.generate(
    //   multiStopList.length,
    //   (int index) => AddStopModelTwo(editingController: multiStopList[index].editingController, latitude: multiStopList[index].latitude, longitude: multiStopList[index].longitude),
    // );
    update();
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

    // Clear polylines and route info if needed
    clearMapDataIfLocationsRemoved();
    update();
  }

  void removeStop(int index) {
    if (index < 0 || index >= multiStopList.length) return;

    // Remove stop from the list
    multiStopList.removeAt(index);

    // Remove stop marker from map
    if (Constant.selectedMapType == 'osm') {
      osmMarker.removeWhere((marker) {
        final point = marker.point;
        final stop = multiStopList.length > index ? multiStopList[index] : null;
        if (stop == null) return false;
        final lat = double.tryParse(stop.latitude) ?? 0.0;
        final lng = double.tryParse(stop.longitude) ?? 0.0;
        return point.latitude == lat && point.longitude == lng;
      });
    } else {
      markers.removeWhere((marker) => marker.markerId.value == 'Stop $index');
    }

    // Recalculate route after removing stop
    getDirections();

    update();
  }

  void removeDestination() {
    destinationLatLongOsm.value = latlong.LatLng(0.0, 0.0);
    destinationLatLong.value = const LatLng(0.0, 0.0);
    destinationTextEditController.value.clear();

    if (Constant.selectedMapType == 'osm') {
      osmMarker.removeWhere((marker) => marker.point == destinationLatLongOsm.value);
    } else {
      markers.removeWhere((marker) => marker.markerId.value == 'Destination');
    }

    clearMapDataIfLocationsRemoved();
    update();
  }

  double calculateTripPrice(VehicleData model) {
    double cout = 0.0;
    cout = (double.tryParse(model.baseFare.toString()) ?? 0.0);
    return cout;
  }

  Future<void> searchPlaceNameOSM() async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${departureLatLongOsm.value.latitude}&lon=${departureLatLongOsm.value.longitude}&format=json');

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterMapApp/1.0 (menil.siddhiinfosoft@gmail.com)',
    });

    if (response.statusCode == 200) {
      log("response.body :: ${response.body}");
      Map<String, dynamic> data = json.decode(response.body);
      sourceTextEditController.value.text = data['display_name'] ?? '';
    }
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

  @override
  void dispose() {
    cancelNoDriverTimer();
    super.dispose();
  }
}

class PaymentGatewayData {
  final String key;
  final String secret;
  final bool enabled;

  PaymentGatewayData({
    required this.key,
    required this.secret,
    required this.enabled,
  });
}

class AddStopModelTwo {
  String latitude = "";
  String longitude = "";
  TextEditingController editingController = TextEditingController();

  AddStopModelTwo({
    required this.editingController,
    required this.latitude,
    required this.longitude,
  });
}
