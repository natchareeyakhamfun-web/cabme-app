import 'dart:convert';
import 'dart:math';

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/ride_satatus.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/booking_mode.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/service/pusher_service.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BookingDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  RxList<Stops> locationData = <Stops>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();

    super.onInit();
  }

  Rx<BookingData> bookingModel = BookingData().obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingModel.value = argumentData['bookingModel'];
      setBookingData(bookingModel.value);
      await getPusherBookingData();
    }
    isLoading.value = false;
    update();
  }

  Future<void> getPusherBookingData() async {
    if (bookingModel.value.statut == RideStatus.newRide || bookingModel.value.statut == RideStatus.confirmed || bookingModel.value.statut == RideStatus.onRide) {
      PusherService().subscribeToRideEvent<BookingModel>(
        rideId: bookingModel.value.id.toString(),
        event: 'updated',
        fromJson: BookingModel.fromJson,
        onData: (ride) {
          setBookingData(ride.data!);
        },
      );
    }

    Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.id,
    };

    print(bodyParams);
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.getBookingDetails), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false).then(
      (value) async {
        if (value != null) {
          if (value['success'] == "Failed" || value['success'] == "failed") {
            ShowToastDialog.showToast(value['error'] ?? "Booking data not found");
            return null;
          } else {
            BookingModel bookingData = BookingModel.fromJson(value);
            if (bookingData.data == null) {
              ShowToastDialog.showToast("Booking data not found");
              return;
            }
            setBookingData(bookingData.data!);
          }
        }
      },
    );
  }

  void setBookingData(BookingData booking) {
    bookingModel.value = booking;
    locationData.clear();
    locationData.add(Stops(location: booking.departName, latitude: booking.latitudeDepart, longitude: booking.longitudeDepart));
    if (booking.stops != null) {
      locationData.addAll(booking.stops!.map((e) => Stops(location: e.location, latitude: e.latitude, longitude: e.longitude)));
    }
    locationData.add(Stops(location: booking.destinationName, latitude: booking.latitudeArrivee, longitude: booking.longitudeArrivee));
    calculateTotalAmount();
    if (Constant.selectedMapType == 'osm') {
      fetchRoute();
    } else {
      getPolyline();
    }
  }

  RxString subTotal = "0.0".obs;
  RxString bumpAmount = "0.0".obs;
  RxString taxAmount = "0.0".obs;
  RxString discount = "0.0".obs;
  RxString totalAmount = "0.0".obs;

  void calculateTotalAmount() {
    taxAmount = "0.0".obs;
    subTotal.value = bookingModel.value.montant.toString();
    bumpAmount.value = bookingModel.value.bumpAmount.toString();
    for (var element in bookingModel.value.tax!) {
      taxAmount.value = (double.parse(taxAmount.value) + Constant().calculateTax(amount: ((double.parse(subTotal.value)) - (double.parse(discount.value))).toString(), taxModel: element))
          .toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
    }
    if (bookingModel.value.discountType != null) {
      discount.value = Constant.calculateDiscountOrder(amount: subTotal.value, offerModel: bookingModel.value.discountType).toString();
    }
    totalAmount.value = ((double.parse(subTotal.value) - (double.parse(discount.value))) + double.parse(taxAmount.value)).toStringAsFixed(int.tryParse(Constant.decimal.toString()) ?? 2);
    update();
  }

  gmaps.GoogleMapController? googleMapController;

  List<latlong.LatLng> get osmPoints => locationData.map((e) => latlong.LatLng(double.parse(e.latitude!), double.parse(e.longitude!))).toList();

  RxList<latlong.LatLng> routePoints = <latlong.LatLng>[].obs;

  Future<void> fetchRoute() async {
    try {
      final allCoordinates = [
        ...osmPoints.map((stop) => '${stop.longitude},${stop.latitude}'),
      ];

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${allCoordinates.join(';')}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final geometry = decoded['routes'][0]['geometry']['coordinates'];

        routePoints.clear();
        for (var coord in geometry) {
          final lon = coord[0];
          final lat = coord[1];
          routePoints.add(latlong.LatLng(lat, lon));
        }
        update();
      } else {
        print("Failed to get route: ${response.body}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.kGoogleApiKey.toString());

  void getPolyline() async {
    if (googlePoints.length < 2) return;

    final source = googlePoints.first;
    final destination = googlePoints.last;

    if (source.latitude == 0.0 || destination.latitude == 0.0) return;

    final intermediateStops = googlePoints.length > 2 ? googlePoints.sublist(1, googlePoints.length - 1) : <LatLng>[];

    final wayPoints = intermediateStops.map((stop) => PolylineWayPoint(location: "${stop.latitude},${stop.longitude}")).toList();

    final polylineRequest = PolylineRequest(
      origin: PointLatLng(source.latitude, source.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      wayPoints: wayPoints,
      mode: TravelMode.driving,
    );

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: polylineRequest,
      );

      if (result.points.isEmpty) {
        print("Polyline error: ${result.errorMessage}");
        return;
      }

      final polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();

      _addPolyLine(polylineCoordinates);
    } catch (e) {
      print("Exception while fetching polyline: $e");
    }
  }

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      color: Colors.blue,
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      width: 6,
    );
    polyLines[id] = polyline;
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  List<gmaps.LatLng> get googlePoints => locationData.map((e) => gmaps.LatLng(double.parse(e.latitude!), double.parse(e.longitude!))).toList();

  void fitGoogleBounds() {
    if (locationData.length < 2) return;

    final bounds = gmaps.LatLngBounds(
      southwest: gmaps.LatLng(
        locationData.map((e) => double.parse(e.latitude!)).reduce(min),
        locationData.map((e) => double.parse(e.longitude!)).reduce(min),
      ),
      northeast: gmaps.LatLng(
        locationData.map((e) => double.parse(e.latitude!)).reduce(max),
        locationData.map((e) => double.parse(e.longitude!)).reduce(max),
      ),
    );

    googleMapController?.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  Future<void> cancelRequest() async {
    Map<String, dynamic> bodyParams = {
      'id_ride': bookingModel.value.id.toString(),
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'reason': "Cancelled by user",
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.setCancelledRequete), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: true).then(
      (value) {
        if (value != null) {
          if (value['success'] == "Failed") {
            ShowToastDialog.showToast(value['error']);
            return null;
          } else {
            ShowToastDialog.showToast("Ride cancelled successfully");
            Get.back(result: true);
          }
        }
      },
    );
  }
}
