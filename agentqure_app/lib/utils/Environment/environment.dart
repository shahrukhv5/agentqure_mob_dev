import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  // Add other environment variables here as needed
  static String get razorpayKey {
    return dotenv.env['RAZORPAY_KEY'] ?? '';
  }

  // Helper method to validate that required keys are present
  static void validateRequiredKeys() {
    final requiredKeys = ['GOOGLE_MAPS_API_KEY', 'RAZORPAY_KEY'];

    for (final key in requiredKeys) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        throw Exception('Missing required environment variable: $key');
      }
    }
  }
}