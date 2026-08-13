import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();

  factory PusherService() => _instance;

  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  final Map<String, Function(dynamic)> _eventCallbacks = {};
  bool _initialized = false;

  PusherService._internal();

  Future<void> init({
    required String apiKey,
    required String cluster,
  }) async {
    if (_initialized) return;
    await pusher.init(
      apiKey: apiKey,
      cluster: cluster,
      onEvent: (PusherEvent event) {
        final key = '${event.channelName}:${event.eventName}';
        if (_eventCallbacks.containsKey(key)) {
          final raw = event.data;
          dynamic decoded = raw;
          try {
            if (raw is String && raw.trim().startsWith("{")) {
              decoded = jsonDecode(raw);
            }
          } catch (e) {
            debugPrint("❌ JSON decode error: $e | raw: $raw");
          }
          _eventCallbacks[key]?.call(decoded);
        }
      },
      onConnectionStateChange: (currentState, previousState) {
        debugPrint("🔌 Connection state changed: $previousState → $currentState");
        if (currentState == 'CONNECTED') {
          for (var channel in _subscribedChannels) {
            pusher.subscribe(channelName: channel);
            debugPrint("🔄 Re-subscribed to $channel after reconnect");
          }
        }
      },
      onSubscriptionSucceeded: (channelName, data) {
        debugPrint("✅ Subscribed to $channelName");
      },
      onError: (message, code, e) {
        debugPrint("❗ Pusher Error: $message ($code)");
      },
    );

    await pusher.connect();
    _initialized = true;
  }

  final Set<String> _subscribedChannels = {};

  Future<void> subscribeToRideEvent<T>({
    required String rideId,
    required String event,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
  }) async {
    final channelName = 'ride.$rideId';
    final eventKey = '$channelName:$event';

    // ✅ Always register callback
    _eventCallbacks[eventKey] = (data) {
      final pretty = data is Map || data is List
          ? const JsonEncoder.withIndent('  ').convert(data)
          : data.toString();
      log("📬 Received event [$eventKey]: $pretty");
      try {
        final parsed = data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);
        final model = fromJson(parsed);
        onData(model);
      } catch (e, stack) {
        debugPrint("❌ Error parsing ride model: $e\nStack: $stack\nData: $data");
      }
    };

    // ✅ Only subscribe once per channel
    if (!_subscribedChannels.contains(channelName)) {
      await pusher.subscribe(channelName: channelName);
      _subscribedChannels.add(channelName);
      debugPrint("✅ Subscribed to $channelName");
    }
  }

  Future<void> subscribeCustomerRecentRide<T>({
    required String customerId,
    required String event,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
  }) async {
    final channelName = 'customerNewOrder.$customerId';
    final eventKey = '$channelName:$event';

    // ✅ Always register the callback
    _eventCallbacks[eventKey] = (data) {
      final pretty = data is Map || data is List
          ? const JsonEncoder.withIndent('  ').convert(data)
          : data.toString();
      log("📬 Received event [$eventKey]: $pretty");
      try {
        final model = fromJson(data is String ? jsonDecode(data) : Map<String, dynamic>.from(data));
        onData(model);
      } catch (e, stack) {
        debugPrint("❌ Error parsing model: $e\nStack: $stack\nData: $data");
      }
    };

    // ✅ Only subscribe once per channel
    if (!_subscribedChannels.contains(channelName)) {
      await pusher.subscribe(channelName: channelName);
      _subscribedChannels.add(channelName);
      debugPrint("✅ Subscribed to $channelName");
    }
  }

  Future<void> subscribeToDriverEvent<T>({
    required String driverId,
    required String event,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
  }) async {
    final channelName = 'driver.$driverId';
    final eventKey = '$channelName:$event';

    // ✅ Always register the callback
    _eventCallbacks[eventKey] = (data) {
      final pretty = data is Map || data is List
          ? const JsonEncoder.withIndent('  ').convert(data)
          : data.toString();
      log("📬 Received event [$eventKey]: $pretty");
      try {
        final parsed = data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);
        final model = fromJson(parsed);
        onData(model);
      } catch (e, stack) {
        debugPrint("❌ Error parsing driver model: $e\nStack: $stack\nData: $data");
      }
    };

    // ✅ Only subscribe once per channel
    if (!_subscribedChannels.contains(channelName)) {
      await pusher.subscribe(channelName: channelName);
      _subscribedChannels.add(channelName);
      debugPrint("✅ Subscribed to $channelName");
    }
  }
}
