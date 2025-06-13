import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:sixam_mart_store/helper/websocket_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'websocket_service',
        initialNotificationTitle: 'Order Alert Service',
        initialNotificationContent: 'Listening for new orders',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Initialize WebSocket connection
    await WebSocketHelper.instance.connect();

    // Keep the service alive
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Order Alert Service",
          content: "Listening for new orders",
        );
      }

      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.token);
      
      if (token == null) {
        service.stopSelf();
        return;
      }

      // Ensure WebSocket connection is alive
      if (!WebSocketHelper.instance.isConnected) {
        await WebSocketHelper.instance.connect();
      }
    });
  }
} 