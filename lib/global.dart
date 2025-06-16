import 'package:flutter/foundation.dart';

/*
  * Global configuration for the application.
  * This file contains constants and utility functions used throughout the app.
   http://192.168.2.36:8008 (local development)
   https://smlgoapi.dedepos.com (production)
*/
String apiBaseUrl() {
  return (kDebugMode)
      ? 'http://192.168.2.36:8008' // Debug mode (local development)
      : 'https://smlgoapi.dedepos.com'; // Release mode (production)
}
