// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../services/NotificationService/notification_service.dart';
//
// class UserModel with ChangeNotifier {
//   Map<String, dynamic>? _currentUser;
//   bool _isLoggedIn = false;
//   final Dio _dio = Dio();
//   String? _authToken;
//   double? _pointBalance;
//   int? _age;
//   String? _parentChildRelation;
//   bool? _isParent;
//   String? _linkingId;
//   List<dynamic> _children = [];
//
//   List<Map<String, dynamic>> _notifications = [];
//   List<Map<String, dynamic>> _walletHistory = [];
//   int _newNotificationCount = 0;
//
//   double? get pointBalance => _pointBalance;
//
//   Future<void> fetchPointBalance(String userId) async {
//     try {
//       final response = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/standardOrganization/mobile-list-standard-organizations',
//         queryParameters: {'user_id': userId},
//       );
//
//       if (response.statusCode == 200) {
//         final body = response.data['body'];
//         if (body != null && body['data'] != null) {
//           final List<dynamic> data = body['data'];
//
//           for (var org in data) {
//             if (org['pointBalance'] != null) {
//               _pointBalance = org['pointBalance'].toDouble();
//               notifyListeners();
//               return;
//             }
//           }
//
//           _pointBalance = 0.0;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       print('Error fetching point balance: $e');
//       _pointBalance = null;
//       notifyListeners();
//     }
//   }
//
//   static const String _messageCentralBaseUrl =
//       'https://cpaas.messagecentral.com';
//   static const String _sendOtpEndpoint = '/verification/v3/send';
//   static const String _validateOtpEndpoint = '/verification/v3/validateOtp';
//   static const String _otpAuthEndpoint =
//       'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/auth-tokens-for-otp';
//
//   bool get isLoggedIn => _isLoggedIn;
//
//   Map<String, dynamic>? get currentUser => _currentUser;
//
//   List<Map<String, dynamic>> get notifications => _notifications;
//
//   List<Map<String, dynamic>> get walletHistory => _walletHistory;
//
//   int get newNotificationCount => _newNotificationCount;
//
//   int? get age => _age;
//
//   String? get parentChildRelation => _parentChildRelation;
//
//   bool? get isParent => _isParent;
//
//   String? get linkingId => _linkingId;
//
//   List<dynamic> get children => _children;
//
//   // UserModel() {
//   //   _dio.options.baseUrl =
//   //   'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user';
//   //   _dio.options.connectTimeout = const Duration(seconds: 30);
//   //   _dio.options.receiveTimeout = const Duration(seconds: 30);
//   //
//   //   _dio.interceptors.add(
//   //     InterceptorsWrapper(
//   //       onRequest: (options, handler) {
//   //         print('Sending request to ${options.uri}');
//   //         print('Request data: ${options.data}');
//   //         return handler.next(options);
//   //       },
//   //       onResponse: (response, handler) {
//   //         print('Received response: ${response.data}');
//   //         return handler.next(response);
//   //       },
//   //       onError: (DioException e, handler) {
//   //         print('Error occurred: ${e.message}');
//   //         print('Error response: ${e.response?.data}');
//   //         return handler.next(e);
//   //       },
//   //     ),
//   //   );
//   //
//   //   _initialize();
//   // }
//   UserModel() {
//     _dio.options.baseUrl =
//     'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user';
//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);
//
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           print('Sending request to ${options.uri}');
//           print('Request data: ${options.data}');
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           print('Received response: ${response.data}');
//           return handler.next(response);
//         },
//         onError: (DioException e, handler) {
//           print('Error occurred: ${e.message}');
//           print('Error response: ${e.response?.data}');
//           return handler.next(e);
//         },
//       ),
//     );
//   }
//   // Future<void> _initialize() async {
//   //   await _loadNotifications();
//   //   await _loadWalletHistory();
//   //   await _loadNewNotificationCount();
//   //   await checkLoginStatus();
//   // }
//   Future<void> initialize() async {
//     await _loadNotifications();
//     await _loadWalletHistory();
//     await _loadNewNotificationCount();
//     await checkLoginStatus();
//   }
//   Future<void> _loadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? notificationsJson = prefs.getString('notifications');
//     if (notificationsJson != null) {
//       final List<dynamic> decoded = jsonDecode(notificationsJson);
//       _notifications = decoded.cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }
//
//   Future<void> _saveNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String notificationsJson = jsonEncode(_notifications);
//     await prefs.setString('notifications', notificationsJson);
//   }
//
//   void addNotification(String title, String message) {
//     _notifications.insert(0, {
//       'title': title,
//       'message': message,
//       'timestamp': DateTime.now().toIso8601String(),
//       'type': 'notification',
//       'isNew': true,
//     });
//     _newNotificationCount++;
//     _saveNotifications();
//     _saveNewNotificationCount();
//     notifyListeners();
//   }
//
//   void markAllAsRead() {
//     for (var notification in _notifications) {
//       notification['isNew'] = false;
//     }
//     _newNotificationCount = 0;
//     _saveNotifications();
//     _saveNewNotificationCount();
//     notifyListeners();
//   }
//
//   void clearNotifications() {
//     _notifications.clear();
//     _newNotificationCount = 0;
//     _saveNotifications();
//     _saveNewNotificationCount();
//     notifyListeners();
//   }
//
//   Future<void> _loadWalletHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? walletHistoryJson = prefs.getString('walletHistory');
//     if (walletHistoryJson != null) {
//       final List<dynamic> decoded = jsonDecode(walletHistoryJson);
//       _walletHistory = decoded.cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }
//
//   Future<void> _saveWalletHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String walletHistoryJson = jsonEncode(_walletHistory);
//     await prefs.setString('walletHistory', walletHistoryJson);
//   }
//
//   void addToWalletHistory(String title, String amount, String description) {
//     _walletHistory.insert(0, {
//       'title': title,
//       'amount': amount,
//       'description': description,
//       'timestamp': DateTime.now().toIso8601String(),
//       'type': 'wallet',
//     });
//     _saveWalletHistory();
//     notifyListeners();
//   }
//
//   Future<void> _loadNewNotificationCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     _newNotificationCount = prefs.getInt('newNotificationCount') ?? 0;
//     notifyListeners();
//   }
//
//   Future<void> _saveNewNotificationCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('newNotificationCount', _newNotificationCount);
//   }
//
//   Future<void> checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     if (_isLoggedIn) {
//       final phone = prefs.getString('phoneNumber');
//       if (phone != null) {
//         print('Checking login status, phone: $phone');
//         await getUserByPhone(phone);
//       } else {
//         print('No phone number found in SharedPreferences during login check');
//       }
//     } else {
//       print('User is not logged in');
//     }
//     notifyListeners();
//   }
//
//   Future<bool> checkUserExists(String phoneNumber) async {
//     try {
//       final response = await _dio.post(
//         '/list-app-user',
//         data: {"contactNumber": phoneNumber},
//       );
//       print('checkUserExists response: ${response.data}');
//
//       if (response.data != null &&
//           response.data is Map &&
//           response.data.containsKey('body') &&
//           response.data['body'] is Map &&
//           response.data['body']['appUserId'] != null) {
//         return true;
//       }
//       return false;
//     } on DioException catch (e) {
//       print('DioError checking user: ${e.response?.data}');
//       return false;
//     } catch (e) {
//       print('Error checking user: $e');
//       return false;
//     }
//   }
//
//   Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
//     try {
//       final response = await _dio.post(
//         '/list-app-user',
//         data: {"contactNumber": phoneNumber},
//       );
//       print('getUserByPhone response: ${response.data}');
//
//       if (response.data != null &&
//           response.data is Map &&
//           response.data.containsKey('body') &&
//           response.data['body'] is Map &&
//           response.data['body']['appUserId'] != null) {
//         _currentUser = Map<String, dynamic>.from(response.data['body']);
//         _age = _currentUser?['age'];
//         _parentChildRelation =
//             _currentUser?['parent_child_relation']?.toString();
//         final isParentValue = _currentUser?['is_parent'];
//         _isParent =
//         isParentValue is bool
//             ? isParentValue
//             : isParentValue is int
//             ? isParentValue == 1
//             : false;
//         _linkingId = _currentUser?['linkingId']?.toString();
//         _children =
//             (_currentUser?['children'] as List<dynamic>?)?.map((child) {
//               if (child is Map<String, dynamic>) {
//                 final childIsParent = child['is_parent'];
//                 return {
//                   ...child,
//                   'is_parent':
//                   childIsParent is bool
//                       ? childIsParent
//                       : childIsParent is int
//                       ? childIsParent == 1
//                       : false,
//                   'parent_child_relation':
//                   child['parent_child_relation']?.toString() ?? '',
//                 };
//               }
//               return child;
//             }).toList() ??
//                 [];
//         if (_children.isEmpty) {
//           print('Warning: Children list is empty in response');
//         } else {
//           print('Children fetched: $_children');
//         }
//         notifyListeners();
//         return _currentUser;
//       }
//       print('No valid user data found in response');
//       return null;
//     } on DioException catch (e) {
//       print('DioError getting user: ${e.response?.data}');
//       return null;
//     } catch (e) {
//       print('Error getting user: $e');
//       _children = [];
//       notifyListeners();
//       return null;
//     }
//   }
//
//   Future<void> login(String phoneNumber) async {
//     final user = await getUserByPhone(phoneNumber);
//     if (user != null) {
//       _isLoggedIn = true;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
//       await prefs.setString('phoneNumber', phoneNumber);
//       // if (_pointBalance != null) {
//       //   final notificationService = NotificationService();
//       //   await notificationService.showWelcomeNotification(_pointBalance!);
//       // }
//       print('User logged in with phone: $phoneNumber');
//       notifyListeners();
//     } else {
//       print('Login failed: No user found for phone $phoneNumber');
//     }
//   }
//
//   Future<void> logout() async {
//     _isLoggedIn = false;
//     _currentUser = null;
//     _authToken = null;
//     _children = [];
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('isLoggedIn');
//     await prefs.remove('phoneNumber');
//     print('User logged out');
//     notifyListeners();
//   }
//
//   // Future<void> registerUser({
//   //   required String firstName,
//   //   required String lastName,
//   //   required String phoneNumber,
//   //   required String email,
//   //   required String address,
//   //   required String gender,
//   //   required int? age,
//   //   String? parentChildRelation,
//   //   bool? isParent,
//   //   String? linkingId,
//   //   String? referralCode,
//   // }) async {
//   //   try {
//   //     final data = {
//   //       "firstName": firstName,
//   //       "lastName": lastName,
//   //       "emailId": email,
//   //       "address": address,
//   //       "gender": gender,
//   //       "age": age,
//   //       if (parentChildRelation != null)
//   //         "parent_child_relation": parentChildRelation,
//   //       if (isParent != null) "is_parent": isParent ? 1 : 0,
//   //       if (linkingId != null) "linking_id": linkingId,
//   //       if (referralCode != null) "referralCode": referralCode,
//   //     };
//   //
//   //     if (phoneNumber.isNotEmpty) {
//   //       data["contactNumber"] = phoneNumber;
//   //     }
//   //
//   //     final response = await _dio.post('/register-app-user', data: data);
//   //     print('registerUser response: ${response.data}');
//   //
//   //     if (response.data != null) {
//   //       _currentUser = {
//   //         'firstName': firstName,
//   //         'lastName': lastName,
//   //         'contactNumber': phoneNumber.isNotEmpty ? phoneNumber : null,
//   //         'emailId': email,
//   //         'address': address,
//   //         'gender': gender,
//   //         'age': age,
//   //         'parent_child_relation': parentChildRelation,
//   //         'is_parent': isParent,
//   //         'linking_id': linkingId,
//   //         'referralCode': referralCode,
//   //         'children': [],
//   //       };
//   //       await login(phoneNumber.isNotEmpty ? phoneNumber : (linkingId ?? ''));
//   //     }
//   //   } catch (e) {
//   //     print('Error registering user: $e');
//   //     rethrow;
//   //   }
//   // }
//   Future<void> registerUser({
//     required String firstName,
//     required String lastName,
//     required String phoneNumber,
//     required String email,
//     required String address,
//     required String gender,
//     required int? age,
//     String? parentChildRelation,
//     bool? isParent,
//     String? linkingId,
//     String? referralCode,
//   }) async {
//     try {
//       final data = {
//         "firstName": firstName,
//         "lastName": lastName,
//         "emailId": email,
//         "address": address,
//         "gender": gender,
//         "age": age,
//         if (parentChildRelation != null)
//           "parent_child_relation": parentChildRelation,
//         if (isParent != null) "is_parent": isParent ? 1 : 0,
//         if (linkingId != null) "linking_id": linkingId,
//         if (referralCode != null) "referralCode": referralCode,
//       };
//
//       if (phoneNumber.isNotEmpty) {
//         data["contactNumber"] = phoneNumber;
//       }
//
//       final response = await _dio.post('/register-app-user', data: data);
//       print('registerUser response: ${response.data}');
//
//       // ERROR CHECKING
//       if (response.data != null) {
//         // Check if the response indicates success
//         if (response.data['statusCode'] == 400 ||
//             response.data['body']?['status'] == 'failed') {
//           throw Exception(response.data['body']?['message'] ?? 'Registration failed');
//         }
//
//         // Only proceed if registration was successful
//         _currentUser = {
//           'firstName': firstName,
//           'lastName': lastName,
//           'contactNumber': phoneNumber.isNotEmpty ? phoneNumber : null,
//           'emailId': email,
//           'address': address,
//           'gender': gender,
//           'age': age,
//           'parent_child_relation': parentChildRelation,
//           'is_parent': isParent,
//           'linking_id': linkingId,
//           'referralCode': referralCode,
//           'children': [],
//         };
//
//         // Only login if registration was truly successful
//         if (phoneNumber.isNotEmpty) {
//           await login(phoneNumber);
//         } else if (linkingId != null) {
//           await login(linkingId);
//         }
//       } else {
//         throw Exception('Empty response from server');
//       }
//     } catch (e) {
//       print('Error registering user: $e');
//       rethrow;
//     }
//   }
//   Future<void> updateUser({
//     required String firstName,
//     required String lastName,
//     required String phoneNumber,
//     required String email,
//     required String address,
//     required String gender,
//     required int? age,
//     String? parentChildRelation,
//     bool? isParent,
//     String? linkingId,
//   }) async {
//     try {
//       final user = await getUserByPhone(phoneNumber);
//       if (user == null || user['appUserId'] == null) {
//         throw Exception('User not found');
//       }
//
//       final data = {
//         "appUserId": user['appUserId'],
//         "firstName": firstName,
//         "lastName": lastName,
//         "address": address,
//         "age": age,
//         "gender": gender,
//         if (parentChildRelation != null)
//           "parent_child_relation": parentChildRelation,
//         if (isParent != null) "is_parent": isParent ? 1 : 0,
//         if (linkingId != null) "linking_id": linkingId,
//       };
//
//       if (phoneNumber.isNotEmpty) {
//         data["contactNumber"] = phoneNumber;
//       }
//
//       final response = await _dio.put('/register-app-user', data: data);
//       print('updateUser response: ${response.data}');
//
//       if (response.data != null) {
//         _currentUser = {
//           ..._currentUser!,
//           'firstName': firstName,
//           'lastName': lastName,
//           'contactNumber':
//           phoneNumber.isNotEmpty
//               ? phoneNumber
//               : _currentUser!['contactNumber'],
//           'emailId': email,
//           'address': address,
//           'gender': gender,
//           'age': age,
//           'parent_child_relation': parentChildRelation,
//           'is_parent': isParent,
//           'linking_id': linkingId,
//         };
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error updating user: $e');
//       rethrow;
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getRelations() async {
//     try {
//       final response = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/relation/list-relations',
//       );
//       print('Relations API response: ${response.data}');
//       if (response.data != null &&
//           response.data['body'] != null &&
//           response.data['body']['data'] != null) {
//         final List<dynamic> data = response.data['body']['data'];
//         return data
//             .map(
//               (item) => {
//             'id': item['id'].toString(),
//             'relationName': item['relationName'],
//           },
//         )
//             .toList();
//       }
//       print('No data found in relations response');
//       return [];
//     } catch (e) {
//       print('Error fetching relations: $e');
//       rethrow;
//     }
//   }
//
//   Future<String> _getValidToken() async {
//     if (_authToken == null) {
//       await _generateAuthToken();
//     }
//     return _authToken!;
//   }
//
//   Future<void> _generateAuthToken() async {
//     try {
//       final response = await _dio.get(
//         _otpAuthEndpoint,
//         options: Options(headers: {'accept': '*/*'}),
//       );
//
//       if (response.statusCode == 200 && response.data != null) {
//         final responseBody = response.data['body'];
//         if (responseBody != null && responseBody['success'] == true) {
//           _authToken = responseBody['token'];
//           print('Generated new auth token: ${_authToken?.substring(0, 20)}...');
//         } else {
//           throw Exception(
//             'Failed to generate token: Invalid response structure',
//           );
//         }
//       } else {
//         throw Exception('Failed to generate token: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error generating auth token: $e');
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> sendOtp(
//       String countryCode,
//       String mobileNumber,
//       ) async {
//     try {
//       await _getValidToken();
//
//       final response = await _dio.post(
//         '$_messageCentralBaseUrl$_sendOtpEndpoint',
//         queryParameters: {
//           'countryCode': countryCode,
//           'flowType': 'SMS',
//           'mobileNumber': mobileNumber,
//         },
//         options: Options(
//           headers: {'authToken': _authToken},
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       if (response.statusCode == 401) {
//         await _generateAuthToken();
//         return sendOtp(countryCode, mobileNumber);
//       }
//
//       if (response.statusCode == 200) {
//         return response.data;
//       }
//
//       throw Exception(response.data['message'] ?? 'Failed to send OTP');
//     } catch (e) {
//       print('Error sending OTP: $e');
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> validateOtp(
//       String verificationId,
//       String otp,
//       ) async {
//     try {
//       await _generateAuthToken();
//       final token = _authToken!;
//
//       print('Validating with NEW token: ${token.substring(0, 20)}...');
//
//       final response = await _dio.get(
//         '$_messageCentralBaseUrl$_validateOtpEndpoint',
//         queryParameters: {
//           'verificationId': verificationId,
//           'code': otp,
//           'langId': 'en',
//         },
//         options: Options(
//           headers: {'authToken': token, 'Content-Type': 'application/json'},
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       print('Validation Response Status: ${response.statusCode}');
//       print('Response Body: ${response.data}');
//
//       if (response.statusCode == 200) {
//         return response.data;
//       }
//
//       throw Exception(
//         response.data?['message'] ??
//             'Validation failed (${response.statusCode})',
//       );
//     } on DioException catch (e) {
//       print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
//       throw Exception('Server error: ${e.message}');
//     } catch (e) {
//       print('Validation Error: $e');
//       throw Exception('OTP validation failed');
//     }
//   }
//
//   Map<String, dynamic>? getPatientById(String patientId) {
//     print('Fetching patient for ID: $patientId');
//     print(
//       'Current user: ${_currentUser?['appUserId']} ${_currentUser?['firstName']}',
//     );
//     print('Children: $_children');
//
//     if (_currentUser != null &&
//         _currentUser!['appUserId'].toString() == patientId) {
//       print(
//         'Returning primary user: ${_currentUser!['firstName']} ${_currentUser!['lastName']}',
//       );
//       return _currentUser;
//     }
//     final children = _children ?? [];
//     for (var child in children) {
//       if (child['appUserId'].toString() == patientId) {
//         print('Returning child: ${child['firstName']} ${child['lastName']}');
//         return {
//           ...child,
//           'is_parent': child['is_parent'] == 1 || child['is_parent'] == true,
//         };
//       }
//     }
//     print('No patient found for ID: $patientId');
//     return null;
//   }
// }
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/NotificationService/notification_service.dart';

class UserModel with ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  bool _isLoggedIn = false;
  final Dio _dio = Dio();
  String? _authToken;
  double? _pointBalance;
  int? _age;
  String? _parentChildRelation;
  bool? _isParent;
  String? _linkingId;
  List<dynamic> _children = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _walletHistory = [];
  int _newNotificationCount = 0;

  double? get pointBalance => _pointBalance;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get walletHistory => _walletHistory;
  int get newNotificationCount => _newNotificationCount;
  int? get age => _age;
  String? get parentChildRelation => _parentChildRelation;
  bool? get isParent => _isParent;
  String? get linkingId => _linkingId;
  List<dynamic> get children => _children;

  UserModel() {
    _dio.options.baseUrl = 'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Sending request to ${options.uri}');
          print('Request data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error occurred: ${e.message}');
          print('Error response: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> initialize() async {
    print('Initializing UserModel...');
    await _loadNotifications();
    await _loadWalletHistory();
    await _loadNewNotificationCount();
    await checkLoginStatus();
    print('UserModel initialized: isLoggedIn=$_isLoggedIn, currentUser=$_currentUser');
  }

  Future<void> fetchPointBalance(String userId) async {
    try {
      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/standardOrganization/mobile-list-standard-organizations',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final body = response.data['body'];
        if (body != null && body['data'] != null) {
          final List<dynamic> data = body['data'];
          for (var org in data) {
            if (org['pointBalance'] != null) {
              _pointBalance = org['pointBalance'].toDouble();
              notifyListeners();
              return;
            }
          }
          _pointBalance = 0.0;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching point balance: $e');
      _pointBalance = null;
      notifyListeners();
    }
  }

  static const String _messageCentralBaseUrl = 'https://cpaas.messagecentral.com';
  static const String _sendOtpEndpoint = '/verification/v3/send';
  static const String _validateOtpEndpoint = '/verification/v3/validateOtp';
  static const String _otpAuthEndpoint = 'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/auth-tokens-for-otp';

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      _notifications = decoded.cast<Map<String, dynamic>>();
    }
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String notificationsJson = jsonEncode(_notifications);
    await prefs.setString('notifications', notificationsJson);
  }

  void addNotification(String title, String message) {
    _notifications.insert(0, {
      'title': title,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'notification',
      'isNew': true,
    });
    _newNotificationCount++;
    _saveNotifications();
    _saveNewNotificationCount();
    notifyListeners();
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isNew'] = false;
    }
    _newNotificationCount = 0;
    _saveNotifications();
    _saveNewNotificationCount();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _newNotificationCount = 0;
    _saveNotifications();
    _saveNewNotificationCount();
    notifyListeners();
  }

  Future<void> _loadWalletHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? walletHistoryJson = prefs.getString('walletHistory');
    if (walletHistoryJson != null) {
      final List<dynamic> decoded = jsonDecode(walletHistoryJson);
      _walletHistory = decoded.cast<Map<String, dynamic>>();
    }
    notifyListeners();
  }

  Future<void> _saveWalletHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String walletHistoryJson = jsonEncode(_walletHistory);
    await prefs.setString('walletHistory', walletHistoryJson);
  }

  void addToWalletHistory(String title, String amount, String description) {
    _walletHistory.insert(0, {
      'title': title,
      'amount': amount,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'wallet',
    });
    _saveWalletHistory();
    notifyListeners();
  }

  Future<void> _loadNewNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    _newNotificationCount = prefs.getInt('newNotificationCount') ?? 0;
    notifyListeners();
  }

  Future<void> _saveNewNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('newNotificationCount', _newNotificationCount);
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('checkLoginStatus: isLoggedIn=$_isLoggedIn');

    if (_isLoggedIn) {
      final phone = prefs.getString('phoneNumber');
      if (phone != null) {
        print('Checking login status, phone: $phone');
        try {
          final user = await getUserByPhone(phone);
          if (user == null) {
            print('No user found for phone $phone, resetting login state');
            _isLoggedIn = false;
            await prefs.setBool('isLoggedIn', false);
            await prefs.remove('phoneNumber');
          }
        } catch (e) {
          print('Error fetching user during login check: $e');
          _isLoggedIn = false;
          await prefs.setBool('isLoggedIn', false);
          await prefs.remove('phoneNumber');
        }
      } else {
        print('No phone number found in SharedPreferences during login check');
        _isLoggedIn = false;
        await prefs.setBool('isLoggedIn', false);
      }
    } else {
      print('User is not logged in');
    }
    notifyListeners();
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/list-app-user',
        data: {"contactNumber": phoneNumber},
      );
      print('checkUserExists response: ${response.data}');

      if (response.data != null &&
          response.data is Map &&
          response.data.containsKey('body') &&
          response.data['body'] is Map &&
          response.data['body']['appUserId'] != null) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('DioError checking user: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/list-app-user',
        data: {"contactNumber": phoneNumber},
      );
      print('getUserByPhone response: ${response.data}');

      if (response.data != null &&
          response.data is Map &&
          response.data.containsKey('body') &&
          response.data['body'] is Map &&
          response.data['body']['appUserId'] != null) {
        _currentUser = Map<String, dynamic>.from(response.data['body']);
        _age = _currentUser?['age'];
        _parentChildRelation = _currentUser?['parent_child_relation']?.toString();
        final isParentValue = _currentUser?['is_parent'];
        _isParent = isParentValue is bool
            ? isParentValue
            : isParentValue is int
            ? isParentValue == 1
            : false;
        _linkingId = _currentUser?['linkingId']?.toString();
        _children = (_currentUser?['children'] as List<dynamic>?)?.map((child) {
          if (child is Map<String, dynamic>) {
            final childIsParent = child['is_parent'];
            return {
              ...child,
              'is_parent': childIsParent is bool
                  ? childIsParent
                  : childIsParent is int
                  ? childIsParent == 1
                  : false,
              'parent_child_relation': child['parent_child_relation']?.toString() ?? '',
            };
          }
          return child;
        }).toList() ?? [];
        if (_children.isEmpty) {
          print('Warning: Children list is empty in response');
        } else {
          print('Children fetched: $_children');
        }
        notifyListeners();
        return _currentUser;
      }
      print('No valid user data found in response');
      return null;
    } on DioException catch (e) {
      print('DioError getting user: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Error getting user: $e');
      _children = [];
      notifyListeners();
      return null;
    }
  }

  Future<void> login(String phoneNumber) async {
    final user = await getUserByPhone(phoneNumber);
    if (user != null) {
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('phoneNumber', phoneNumber);
      print('User logged in with phone: $phoneNumber, isLoggedIn: $_isLoggedIn');
      // Optional: Show welcome notification
      // if (_pointBalance != null) {
      //   final notificationService = NotificationService();
      //   await notificationService.showWelcomeNotification(_pointBalance!);
      // }
      notifyListeners();
    } else {
      print('Login failed: No user found for phone $phoneNumber');
      throw Exception('Login failed: User not found');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _children = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('phoneNumber');
    print('User logged out, isLoggedIn: $_isLoggedIn');
    notifyListeners();
  }

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String address,
    required String gender,
    required int? age,
    String? parentChildRelation,
    bool? isParent,
    String? linkingId,
    String? referralCode,
  }) async {
    try {
      final data = {
        "firstName": firstName,
        "lastName": lastName,
        "emailId": email,
        "address": address,
        "gender": gender,
        "age": age,
        if (parentChildRelation != null) "parent_child_relation": parentChildRelation,
        if (isParent != null) "is_parent": isParent ? 1 : 0,
        if (linkingId != null) "linking_id": linkingId,
        if (referralCode != null) "referralCode": referralCode,
      };

      if (phoneNumber.isNotEmpty) {
        data["contactNumber"] = phoneNumber;
      }

      final response = await _dio.post('/register-app-user', data: data);
      print('registerUser response: ${response.data}');

      if (response.data != null) {
        if (response.data['statusCode'] == 400 || response.data['body']?['status'] == 'failed') {
          throw Exception(response.data['body']?['message'] ?? 'Registration failed');
        }

        _currentUser = {
          'firstName': firstName,
          'lastName': lastName,
          'contactNumber': phoneNumber.isNotEmpty ? phoneNumber : null,
          'emailId': email,
          'address': address,
          'gender': gender,
          'age': age,
          'parent_child_relation': parentChildRelation,
          'is_parent': isParent,
          'linking_id': linkingId,
          'referralCode': referralCode,
          'children': [],
        };

        if (phoneNumber.isNotEmpty) {
          await login(phoneNumber);
        } else if (linkingId != null) {
          await login(linkingId);
        }
      } else {
        throw Exception('Empty response from server');
      }
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String address,
    required String gender,
    required int? age,
    String? parentChildRelation,
    bool? isParent,
    String? linkingId,
  }) async {
    try {
      final user = await getUserByPhone(phoneNumber);
      if (user == null || user['appUserId'] == null) {
        throw Exception('User not found');
      }

      final data = {
        "appUserId": user['appUserId'],
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "age": age,
        "gender": gender,
        if (parentChildRelation != null) "parent_child_relation": parentChildRelation,
        if (isParent != null) "is_parent": isParent ? 1 : 0,
        if (linkingId != null) "linking_id": linkingId,
      };

      if (phoneNumber.isNotEmpty) {
        data["contactNumber"] = phoneNumber;
      }

      final response = await _dio.put('/register-app-user', data: data);
      print('updateUser response: ${response.data}');

      if (response.data != null) {
        _currentUser = {
          ..._currentUser!,
          'firstName': firstName,
          'lastName': lastName,
          'contactNumber': phoneNumber.isNotEmpty ? phoneNumber : _currentUser!['contactNumber'],
          'emailId': email,
          'address': address,
          'gender': gender,
          'age': age,
          'parent_child_relation': parentChildRelation,
          'is_parent': isParent,
          'linking_id': linkingId,
        };
        notifyListeners();
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRelations() async {
    try {
      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/relation/list-relations',
      );
      print('Relations API response: ${response.data}');
      if (response.data != null && response.data['body'] != null && response.data['body']['data'] != null) {
        final List<dynamic> data = response.data['body']['data'];
        return data.map((item) => {
          'id': item['id'].toString(),
          'relationName': item['relationName'],
        }).toList();
      }
      print('No data found in relations response');
      return [];
    } catch (e) {
      print('Error fetching relations: $e');
      rethrow;
    }
  }

  Future<String> _getValidToken() async {
    if (_authToken == null) {
      await _generateAuthToken();
    }
    return _authToken!;
  }

  Future<void> _generateAuthToken() async {
    try {
      final response = await _dio.get(
        _otpAuthEndpoint,
        options: Options(headers: {'accept': '*/*'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseBody = response.data['body'];
        if (responseBody != null && responseBody['success'] == true) {
          _authToken = responseBody['token'];
          print('Generated new auth token: ${_authToken?.substring(0, 20)}...');
        } else {
          throw Exception('Failed to generate token: Invalid response structure');
        }
      } else {
        throw Exception('Failed to generate token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating auth token: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendOtp(String countryCode, String mobileNumber) async {
    try {
      await _getValidToken();
      final response = await _dio.post(
        '$_messageCentralBaseUrl$_sendOtpEndpoint',
        queryParameters: {
          'countryCode': countryCode,
          'flowType': 'SMS',
          'mobileNumber': mobileNumber,
        },
        options: Options(
          headers: {'authToken': _authToken},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 401) {
        await _generateAuthToken();
        return sendOtp(countryCode, mobileNumber);
      }

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception(response.data['message'] ?? 'Failed to send OTP');
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateOtp(String verificationId, String otp) async {
    try {
      await _generateAuthToken();
      final token = _authToken!;
      print('Validating with NEW token: ${token.substring(0, 20)}...');

      final response = await _dio.get(
        '$_messageCentralBaseUrl$_validateOtpEndpoint',
        queryParameters: {
          'verificationId': verificationId,
          'code': otp,
          'langId': 'en',
        },
        options: Options(
          headers: {'authToken': token, 'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Validation Response Status: ${response.statusCode}');
      print('Response Body: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception(response.data?['message'] ?? 'Validation failed (${response.statusCode})');
    } on DioException catch (e) {
      print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Server error: ${e.message}');
    } catch (e) {
      print('Validation Error: $e');
      throw Exception('OTP validation failed');
    }
  }

  Map<String, dynamic>? getPatientById(String patientId) {
    print('Fetching patient for ID: $patientId');
    print('Current user: ${_currentUser?['appUserId']} ${_currentUser?['firstName']}');
    print('Children: $_children');

    if (_currentUser != null && _currentUser!['appUserId'].toString() == patientId) {
      print('Returning primary user: ${_currentUser!['firstName']} ${_currentUser!['lastName']}');
      return _currentUser;
    }
    final children = _children ?? [];
    for (var child in children) {
      if (child['appUserId'].toString() == patientId) {
        print('Returning child: ${child['firstName']} ${child['lastName']}');
        return {
          ...child,
          'is_parent': child['is_parent'] == 1 || child['is_parent'] == true,
        };
      }
    }
    print('No patient found for ID: $patientId');
    return null;
  }
}