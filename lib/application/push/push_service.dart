import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../core/observability/crash_reporter.dart';
import '../../core/utils/logger.dart';

/// Thin wrapper over Firebase Cloud Messaging. Registered + `init()`ed from
/// `bootstrap.dart` only when Firebase came up. Backend device registration
/// (`POST /api/v1/devices`) is a 7a backend dependency — marked TODO below.
class PushService {
  PushService([FirebaseMessaging? messaging])
    : _fm = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _fm;
  String? token;

  Future<void> init() async {
    try {
      await _fm.requestPermission();
      token = await _fm.getToken();
      if (token != null) {
        CrashReporter.instance.breadcrumb('fcm token acquired');
        // TODO(7a): AuthRepository.registerDevice(token) → POST /api/v1/devices
      }
      _fm.onTokenRefresh.listen((t) {
        token = t;
        // TODO(7a): re-register the refreshed token
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_route);
      final initial = await _fm.getInitialMessage();
      if (initial != null) _route(initial);
    } on Object catch (e, s) {
      AppLog.w('push init failed: $e');
      unawaited(CrashReporter.instance.recordError(e, s, context: 'push.init'));
    }
  }

  /// Deep-link a notification tap through the same route path the in-app list
  /// uses (`AppNotification.route`).
  void _route(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && route.isNotEmpty) {
      Get.toNamed<void>(route);
    }
  }
}
