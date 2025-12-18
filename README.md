
# Real-time Order Alert System

A robust real-time order notification system built with Flutter and Laravel, featuring WebSocket integration for instant order alerts.

## Features

- Real-time order notifications using WebSocket
- Background service for persistent connections
- Sound alerts for new orders
- Non-dismissible alert dialogs
- Automatic reconnection handling
- SSL support
- Cross-platform support (Android & iOS)


## Prerequisites

- Flutter SDK (latest stable version)
- Laravel 8.x or higher
- PHP 7.4 or higher
- Composer
- Node.js and NPM

## Setup

### Laravel Backend

1. Install dependencies:
```bash
composer install
```

2. Configure environment variables in `.env`:
```env
WEBSOCKET_HOST=0.0.0.0
WEBSOCKET_PORT=8080
WEBSOCKET_ALLOWED_ORIGINS=*
WEBSOCKET_SSL_ENABLED=false
```

3. Start the WebSocket server:
```bash
php artisan websocket:serve
```

### Flutter Frontend

1. Install dependencies:
```bash
flutter pub get
```

2. Configure environment variables in `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-api-url';
  // ... other configurations
}
```

3. Run the app:
```bash
flutter run
```

## Android Configuration

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## iOS Configuration

Add the following to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
    <string>audio</string>
    <string>processing</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
```

## Usage

The system automatically handles:
- WebSocket connection management
- Background service operation
- Order notifications
- Sound alerts
- Reconnection attempts

## Testing

1. Connection Testing:
   - Test WebSocket connection in different network conditions
   - Verify automatic reconnection
   - Check background service persistence

2. Order Flow Testing:
   - Send test orders through the API
   - Verify notification delivery
   - Test alert dialog behavior
   - Confirm sound alerts

3. App State Testing:
   - Test in foreground
   - Test in background
   - Test after app closure
   - Test after device restart

## Troubleshooting

1. Connection Issues:
   - Check network connectivity
   - Verify WebSocket server is running
   - Check SSL configuration if enabled
   - Review server logs

2. Notification Issues:
   - Verify permissions are granted
   - Check sound settings
   - Review notification settings

3. Background Service Issues:
   - Check battery optimization settings
   - Verify background mode is enabled
   - Review system logs

## Support

For issues and feature requests, please create an issue in the repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
