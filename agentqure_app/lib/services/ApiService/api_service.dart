import 'dart:convert';

import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );

  // Common config
  ApiService configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status! < 500,
    );
    return this;
  }

  // Helper: Make GET request (enhanced with queryParams and options)
  Future<Response> get({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      '$baseUrl$endpoint',
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Helper: Make POST request (enhanced with queryParams and options)
  Future<Response> post({
    required String baseUrl,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      '$baseUrl$endpoint',
      data: data,
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Helper: Make PUT request (enhanced with queryParams and options)
  Future<Response> put({
    required String baseUrl,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      '$baseUrl$endpoint',
      data: data,
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Helper: Make DELETE request (enhanced with queryParams and options)
  Future<Response> delete({
    required String baseUrl,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      '$baseUrl$endpoint',
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Reusable API Methods
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    final response = await post(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.listAppUser,
      data: {"contactNumber": phoneNumber},
    );
    if (response.statusCode == 200 &&
        response.data['body']['appUserId'] != null) {
      return response.data['body'];
    }
    return null;
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    final response = await post(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.listAppUser,
      data: {"contactNumber": phoneNumber},
    );
    return response.data['body']['appUserId'] != null;
  }

  Future<List<Map<String, dynamic>>> getOrganizations(String userId) async {
    final response = await get(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.listStandardOrganizations,
      queryParams: {'user_id': userId},
    );
    return List<Map<String, dynamic>>.from(response.data['body']['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getRelations() async {
    final response = await get(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.listRelations,
    );
    return List<Map<String, dynamic>>.from(response.data['body']['data'] ?? []);
  }

  Future<String> generateAuthToken() async {
    final response = await get(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.authTokensForOtp,
    );
    if (response.statusCode == 200 &&
        response.data['body']['success'] == true) {
      return response.data['body']['token'];
    }
    throw Exception('Failed to generate token');
  }

  // Future<Map<String, dynamic>> sendOtp(
  //   String countryCode,
  //   String mobileNumber,
  // ) async {
  //   String token = await generateAuthToken();
  //   Response response = await _dio.post(
  //     '${ApiConstants.messageCentralBaseUrl}${ApiConstants.sendOtp}',
  //     queryParameters: {
  //       'countryCode': countryCode,
  //       'flowType': 'SMS',
  //       'mobileNumber': mobileNumber,
  //     },
  //     options: Options(headers: {'authToken': token}),
  //   );
  //
  //   if (response.statusCode == 401) {
  //     // Retry with fresh token
  //     token = await generateAuthToken();
  //     response = await _dio.post(
  //       '${ApiConstants.messageCentralBaseUrl}${ApiConstants.sendOtp}',
  //       queryParameters: {
  //         'countryCode': countryCode,
  //         'flowType': 'SMS',
  //         'mobileNumber': mobileNumber,
  //       },
  //       options: Options(headers: {'authToken': token}),
  //     );
  //   }
  //
  //   if (response.statusCode == 200) {
  //     return response.data;
  //   }
  //
  //   throw Exception(response.data['message'] ?? 'Failed to send OTP');
  // }

  Future<Map<String, dynamic>> sendOtp(
      String countryCode,
      String mobileNumber,
      ) async {
    String token = await generateAuthToken();
    Response response = await _dio.post(
      '${ApiConstants.messageCentralBaseUrl}${ApiConstants.sendOtp}',
      queryParameters: {
        'countryCode': countryCode,
        'flowType': 'SMS',
        'mobileNumber': mobileNumber,
      },
      options: Options(headers: {'authToken': token}),
    );

    if (response.statusCode == 401) {
      // Retry with fresh token
      token = await generateAuthToken();
      response = await _dio.post(
        '${ApiConstants.messageCentralBaseUrl}${ApiConstants.sendOtp}',
        queryParameters: {
          'countryCode': countryCode,
          'flowType': 'SMS',
          'mobileNumber': mobileNumber,
        },
        options: Options(headers: {'authToken': token}),
      );
    }

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 400) {
      // Handle REQUEST_ALREADY_EXISTS - return the existing verificationId
      final errorData = response.data;
      if (errorData['message'] == 'REQUEST_ALREADY_EXISTS' &&
          errorData['data'] != null &&
          errorData['data']['verificationId'] != null) {
        return {
          'message': 'REQUEST_ALREADY_EXISTS',
          'data': {
            'verificationId': errorData['data']['verificationId'],
            'mobileNumber': mobileNumber,
          }
        };
      }
    }

    throw Exception(response.data['message'] ?? 'Failed to send OTP');
  }
  Future<Map<String, dynamic>> validateOtp(
    String verificationId,
    String otp,
  ) async {
    try {
      final token = await generateAuthToken();
      final response = await _dio.get(
        '${ApiConstants.messageCentralBaseUrl}${ApiConstants.validateOtp}',
        queryParameters: {
          'verificationId': verificationId,
          'code': otp,
          'langId': 'en',
        },
        options: Options(headers: {'authToken': token}),
      );

      print('Validation Response Status: ${response.statusCode}');
      print('Validation Response Headers: ${response.headers}');
      print('Validation Response Data: ${response.data}');

      // Handle 401 - Token expired
      if (response.statusCode == 401) {
        print('Token expired, generating new token and retrying...');
        // Clear cached token and retry
        return await validateOtp(verificationId, otp);
      }

      if (response.statusCode == 200) {
        // Handle both string and map responses
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else if (response.data is String) {
          // Parse string response as JSON
          return jsonDecode(response.data);
        } else {
          throw Exception(
            'Unexpected response format: ${response.data.runtimeType}',
          );
        }
      }

      // Handle other error status codes
      final errorMessage = response.data is Map
          ? response.data['message']
          : response.data?.toString() ??
                'Validation failed (${response.statusCode})';

      throw Exception(errorMessage);
    } on DioException catch (e) {
      print('DioError in validateOtp: ${e.message}');
      print('DioError Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please try again.');
      }

      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in validateOtp: $e');
      throw Exception('OTP validation failed: ${e.toString()}');
    }
  }

  Future<Response> registerUser(dynamic data) async {
    return await post(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.registerAppUser,
      data: data,
    );
  }

  Future<Response> updateUser(dynamic data) async {
    return await put(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.registerAppUser,
      data: data,
    );
  }

  Future<Response> deleteUser(String id) async {
    return await delete(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.registerAppUser,
      queryParams: {'id': id},
    );
  }

  Future<List<Map<String, dynamic>>> fetchTimeSlots() async {
    final response = await get(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.bookingSlot,
      queryParams: {'id': 0},
    );
    return List<Map<String, dynamic>>.from(response.data['body']['data'] ?? []);
  }

  Future<Response> placeBooking(dynamic data) async {
    return await post(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.registerBookingRequests,
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> listBookings(
    Map<String, dynamic> queryParams,
  ) async {
    final response = await get(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.listBookingRequests,
      queryParams: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data['body']['data'] ?? []);
  }

  Future<Response> updateBookingStatus(dynamic data) async {
    return await post(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.bookingStatus,
      data: data,
    );
  }

  // Future<Response> updateBookingStatus(dynamic data) async {
  //   return await put(
  //     baseUrl: ApiConstants.standardOrgBaseUrl,
  //     endpoint: ApiConstants.bookingStatus,
  //     data: data,
  //   );
  // }
  Future<Response> fetchUserBookings(String id) async {
    return await get(
      baseUrl: ApiConstants.appUserBaseUrl,
      endpoint: ApiConstants.userBookings,
      queryParams: {'id': id},
    );
  }

  Future<List<Map<String, dynamic>>> fetchTests(String orgId) async {
    final response = await get(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.listOrgLabPartners,
      queryParams: {'labpartner_id': '', 'org_id': orgId, 'mode': 'Self'},
    );
    return List<Map<String, dynamic>>.from(response.data['body'] ?? []);
  }

  // Google Places Autocomplete
  Future<List<Map<String, dynamic>>> getPlacePredictions(
    String input,
    String apiKey, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await get(
        baseUrl: ApiConstants.googleMapsBaseUrl,
        endpoint: 'place/autocomplete/json',
        queryParams: {
          'input': input,
          'key': apiKey,
          'components': 'country:in', // Restrict to India
          'language': 'en',
        },
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map<Map<String, dynamic>>((prediction) {
            return {
              'description': prediction['description'],
              'place_id': prediction['place_id'],
              'structured_formatting': prediction['structured_formatting'],
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching place predictions: $e');
      return [];
    }
  }

  // Get Place Details
  Future<Map<String, dynamic>?> getPlaceDetails(
    String placeId,
    String apiKey, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await get(
        baseUrl: ApiConstants.googleMapsBaseUrl,
        endpoint: 'place/details/json',
        queryParams: {
          'place_id': placeId,
          'key': apiKey,
          'fields': 'formatted_address,geometry,name,address_components',
          'language': 'en',
        },
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }
  // this method for prescription upload
  Future<Response> uploadPrescription({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    return await post(
      baseUrl: ApiConstants.standardOrgBaseUrl,
      endpoint: ApiConstants.registerBookingRequests,
      data: data,
      cancelToken: cancelToken,
    );
  }
}
