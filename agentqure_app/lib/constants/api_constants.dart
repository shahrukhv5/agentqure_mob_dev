import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs
  static String get appUserBaseUrl => dotenv.env['APP_USER_BASE_URL'] ?? 'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/';
  static String get standardOrgBaseUrl => dotenv.env['STANDARD_ORG_BASE_URL'] ?? 'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/';
  static String get messageCentralBaseUrl => dotenv.env['MESSAGE_CENTRAL_BASE_URL'] ?? 'https://cpaas.messagecentral.com/';
  static String get googleMapsBaseUrl => dotenv.env['GOOGLE_MAPS_BASE_URL'] ?? 'https://maps.googleapis.com/maps/api/';
  // Endpoints (appended to base URLs)
  static const String listAppUser = 'app-user/list-app-user';
  static const String registerAppUser = 'app-user/register-app-user';
  static const String listStandardOrganizations = 'standardOrganization/mobile-list-standard-organizations';
  static const String listRelations = 'relation/list-relations';
  static const String authTokensForOtp = 'auth-tokens-for-otp';
  static const String sendOtp = 'verification/v3/send';
  static const String validateOtp = 'verification/v3/validateOtp';
  static const String bookingSlot = 'booking-slot';
  static const String registerBookingRequests = 'bookings/booking-requests/register-booking-requests';
  static const String listBookingRequests = 'bookings/booking-requests/list-booking-requests';
  static const String bookingRequestDecisions = 'bookings/booking-requests/booking-request-decisions';
  static const String listOrgLabPartners = 'test-prices/list-org-labprtners/';
  static const String userBookings = 'app-user/user-bookings';
  static const String bookingStatus = 'bookings/booking-status';
}