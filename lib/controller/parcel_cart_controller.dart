import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:cabme/constant/constant.dart';
import 'package:cabme/constant/show_toast_dialog.dart';
import 'package:cabme/model/book_parcel_model.dart';
import 'package:cabme/model/discount_list_model.dart';
import 'package:cabme/model/parcel_category_model..dart';
import 'package:cabme/model/parcel_category_model.dart';
import 'package:cabme/model/payStackURLModel.dart';
import 'package:cabme/model/payment_setting_model.dart';
import 'package:cabme/model/stripe_failed_model.dart';
import 'package:cabme/model/user_model.dart';
import 'package:cabme/model/xenditModel.dart';
import 'package:cabme/page/dashboard_screen.dart';
import 'package:cabme/page/wallet/MercadoPagoScreen.dart';
import 'package:cabme/page/wallet/PayFastScreen.dart';
import 'package:cabme/page/wallet/midtrans_screen.dart';
import 'package:cabme/page/wallet/orangePayScreen.dart';
import 'package:cabme/page/wallet/payStackScreen.dart';
import 'package:cabme/page/wallet/paystack_url_genrater.dart';
import 'package:cabme/page/wallet/xenditScreen.dart';
import 'package:cabme/service/api.dart';
import 'package:cabme/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

import '../themes/app_them_data.dart';

class ParcelCartController extends GetxController {
  RxBool isLoading = true.obs;
  final Rx<TextEditingController> couponCodeTextEditController = TextEditingController().obs;
  Rx<BookParcelModel> bookParcelModel = BookParcelModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<PaymentSettingModel> paymentSettingModel = PaymentSettingModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxList<XFile> parcelImages = <XFile>[].obs;

  RxList<DiscountData> discountList = <DiscountData>[].obs;
  Rx<DiscountData> selectedDiscount = DiscountData().obs;

  Rx<ParcelCategoryData> parcelCategorydata = ParcelCategoryData().obs;

  Rx<ParcelCategory?> parcelCategory = ParcelCategory().obs;

  @override
  void onInit() {
    getArgument();
    // TODO: implement onInit
    userModel.value = Constant.getUserData();
    paymentSettingModel.value = Constant.getPaymentSetting();
    selectedPaymentMethod.value = paymentSettingModel.value.myWallet!.libelle.toString();
    super.onInit();
  }

  Future<void> getArgument() async {
    Constant.taxList.clear();
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookParcelModel.value = argumentData['bookParcelModel'];
      parcelImages.value = argumentData['parcelImages'];
      parcelCategorydata.value = argumentData['parcelCategory'];
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(double.parse(bookParcelModel.value.lat1.toString()), double.parse(bookParcelModel.value.lng1.toString()));

      for (var i = 0; i < Constant.allTaxList.length; i++) {
        if (placeMarks.first.country.toString().toUpperCase() == Constant.allTaxList[i].country!.toUpperCase()) {
          Constant.taxList.add(Constant.allTaxList[i]);
        }
      }
      log("bookParcelModel.value :: ${bookParcelModel.value.toJson()}");
      await getParcleCategory();
      calculateAmount();
    }
    await getCouponCode();
    isLoading.value = false;
    update();
  }

  Future getParcleCategory() async {
    Map<String, dynamic> bodyParams = {
      'lat_source': bookParcelModel.value.lat1,
      'lng_source': bookParcelModel.value.lng1,
      'distance': bookParcelModel.value.distance,
      'parcel_weight': bookParcelModel.value.parcelWeight
    };

    await API.handleApiRequest(request: () => http.post(Uri.parse(API.getparcelCategoryBasefare), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false).then(
      (value) {
        if (value != null) {
          ParcelCategoryModel model = ParcelCategoryModel.fromJson(value);
          if (model.success == "Failed" || model.success == "failed") {
            ShowToastDialog.showToast(model.message ?? "No Parcel available for the selected route");
            return;
          } else {
            parcelCategory.value = model.data?.firstWhereOrNull(
              (item) => item.title == parcelCategorydata.value.title,
            );
          }
        }
      },
    );
  }

  Future getCouponCode() async {
    Map<String, String> bodyParams = {
      'coupon_type': "Parcel",
    };
    await API.handleApiRequest(request: () => http.post(Uri.parse(API.discountList), headers: API.headers, body: jsonEncode(bodyParams)), showLoader: false).then(
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

  RxDouble subTotal = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;

  void calculateAmount() {
    taxAmount = 0.0.obs;
    subTotal.value = subTotal.value =
        (double.parse(bookParcelModel.value.distance ?? '0.0') * parcelCategory.value!.perKmCharge! + (double.parse(bookParcelModel.value.parcelWeight ?? '0.0') * parcelCategory.value!.perKgCharge!));
    bookParcelModel.value.amount = subTotal.value.toString();
    if (selectedDiscount.value.id != null) {
      discount.value = Constant.calculateDiscount(amount: subTotal.value.toString(), offerModel: selectedDiscount.value);
    }
    for (var element in Constant.taxList) {
      taxAmount.value = taxAmount.value + Constant().calculateTax(amount: (subTotal.value - discount.value).toString(), taxModel: element);
    }

    totalAmount.value = subTotal.value - discount.value + taxAmount.value;
    update();
  }

  Future<void> bookParcelRide() async {
    final value = Constant.getGatewayValue(
      key: selectedPaymentMethod.value,
      property: "id_payment_method",
      model: paymentSettingModel.value,
    );

    List<http.MultipartFile> files = [];

    for (var i = 0; i < parcelImages.length; i++) {
      final imageFile = http.MultipartFile.fromBytes(
        'parcel_image[]',
        File(parcelImages[i].path).readAsBytesSync(),
        filename: parcelImages[i].path.split('/').last,
      );
      files.add(imageFile);
    }

    Map<String, String> fields = {
      'id_user': Preferences.getInt(Preferences.userId).toString(),
      'lat_source': bookParcelModel.value.lat1.toString(),
      'lng_source': bookParcelModel.value.lng1.toString(),
      'lat_destination': bookParcelModel.value.lat2.toString(),
      'lng_destination': bookParcelModel.value.lng2.toString(),
      'distance': bookParcelModel.value.distance.toString(),
      'distance_unit': Constant.distanceUnit.toString(),
      'id_payment': value.toString(),
      'source_adrs': bookParcelModel.value.sourceAdrs.toString().trim(),
      'destination_adrs': bookParcelModel.value.destinationAdrs.toString().trim(),
      'sender_name': bookParcelModel.value.senderName.toString().trim(),
      'receiver_name': bookParcelModel.value.receiverName.toString().trim(),
      'sender_phone': bookParcelModel.value.senderPhone.toString().trim(),
      'receiver_phone': bookParcelModel.value.receiverPhone.toString().trim(),
      'note': bookParcelModel.value.note.toString().trim(),
      'parcel_weight': bookParcelModel.value.parcelWeight.toString().trim(),
      'parcel_dimension': bookParcelModel.value.parcelDimension.toString().trim(),
      'parcel_type': bookParcelModel.value.parcelType.toString().trim(),
      'parcel_date': bookParcelModel.value.parcelDate.toString(),
      'parcel_time': bookParcelModel.value.parcelTime.toString(),
      'receive_date': bookParcelModel.value.receiveDate.toString(),
      'receive_time': bookParcelModel.value.receiveTime.toString(),
      'amount': bookParcelModel.value.amount.toString(),
      'discount_id': selectedDiscount.value.id ?? '',
      'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final response = await API.handleMultipartRequest(
      url: API.bookParcel,
      headers: API.headers,
      fields: fields,
      files: files,
      showLoader: true,
    );

    if (response != null && response['success'] == 'success') {
      ShowToastDialog.showToast("Parcel booked successfully");
      Get.offAll(const DashboardScreen());
    } else {
      ShowToastDialog.showToast(response['message'] ?? "Something went wrong, please try again.");
      log("Book Parcel Error: ${response.toString()}");
    }
  }

  void paypalPaymentSheet(String amount, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: paymentSettingModel.value.payPal!.isLive == "yes" ? false : true,
            clientId: paymentSettingModel.value.payPal!.publicKey ?? '',
            secretKey: paymentSettingModel.value.payPal!.secretKey ?? '',
            returnURL: "com.parkme://paypalpay",
            cancelURL: "com.parkme://paypalpay",
            transactions: [
              {
                "amount": {
                  "total": amount,
                  "currency": "USD",
                  "details": {"subtotal": amount}
                },
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              bookParcelRide();
              ShowToastDialog.showToast("Payment Successful!!");
            },
            onError: (error) {
              ShowToastDialog.showToast("Payment UnSuccessful!!");
            },
            onCancel: (params) {
              ShowToastDialog.showToast("Payment UnSuccessful!!");
            }),
      ),
    );
  }

  // Strip
  Future<void> stripeMakePayment({required String amount}) async {
    log(double.parse(amount).toStringAsFixed(0));
    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      log("stripe Responce====>$paymentIntentData");

      if (paymentIntentData!.containsKey("error")) {
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                customFlow: true,
                style: ThemeMode.system,
                appearance: PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppThemeData.primaryDefault,
                  ),
                ),
                merchantDisplayName: 'GoRide'));
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  Future<void> displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ShowToastDialog.showToast("Payment successfully");
        bookParcelRide();
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.userData!.nom,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      log(paymentSettingModel.value.strip!.secretKey.toString());
      var stripeSecret = paymentSettingModel.value.strip!.secretKey;
      var response =
          await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: body, headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  //mercadoo
  void mercadoPagoMakePayment({required BuildContext context, required String amount}) {
    makePreference(amount).then((result) async {
      if (result != {}) {
        log("mercadoPagoMakePayment URL :: ${paymentSettingModel.value.mercadopago?.isSandboxEnabled == "false" ? result['init_point'] : result['sandbox_init_point']}");
        Get.to(MercadoPagoScreen(initialURl: paymentSettingModel.value.mercadopago?.isSandboxEnabled == "false" ? result['init_point'] : result['sandbox_init_point']))!.then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!");
            bookParcelRide();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!");
          }
        });
        // final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
      } else {
        ShowToastDialog.showToast("Error while transaction!");
      }
    });
  }

  Future<Map<String, dynamic>> makePreference(String amount) async {
    final headers = {
      'Authorization': 'Bearer ${paymentSettingModel.value.mercadopago!.accesstoken ?? ''}',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      "items": [
        {
          "title": "Wallet TopUp",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.userData!.email ?? ''},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return": "approved"
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return {};
    }
  }

  ///PayStack Payment Method
  Future<void> payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(amount: (double.parse(totalAmount) * 100).toString(), currency: "ZAR", secretKey: paymentSettingModel.value.payStack!.secretKey.toString()).then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentSettingModel.value.payStack!.secretKey.toString(),
          callBackUrl: paymentSettingModel.value.payStack!.callbackUrl.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!");
            bookParcelRide();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!");
          }
        });
      } else {
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
      }
    });
  }

  //flutter wave Payment Method
  Future<Null> flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${paymentSettingModel.value.flutterWave!.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.userData!.email.toString(),
        "phonenumber": userModel.value.userData!.phone, // Add a real phone number
        "name": userModel.value.userData!.prenom, // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!.then((value) {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!!");
          bookParcelRide();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      });
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  String? _ref;

  void setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // payFast
  void payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(payFastSettingData: paymentSettingModel.value.payFast!, amount: double.parse(amount.toString()).toStringAsFixed(2)).then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(htmlData: value!, payFastSettingData: paymentSettingModel.value.payFast!));
      if (isDone) {
        ShowToastDialog.showToast("Payment successfully");
        bookParcelRide();
      } else {
        ShowToastDialog.showToast("Payment Failed");
      }
    });
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': paymentSettingModel.value.razorpay!.key,
      'amount': amount * 100,
      'name': 'PoolMate',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userModel.value.userData!.phone,
        'email': userModel.value.userData!.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    ShowToastDialog.showToast("Payment Successful!!");
    bookParcelRide();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    ShowToastDialog.showToast("Payment Processing!! via");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    ShowToastDialog.showToast("Payment Failed!!");
  }

  Future<void> xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: paymentSettingModel.value.xendit!.key!.toString(),
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            bookParcelRide();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(paymentSettingModel.value.xendit!.key!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  Future<void> orangeMakePayment({required String amount, required BuildContext context}) async {
    reset();
    var id = const Uuid().v4();
    var paymentURL = await fetchToken(context: context, orderId: id, amount: amount, currency: 'USD');

    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: paymentSettingModel.value.orangePay!,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value != null) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            bookParcelRide();
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Payment Unsuccessful!! \n"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken({required String orderId, required String currency, required BuildContext context, required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${paymentSettingModel.value.orangePay!.key!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response
    print("================Responce Body : ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("================Responce Body : $responseData");
      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(context: context, amountData: amount, currency: currency, orderIdData: orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment({required String orderIdData, required BuildContext context, required String currency, required String amountData}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = paymentSettingModel.value.orangePay!.isSandboxEnabled! == "true"
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": paymentSettingModel.value.orangePay!.merchantKey ?? '',
      "currency": paymentSettingModel.value.orangePay!.isSandboxEnabled == "true" ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": paymentSettingModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url": paymentSettingModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url": paymentSettingModel.value.orangePay!.notifUrl!.toString(),
    };
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode(requestBody),
    );
    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static void reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

  Future<void> midtransMakePayment({required String amount, required BuildContext context}) async {
    await createPaymentLink(amount: amount).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            bookParcelRide();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var orderId = const Uuid().v1();
    final url = Uri.parse(paymentSettingModel.value.midtrans!.isSandboxEnabled! == "true" ? 'https://api.sandbox.midtrans.com/v1/payment-links' : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': generateBasicAuthHeader(paymentSettingModel.value.midtrans!.key!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {"finish": "https://www.google.com?merchant_order_id=$orderId"},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Payment link created: ${responseData['payment_url']}');
      return responseData['payment_url'];
    } else {
      return '';
    }
  }
}
