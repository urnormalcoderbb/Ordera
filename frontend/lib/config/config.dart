import 'package:flutter/foundation.dart';

class AppConfig {
  /// Toggle this to false for cloud production
  static const bool isDevelopment = kDebugMode;

  /// Local Development Settings
  /// If testing on physical devices in the same WiFi: use your machine's Local IP (e.g., '192.168.1.5')
  /// Android Emulator: use '10.0.2.2'
  static const String devHost = "127.0.0.1:8000";

  /// Production Cloud Settings (Replace with your actual domain after deployment)
  static const String prodHost = "api.ordera-app.com";

  static String get _activeHost => isDevelopment ? devHost : prodHost;
  static String get _activeProtocol => isDevelopment ? "http" : "https";
  static String get _activeWsProtocol => isDevelopment ? "ws" : "wss";

  static String get apiBaseUrl => "$_activeProtocol://$_activeHost";
  static String get wsBaseUrl => "$_activeWsProtocol://$_activeHost";

  /// Sentry configuration
  static const String sentryDsn = ""; 
}
