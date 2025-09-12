// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/UserModel/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// class CartModel extends ChangeNotifier {
//   final List<Map<String, dynamic>> _items = [];
//   final Dio _dio = Dio();
//   CancelToken? _cancelToken;
//   final UserModel userModel;
//   final logger = Logger();
//   int? _currentOrganizationId;
//   List<Map<String, dynamic>> get items => _items;
//   double _homeCollectionCharge = 200.0;
//   bool _requiresHomeCollection = false;
//   List<Map<String, dynamic>> orderHistory = [];
//
//   int get itemCount => _items.length;
//
//   double get homeCollectionCharge => _homeCollectionCharge;
//
//   bool get requiresHomeCollection => _requiresHomeCollection;
//   String? _selectedAddress;
//   String? _selectedTimeSlot;
//   String? _selectedBookingDate;
//   List<Map<String, dynamic>> _timeSlots = [];
//   bool _isLoadingTimeSlots = false;
//
//   String? get selectedAddress => _selectedAddress;
//
//   String? get selectedTimeSlot => _selectedTimeSlot;
//
//   String? get selectedBookingDate => _selectedBookingDate;
//
//   List<Map<String, dynamic>> get timeSlots => _timeSlots;
//
//   bool get isLoadingTimeSlots => _isLoadingTimeSlots;
//
//   void setCurrentOrganizationId(int orgId) {
//     _currentOrganizationId = orgId;
//
//     // Delay the notification until after the current build frame
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }
//   int? get currentOrganizationId => _currentOrganizationId;
//   CartModel({required this.userModel}) {
//     print('CartModel initialized');
//     _cancelToken = CancelToken();
//     loadOrderHistory();
//   }
//
//   Future<void> loadOrderHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final orderHistoryJson = prefs.getString('orderHistory');
//       if (orderHistoryJson != null) {
//         final List<dynamic> decoded = json.decode(orderHistoryJson);
//         orderHistory =
//             decoded.map<Map<String, dynamic>>((item) {
//               return {
//                 ...item,
//                 'date': DateTime.parse(item['date']),
//                 'items': List<Map<String, dynamic>>.from(item['items']),
//               };
//             }).toList();
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error loading order history: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     print('CartModel disposed');
//     _cancelToken?.cancel();
//     _dio.close();
//     super.dispose();
//   }
//
//   Future<void> _saveOrderHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final orderHistoryJson = json.encode(
//         orderHistory.map((order) {
//           return {
//             ...order,
//             'date': order['date'].toString(),
//             'items': order['items'],
//           };
//         }).toList(),
//       );
//       await prefs.setString('orderHistory', orderHistoryJson);
//     } catch (e) {
//       print('Error saving order history: $e');
//     }
//   }
//
//   void setHomeCollectionCharge(double charge) {
//     print('Setting homeCollectionCharge to $charge');
//     _homeCollectionCharge = charge;
//     notifyListeners();
//   }
//
//   void setRequiresHomeCollection(bool value) {
//     print('Setting requiresHomeCollection to $value');
//     _requiresHomeCollection = value;
//     notifyListeners();
//   }
//
//   double get totalPrice {
//     final subtotal = _items.fold(0.0, (sum, item) {
//       final price = item['discountPrice'] as double;
//       final quantity = item['quantity'] as int;
//       return sum + (price * quantity);
//     });
//     final total =
//     _requiresHomeCollection ? subtotal + _homeCollectionCharge : subtotal;
//     print('Calculating total price: ₹$total');
//     return total;
//   }
//
//   double get walletAmount {
//     if (_items.isEmpty) return 0.0;
//     if (_items.first['isWalletEnabled'] != true) return 0.0;
//     final points = _items.first['pointBalance']?.toString() ?? '0';
//     return double.tryParse(points) ?? 0.0;
//   }
//
//   double get walletDiscountPercentage {
//     if (_items.isEmpty) return 0.0;
//     if (_items.first['isWalletEnabled'] != true) return 0.0;
//     return _items.first['walletAmtPercentage']?.toDouble() ?? 0.0;
//   }
//
//   void addToCart(Map<String, dynamic> test, {int quantity = 1}) {
//     final itemId = '${test['provider']}_${test['name']}';
//     print('Adding to cart - Item: $itemId');
//
//     final patientCount = (test['selectedPatientIds'] as List?)?.length ?? 1;
//
//     final existingItemIndex = _items.indexWhere(
//           (item) => item['itemId'] == itemId,
//     );
//
//     if (existingItemIndex != -1) {
//       print('Item already in cart, updating patient selection');
//       _items[existingItemIndex]['selectedPatientIds'] =
//           test['selectedPatientIds'] ??
//               _items[existingItemIndex]['selectedPatientIds'];
//       _items[existingItemIndex]['quantity'] =
//           (_items[existingItemIndex]['selectedPatientIds'] as List).length;
//     } else {
//       print('Adding new item to cart');
//       _items.add({
//         ...test,
//         'itemId': itemId,
//         'quantity': patientCount,
//         'testId': test['testId'] ?? 0,
//         'pointBalance': test['pointBalance']?.toString() ?? '0',
//         'walletAmtPercentage': test['walletAmtPercentage']?.toDouble() ?? 0.0,
//         'selectedPatientIds': test['selectedPatientIds'] ?? [],
//         'organizationName': test['provider'] ?? 'Provider',
//       });
//     }
//     notifyListeners();
//     print(
//       'Cart updated. Current items: ${_items.length}, Quantity: $patientCount',
//     );
//   }
//
//   void removeFromCart(String itemId) {
//     print('Removing item from cart: $itemId');
//     _items.removeWhere((item) => item['itemId'] == itemId);
//     notifyListeners();
//     print('Item removed. Remaining items: ${_items.length}');
//   }
//
//   void clearCart() {
//     print('Clearing cart');
//     _items.clear();
//     _requiresHomeCollection = false;
//     notifyListeners();
//     print('Cart cleared');
//   }
//
//   void setSelectedAddress(String address) {
//     _selectedAddress = address;
//     notifyListeners();
//   }
//
//   void setSelectedTimeSlot(String timeSlot) {
//     _selectedTimeSlot = timeSlot;
//     notifyListeners();
//   }
//
//   void setSelectedBookingDate(String date) {
//     _selectedBookingDate = date;
//     notifyListeners();
//   }
//
//   Future<void> fetchTimeSlots() async {
//     _isLoadingTimeSlots = true;
//     notifyListeners();
//
//     try {
//       final response = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/booking-slot?id=0',
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data['body']['data'] as List;
//         _timeSlots = data.cast<Map<String, dynamic>>();
//       } else {
//         _timeSlots = [];
//       }
//     } catch (e) {
//       print('Error fetching time slots: $e');
//       _timeSlots = [];
//     } finally {
//       _isLoadingTimeSlots = false;
//       notifyListeners();
//     }
//   }
//
//   void clearHomeCollectionDetails() {
//     _selectedAddress = null;
//     _selectedTimeSlot = null;
//     _selectedBookingDate = null;
//     notifyListeners();
//   }
//
//   Future<Map<String, dynamic>> placeOrder(String paymentMode) async {
//     if (_currentOrganizationId == null) {
//       print('Order failed: No organization ID set');
//       return {'success': false, 'message': 'No organization selected'};
//     }
//
//     final orgId = _currentOrganizationId!;
//     print('Attempting to place order for organization: $orgId');
//     print('Attempting to place order with payment mode: $paymentMode');
//
//     if (items.isEmpty) {
//       print('Order failed: Cart is empty');
//       return {'success': false, 'message': 'Cart is empty'};
//     }
//
//     if (userModel.currentUser == null ||
//         userModel.currentUser!['appUserId'] == null) {
//       print('Order failed: User not logged in');
//       return {'success': false, 'message': 'Please log in to place an order'};
//     }
//
//     try {
//       final now = DateTime.now();
//       final dateFormatter = DateFormat('dd-MM-yyyy');
//       final dateTimeFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
//       // final bookingDate = dateFormatter.format(now);
//       String bookingDate;
//       if (_requiresHomeCollection && _selectedBookingDate != null) {
//         // Parse the selected date and format it consistently
//         try {
//           final selectedDate = DateFormat('yyyy-MM-dd').parse(_selectedBookingDate!);
//           bookingDate = dateFormatter.format(selectedDate);
//         } catch (e) {
//           // Fallback to current date if parsing fails
//           bookingDate = dateFormatter.format(now);
//         }
//       } else {
//         bookingDate = dateFormatter.format(now);
//       }
//
//       final paymentDate = dateFormatter.format(now);
//       final invoiceDate = dateTimeFormatter.format(now);
//       // final paymentDate = dateFormatter.format(now);
//       // final invoiceDate = dateTimeFormatter.format(now);
//
//       // Collect all services for all patients in a single array
//       final List<Map<String, dynamic>> services = [];
//       double subtotal = 0.0;
//
//       // Process each item in the cart
//       for (var item in items) {
//         final patientIds = (item['selectedPatientIds'] as List?) ?? [];
//         for (var patientId in patientIds) {
//           final patient = userModel.getPatientById(patientId.toString());
//           if (patient == null || patient.isEmpty) {
//             print('Patient not found for ID: $patientId');
//             continue;
//           }
//
//           final price = item['discountPrice'] as double;
//           subtotal += price;
//
//           services.add({
//             'user_id': patientId,
//             'testId': item['testId'] ?? 0,
//             'testName': item['name'],
//             'price': price,
//             'discount': '0',
//             'discountFormat': '0',
//             'quantity': 1,
//             'doctorReference': '',
//             'collectionWay': _requiresHomeCollection ? 'Home' : 'In-Center',
//             'testCategory': 'Test',
//             // 'organizationId': 37,
//             'organizationId': orgId,
//             'createdBy': patientId,
//             'updatedBy': patientId,
//             'referencePatientId': patientId,
//             'serviceCategory': 1,
//             'btobrate': null,
//             'patientDetails': {
//               'firstName': patient['firstName'],
//               'lastName': patient['lastName'] ?? '',
//               'age': patient['age']?.toString(),
//               'gender': patient['gender'],
//               'contactNumber': patient['contactNumber'],
//             },
//           });
//         }
//       }
//
//       // Add home collection service (only once, assigned to the primary user)
//       final primaryUserId = userModel.currentUser!['appUserId'].toString();
//       final primaryPatient = userModel.getPatientById(primaryUserId);
//       if (_requiresHomeCollection) {
//         services.add({
//           'user_id': primaryUserId,
//           'testId': 14,
//           'testName': 'Home Sample Collection',
//           'price': _homeCollectionCharge,
//           'discount': '0',
//           'discountFormat': '0',
//           'quantity': 1,
//           'doctorReference': '',
//           'collectionWay': 'Home',
//           'testCategory': 'Services',
//           // 'organizationId': 37,
//           'organizationId': orgId,
//           'createdBy': primaryUserId,
//           'updatedBy': primaryUserId,
//           'referencePatientId': '',
//           'serviceCategory': 5,
//           'btobrate': _homeCollectionCharge,
//         });
//         subtotal += _homeCollectionCharge;
//       }
//
//       // Calculate wallet-related values
//       final isWalletEnabled =
//           items.isNotEmpty && items.first['isWalletEnabled'] == true;
//       final walletBalance = isWalletEnabled ? walletAmount : 0.0;
//       final walletDiscountPercentage =
//       isWalletEnabled ? this.walletDiscountPercentage : 0.0;
//       final walletDiscount =
//       isWalletEnabled && walletBalance > 0
//           ? subtotal * (walletDiscountPercentage / 100)
//           : 0.0;
//       final totalAmountPaid = subtotal - walletDiscount;
//       final hasWalletDiscount =
//           isWalletEnabled && walletBalance > 0 && walletDiscount > 0;
//
//       // Determine payment status and mode
//       String paymentStatus;
//       String displayPaymentMode;
//       double remainingAmount;
//       String advancePayment;
//       double totalPaymentAmount;
//
//       if (paymentMode == 'Pay Now') {
//         paymentStatus = 'Paid';
//         displayPaymentMode = 'Online';
//         remainingAmount = 0.0;
//         advancePayment = (walletDiscount + totalAmountPaid).toStringAsFixed(0);
//         totalPaymentAmount = subtotal;
//       } else {
//         if (hasWalletDiscount) {
//           paymentStatus = 'Partial';
//           displayPaymentMode = 'Partial';
//         } else {
//           paymentStatus = 'Pay Later';
//           displayPaymentMode = 'Pay Later';
//         }
//         remainingAmount = totalAmountPaid;
//         advancePayment =
//         hasWalletDiscount ? walletDiscount.toStringAsFixed(0) : '0';
//         totalPaymentAmount = totalAmountPaid;
//       }
//
//       // Build invoice payments
//       final List<Map<String, dynamic>> invoicePayments = [];
//       if (paymentMode == 'Pay Now') {
//         if (hasWalletDiscount) {
//           invoicePayments.add({
//             'payment_mode': 'Wallet',
//             'dateandtime': invoiceDate,
//             'amount': walletDiscount.toStringAsFixed(0),
//           });
//         }
//         if (totalAmountPaid > 0) {
//           invoicePayments.add({
//             'payment_mode': 'Online',
//             'dateandtime': invoiceDate,
//             'amount': totalAmountPaid.toStringAsFixed(0),
//           });
//         }
//       } else {
//         if (hasWalletDiscount) {
//           invoicePayments.add({
//             'payment_mode': 'Partial',
//             'dateandtime': invoiceDate,
//             'amount': walletDiscount.toStringAsFixed(0),
//           });
//         } else {
//           invoicePayments.add({
//             'payment_mode': 'Pay Later',
//             'dateandtime': invoiceDate,
//             'amount': '0',
//           });
//         }
//       }
//
//       // Use primary user's details for the booking
//       final patientName =
//       '${primaryPatient?['firstName']} ${primaryPatient?['lastName'] ?? ''}'
//           .trim();
//       final patientContact = primaryPatient?['contactNumber'] ?? '';
//
//       // Build the single booking request
//       final requestBody = {
//         'username': patientName,
//         'contact': patientContact,
//         'request_status': paymentMode == 'Pay Now' ? 'Accepted' : 'Pending',
//         'address': _requiresHomeCollection ? _selectedAddress : null,
//         'bookingSlot': _requiresHomeCollection ? _selectedTimeSlot : null,
//         'raw_booking': {
//           // 'bookingDate':
//           // _requiresHomeCollection && _selectedBookingDate != null
//           //     ? _selectedBookingDate
//           //     : bookingDate,
//           'bookingDate': bookingDate,
//           'doctorReference': 'Self',
//           'amount': totalPaymentAmount,
//           'paymentDate': paymentDate,
//           'paymentStatus': paymentStatus,
//           'notes': '',
//           'bookingStatus': 'Booked',
//           'collectionWay': _requiresHomeCollection ? 'Home' : 'In-Center',
//           'paymentMode': displayPaymentMode,
//           'organizationId': orgId,
//           'createdBy': primaryUserId,
//           'updatedBy': primaryUserId,
//           'is_web': false,
//           'remainingAmount': remainingAmount,
//           'advancePayment': advancePayment,
//           'labPartner': null,
//           'discountBy': 'Lab',
//           'discountGiven':
//           hasWalletDiscount ? walletDiscount.toStringAsFixed(0) : '0',
//           'discountReason': hasWalletDiscount ? 'Wallet discount' : '0',
//           'paymentInformation': {
//             'invoiceDate': invoiceDate,
//             'totalPrice': subtotal.toStringAsFixed(0),
//             'totalDiscount': walletDiscount.toStringAsFixed(0),
//             'createdBy': primaryUserId,
//             'updatedBy': primaryUserId,
//             'organizationId': orgId,
//             'remainingAmount': remainingAmount.toStringAsFixed(0),
//             'advancePayment': advancePayment,
//             'invoicepayments': invoicePayments,
//             'pointsBalance': walletBalance.toStringAsFixed(0),
//             'pointsUsed': hasWalletDiscount ? walletDiscount : 0,
//           },
//           'services':
//           services.map((service) {
//             return {
//               ...service,
//               'force_patient_id': service['user_id'],
//               'skip_patient_creation': true,
//             };
//           }).toList(),
//           'patient_linking': {
//             'primary_user_id': primaryUserId,
//             'actual_patient_id': primaryUserId,
//             // Primary user as the main reference
//           },
//         },
//         'org_id': orgId,
//         'user_id': primaryUserId,
//       };
//
//       print('Sending order request: ${jsonEncode(requestBody)}');
//       logger.d(
//         'Services array: ${jsonEncode(requestBody['raw_booking']['services'])}',
//       );
//       logger.d('Full request: ${jsonEncode(requestBody)}');
//
//       final response = await _dio.post(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/register-booking-requests',
//         data: requestBody,
//         cancelToken: _cancelToken,
//         options: Options(
//           headers: {
//             'x-api-key': 'YOUR_API_KEY_HERE',
//             'Content-Type': 'application/json',
//           },
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       logger.d('API Response: ${jsonEncode(response.data)}');
//       print(
//         'API Response - Status: ${response.statusCode}, Data: ${response.data}',
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (response.data is Map && response.data['body'] is Map) {
//           final responseBody = response.data['body'];
//           final requestId = responseBody['request_id']?.toString();
//           final bookingId = responseBody['booking_id']?.toString();
//           final patientResponseId = responseBody['patient_id']?.toString();
//
//           if (responseBody['status'] == 'success') {
//             final message =
//                 responseBody['message'] ?? 'Order placed successfully';
//
//             // Add to order history
//             orderHistory.add({
//               'id':
//               requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//               'request_id': requestId,
//               'booking_id': bookingId,
//               'user_id': patientResponseId,
//               'items': items, // Store all items
//               'date': DateTime.now(),
//               'requiresHomeCollection': _requiresHomeCollection,
//               'status': paymentMode == 'Pay Now' ? 'Accepted' : 'Pending',
//               'subtotal': subtotal,
//               'discount': walletDiscount,
//               'totalAmountPaid': totalAmountPaid,
//               'paymentMode': displayPaymentMode,
//               'paymentStatus': paymentStatus,
//               'pointsBalanceAfterDeduction':
//               (isWalletEnabled && walletBalance >= walletDiscount)
//                   ? walletBalance - walletDiscount
//                   : walletBalance,
//               'walletAmtPercentage': walletDiscountPercentage,
//             });
//
//             await _saveOrderHistory();
//             items.clear();
//             _requiresHomeCollection = false;
//             notifyListeners();
//
//             if (requestId != null) {
//               _verifyOrderAppearsInList(requestId);
//             }
//
//             return {
//               'success': true,
//               'orders': [
//                 {
//                   'success': true,
//                   'orderId': requestId,
//                   'bookingId': bookingId,
//                   'user_id': patientResponseId,
//                   'message': message,
//                 },
//               ],
//               'message': message,
//             };
//           } else {
//             print('Order failed with message: ${responseBody['message']}');
//             return {
//               'success': false,
//               'message': 'Failed to place order: ${responseBody['message']}',
//             };
//           }
//         } else {
//           print('Unexpected response structure: ${response.data}');
//           return {
//             'success': false,
//             'message': 'Unexpected response from server',
//           };
//         }
//       } else if (response.statusCode == 403) {
//         print('403 Forbidden - Check API key and permissions');
//         return {
//           'success': false,
//           'message': 'Access denied. Please check your credentials.',
//         };
//       } else {
//         print('Order failed with HTTP status: ${response.statusCode}');
//         return {
//           'success': false,
//           'message': 'Failed to place order: HTTP ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       if (e is DioException) {
//         print('DioError: ${e.message}');
//         print('Response: ${e.response?.data}');
//         print('Request: ${e.requestOptions.data}');
//         if (e.response?.statusCode == 403) {
//           return {
//             'success': false,
//             'message':
//             'Authentication failed. Please check your API key and permissions.',
//           };
//         }
//       }
//       print('Error placing order: $e');
//       return {
//         'success': false,
//         'message': 'Error placing order: ${e.toString()}',
//       };
//     }
//   }
//
//   Future<void> _verifyOrderAppearsInList(String requestId) async {
//     final orgId = _currentOrganizationId;
//     if (orgId == null) return;
//     try {
//       final verifyResponse = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
//         queryParameters: {
//           'org_id': orgId,
//           'request_id': requestId,
//           'include_family': true,
//           'primary_user_id': userModel.currentUser!['appUserId'],
//         },
//         options: Options(
//           headers: {
//             'x-api-key': 'YOUR_API_KEY_HERE',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       logger.d('Detailed order response: ${jsonEncode(verifyResponse.data)}');
//       if (verifyResponse.statusCode == 200) {
//         final responseData = verifyResponse.data['body'];
//         final isOrderVerified =
//             responseData['status'] == 'success' &&
//                 responseData['data'] is List &&
//                 responseData['data'].any(
//                       (order) => order['bookingRequestId'].toString() == requestId,
//                 );
//
//         if (isOrderVerified) {
//           print('Order $requestId successfully verified');
//           _updateOrderStatus(
//             requestId,
//             responseData['data'].firstWhere(
//                   (order) => order['bookingRequestId'].toString() == requestId,
//             )['requestStatus'] ??
//                 'Confirmed',
//           );
//         } else {
//           print('Order not found in verification response - will retry');
//           await _retryVerification(requestId);
//         }
//       } else {
//         print('Verification failed with status: ${verifyResponse.statusCode}');
//         await _retryVerification(requestId);
//       }
//     } catch (e) {
//       print('Error verifying order: $e');
//       await _retryVerification(requestId);
//     }
//   }
//
//   Future<void> _retryVerification(String requestId) async {
//     await Future.delayed(Duration(seconds: 5));
//     _verifyOrderAppearsInList(requestId);
//   }
//
//   void _updateOrderStatus(String requestId, String status) async {
//     final orderIndex = orderHistory.indexWhere(
//           (o) => o['request_id'] == requestId,
//     );
//     if (orderIndex != -1) {
//       orderHistory[orderIndex]['status'] = status;
//       await _saveOrderHistory();
//       notifyListeners();
//     }
//   }
//
//   // Future<List<Map<String, dynamic>>> fetchOrders({
//   //   String? fromDate,
//   //   String? toDate,
//   // }) async {
//   //   final cartModel = Provider.of<CartModel>(context, listen: false);
//   //   final orgId = cartModel.currentOrganizationId;
//   //
//   //   if (orgId == null) return [];
//   //   try {
//   //     final queryParameters = {
//   //       'org_id': orgId,
//   //       'primary_user_id': userModel.currentUser!['appUserId'],
//   //       'include_family_details': true,
//   //       'show_actual_patient': true,
//   //     };
//   //
//   //     if (fromDate != null && toDate != null) {
//   //       queryParameters['from_date'] = fromDate;
//   //       queryParameters['to_date'] = toDate;
//   //     }
//   //
//   //     final response = await _dio.get(
//   //       'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
//   //       queryParameters: queryParameters,
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       return _processFamilyOrders(response.data['body']);
//   //     }
//   //     return [];
//   //   } catch (e) {
//   //     print('Error fetching orders: $e');
//   //     return [];
//   //   }
//   // }
//   Future<List<Map<String, dynamic>>> fetchOrders({
//     required BuildContext context,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     final orgId = cartModel.currentOrganizationId;
//
//     if (orgId == null) return [];
//
//     try {
//       final queryParameters = {
//         'org_id': orgId,
//         'primary_user_id': userModel.currentUser!['appUserId'],
//         'include_family_details': true,
//         'show_actual_patient': true,
//       };
//
//       if (fromDate != null && toDate != null) {
//         queryParameters['from_date'] = fromDate;
//         queryParameters['to_date'] = toDate;
//       }
//
//       final response = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
//         queryParameters: queryParameters,
//       );
//
//       if (response.statusCode == 200) {
//         return _processFamilyOrders(response.data['body']);
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching orders: $e');
//       return [];
//     }
//   }
//   Future<void> updateBookingRequestStatus({
//     required String requestId,
//     required String bookingId,
//     required String requestStatus,
//   }) async {
//     try {
//       final response = await _dio.post(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/booking-request-decisions',
//         queryParameters: {
//           'request_id': requestId,
//           'request_status': requestStatus,
//           'booking_id': bookingId,
//         },
//         options: Options(
//           headers: {
//             'x-api-key': 'YOUR_API_KEY_HERE',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       print('Booking request decision response: ${response.data}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final orderIndex = orderHistory.indexWhere(
//               (o) => o['request_id'] == requestId,
//         );
//         if (orderIndex != -1) {
//           orderHistory[orderIndex]['status'] = requestStatus;
//           await _saveOrderHistory();
//           notifyListeners();
//           print('Order $requestId status updated to $requestStatus');
//         }
//       } else {
//         print(
//           'Failed to update booking request status: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       print('Error updating booking request status: $e');
//     }
//   }
//
//   List<Map<String, dynamic>> _processFamilyOrders(dynamic responseData) {
//     if (responseData is List) {
//       return responseData.map((order) {
//         final patientId = order['actual_patient_id'] ?? order['patient_id'];
//         final patient = userModel.getPatientById(patientId.toString());
//
//         return {
//           'id': order['bookingRequestId']?.toString(),
//           'status': order['requestStatus'],
//           'date': order['createdOn'],
//           'patient_id': patientId,
//           'patient_name':
//           patient != null
//               ? '${patient['firstName']} ${patient['lastName'] ?? ''}'
//               : 'Unknown Patient',
//           'patient_age': patient?['age']?.toString(),
//           'is_family_order': patientId != userModel.currentUser!['appUserId'],
//           'tests':
//           order['services']?.map((s) => s['testName']).join(', ') ?? '',
//           'amount': order['amount'],
//         };
//       }).toList();
//     }
//     return [];
//   }
//
//   void cancelOrder(String orderId) async {
//     print('Attempting to cancel order: $orderId');
//     final orderIndex = orderHistory.indexWhere(
//           (order) => order['id'] == orderId,
//     );
//     if (orderIndex != -1) {
//       print('Found order to cancel, updating status');
//       orderHistory[orderIndex]['status'] = 'Cancelled';
//       orderHistory[orderIndex]['cancelledAt'] = DateTime.now();
//       await _saveOrderHistory();
//       notifyListeners();
//     } else {
//       print('Order not found for cancellation');
//     }
//   }
// }
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/UserModel/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../services/NotificationService/notification_service.dart';
class CartModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  final UserModel userModel;
  final logger = Logger();
  int? _currentOrganizationId;
  List<Map<String, dynamic>> get items => _items;
  double _homeCollectionCharge = 200.0;
  bool _requiresHomeCollection = false;
  List<Map<String, dynamic>> orderHistory = [];

  int get itemCount => _items.length;

  double get homeCollectionCharge => _homeCollectionCharge;
  final Map<String, bool> _selectedItems = {};

  Map<String, bool> get selectedItems => _selectedItems;

  bool isItemSelected(String itemId) => _selectedItems[itemId] ?? true;
  void toggleItemSelection(String itemId, bool isSelected) {
    _selectedItems[itemId] = isSelected;
    notifyListeners();
  }

  void selectAllItems() {
    for (var item in _items) {
      final itemId = item['itemId'];
      _selectedItems[itemId] = true;
    }
    notifyListeners();
  }

  void deselectAllItems() {
    for (var item in _items) {
      final itemId = item['itemId'];
      _selectedItems[itemId] = false;
    }
    notifyListeners();
  }

  double get selectedTotalPrice {
    final subtotal = _items.fold(0.0, (sum, item) {
      final itemId = item['itemId'];
      if (!isItemSelected(itemId)) return sum;

      final price = item['discountPrice'] as double;
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });

    final total = _requiresHomeCollection ? subtotal + _homeCollectionCharge : subtotal;
    return total;
  }
  double get selectedSubtotal {
    return _items.fold(0.0, (sum, item) {
      final itemId = item['itemId'];
      if (!isItemSelected(itemId)) return sum;

      final price = item['discountPrice'] as double;
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }
  int get selectedItemCount {
    return _items.where((item) => isItemSelected(item['itemId'])).length;
  }
  bool get requiresHomeCollection => _requiresHomeCollection;
  String? _selectedAddress;
  String? _selectedTimeSlot;
  String? _selectedBookingDate;
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingTimeSlots = false;

  String? get selectedAddress => _selectedAddress;

  String? get selectedTimeSlot => _selectedTimeSlot;

  String? get selectedBookingDate => _selectedBookingDate;

  List<Map<String, dynamic>> get timeSlots => _timeSlots;

  bool get isLoadingTimeSlots => _isLoadingTimeSlots;

  void setCurrentOrganizationId(int orgId) {
    _currentOrganizationId = orgId;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  int? get currentOrganizationId => _currentOrganizationId;
  CartModel({required this.userModel}) {
    print('CartModel initialized');
    _cancelToken = CancelToken();
    loadOrderHistory();
  }

  Future<void> loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderHistoryJson = prefs.getString('orderHistory');
      if (orderHistoryJson != null) {
        final List<dynamic> decoded = json.decode(orderHistoryJson);
        orderHistory =
            decoded.map<Map<String, dynamic>>((item) {
              return {
                ...item,
                'date': DateTime.parse(item['date']),
                'items': List<Map<String, dynamic>>.from(item['items']),
              };
            }).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading order history: $e');
    }
  }

  @override
  void dispose() {
    print('CartModel disposed');
    _cancelToken?.cancel();
    _dio.close();
    super.dispose();
  }

  Future<void> _saveOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderHistoryJson = json.encode(
        orderHistory.map((order) {
          return {
            ...order,
            'date': order['date'].toString(),
            'items': order['items'],
          };
        }).toList(),
      );
      await prefs.setString('orderHistory', orderHistoryJson);
    } catch (e) {
      print('Error saving order history: $e');
    }
  }

  void setHomeCollectionCharge(double charge) {
    print('Setting homeCollectionCharge to $charge');
    _homeCollectionCharge = charge;
    notifyListeners();
  }

  void setRequiresHomeCollection(bool value) {
    print('Setting requiresHomeCollection to $value');
    _requiresHomeCollection = value;
    notifyListeners();
  }

  double get totalPrice {
    final subtotal = _items.fold(0.0, (sum, item) {
      final price = item['discountPrice'] as double;
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
    final total =
    _requiresHomeCollection ? subtotal + _homeCollectionCharge : subtotal;
    print('Calculating total price: ₹$total');
    return total;
  }

  double get walletAmount {
    if (_items.isEmpty) return 0.0;
    if (_items.first['isWalletEnabled'] != true) return 0.0;
    final points = _items.first['pointBalance']?.toString() ?? '0';
    return double.tryParse(points) ?? 0.0;
  }

  double get walletDiscountPercentage {
    if (_items.isEmpty) return 0.0;
    if (_items.first['isWalletEnabled'] != true) return 0.0;
    return _items.first['walletAmtPercentage']?.toDouble() ?? 0.0;
  }

  void addToCart(Map<String, dynamic> test, {int quantity = 1}) {
    final itemId = '${test['provider']}_${test['name']}';
    print('Adding to cart - Item: $itemId');

    final patientCount = (test['selectedPatientIds'] as List?)?.length ?? 1;

    final existingItemIndex = _items.indexWhere(
          (item) => item['itemId'] == itemId,
    );

    if (existingItemIndex != -1) {
      print('Item already in cart, updating patient selection');
      _items[existingItemIndex]['selectedPatientIds'] =
          test['selectedPatientIds'] ??
              _items[existingItemIndex]['selectedPatientIds'];
      _items[existingItemIndex]['quantity'] =
          (_items[existingItemIndex]['selectedPatientIds'] as List).length;
    } else {
      print('Adding new item to cart');
      _items.add({
        ...test,
        'itemId': itemId,
        'quantity': patientCount,
        'testId': test['testId'] ?? 0,
        'pointBalance': test['pointBalance']?.toString() ?? '0',
        'walletAmtPercentage': test['walletAmtPercentage']?.toDouble() ?? 0.0,
        'selectedPatientIds': test['selectedPatientIds'] ?? [],
        'organizationName': test['provider'] ?? 'Provider',
      });
    }
    notifyListeners();
    print(
      'Cart updated. Current items: ${_items.length}, Quantity: $patientCount',
    );
  }

  void removeFromCart(String itemId) {
    print('Removing item from cart: $itemId');
    _items.removeWhere((item) => item['itemId'] == itemId);
    notifyListeners();
    print('Item removed. Remaining items: ${_items.length}');
  }

  void clearCart() {
    print('Clearing cart');
    _items.clear();
    _selectedItems.clear();
    _requiresHomeCollection = false;
    notifyListeners();
    print('Cart cleared');
  }

  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setSelectedTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  void setSelectedBookingDate(String date) {
    _selectedBookingDate = date;
    fetchTimeSlots();
    notifyListeners();
  }

  // Future<void> fetchTimeSlots() async {
  //   _isLoadingTimeSlots = true;
  //   notifyListeners();
  //
  //   try {
  //     final response = await _dio.get(
  //       'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/booking-slot?id=0',
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data['body']['data'] as List;
  //       _timeSlots = data.cast<Map<String, dynamic>>();
  //     } else {
  //       _timeSlots = [];
  //     }
  //   } catch (e) {
  //     print('Error fetching time slots: $e');
  //     _timeSlots = [];
  //   } finally {
  //     _isLoadingTimeSlots = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchTimeSlots() async {
    _isLoadingTimeSlots = true;
    notifyListeners();

    try {
      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/booking-slot?id=0',
      );

      if (response.statusCode == 200) {
        final data = response.data['body']['data'] as List;
        final now = DateTime.now();
        final currentHour = now.hour;
        final currentMinute = now.minute;

        // Process slots to add availability information
        _timeSlots = data.asMap().entries.map<Map<String, dynamic>>((entry) {
          final index = entry.key;
          final slot = entry.value;
          final slotName = slot['slotName'] as String;

          bool isAvailable = true;

          // If selected date is today, check if slot has passed
          final selectedDate = _selectedBookingDate;
          final today = DateFormat('yyyy-MM-dd').format(now);
          if (selectedDate == today) {
            // Estimate slot time based on index (9 AM + index hours)
            final slotHour = 9 + index;
            isAvailable = slotHour > currentHour ||
                (slotHour == currentHour && 0 > currentMinute);
          }

          return {
            ...slot,
            'timing': slotName,
            'available': isAvailable,
          };
        }).toList();
      } else {
        _timeSlots = [];
      }
    } catch (e) {
      print('Error fetching time slots: $e');
      _timeSlots = [];
    } finally {
      _isLoadingTimeSlots = false;
      notifyListeners();
    }
  }
  void clearHomeCollectionDetails() {
    _selectedAddress = null;
    _selectedTimeSlot = null;
    _selectedBookingDate = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> placeOrder(String paymentMode) async {
    if (_currentOrganizationId == null) {
      print('Order failed: No organization ID set');
      return {'success': false, 'message': 'No organization selected'};
    }

    final orgId = _currentOrganizationId!;
    print('Attempting to place order for organization: $orgId');
    print('Attempting to place order with payment mode: $paymentMode');

    if (items.isEmpty) {
      print('Order failed: Cart is empty');
      return {'success': false, 'message': 'Cart is empty'};
    }

    if (userModel.currentUser == null ||
        userModel.currentUser!['appUserId'] == null) {
      print('Order failed: User not logged in');
      return {'success': false, 'message': 'Please log in to place an order'};
    }

    try {
      final now = DateTime.now();
      final dateFormatter = DateFormat('dd-MM-yyyy');
      final dateTimeFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
      // final bookingDate = dateFormatter.format(now);
      String bookingDate;
      if (_requiresHomeCollection && _selectedBookingDate != null) {
        // Parse the selected date and format it consistently
        try {
          final selectedDate = DateFormat('yyyy-MM-dd').parse(_selectedBookingDate!);
          bookingDate = dateFormatter.format(selectedDate);
        } catch (e) {
          // Fallback to current date if parsing fails
          bookingDate = dateFormatter.format(now);
        }
      } else {
        bookingDate = dateFormatter.format(now);
      }

      final paymentDate = dateFormatter.format(now);
      final invoiceDate = dateTimeFormatter.format(now);
      // final paymentDate = dateFormatter.format(now);
      // final invoiceDate = dateTimeFormatter.format(now);

      // Collect all services for all patients in a single array
      final List<Map<String, dynamic>> services = [];
      double subtotal = 0.0;

      // Process each item in the cart
      for (var item in items) {
        final itemId = item['itemId'];
        if (!isItemSelected(itemId)) continue;
        final patientIds = (item['selectedPatientIds'] as List?) ?? [];
        for (var patientId in patientIds) {
          final patient = userModel.getPatientById(patientId.toString());
          if (patient == null || patient.isEmpty) {
            print('Patient not found for ID: $patientId');
            continue;
          }

          final price = item['discountPrice'] as double;
          subtotal += price;

          services.add({
            'user_id': patientId,
            'testId': item['testId'] ?? 0,
            'testName': item['name'],
            'price': price,
            'discount': '0',
            'discountFormat': '0',
            'quantity': 1,
            'doctorReference': '',
            'collectionWay': _requiresHomeCollection ? 'Home' : 'In-Center',
            'testCategory': 'Test',
            'organizationId': orgId,
            'createdBy': patientId,
            'updatedBy': patientId,
            'referencePatientId': patientId,
            'serviceCategory': 1,
            'btobrate': null,
            'patientDetails': {
              'firstName': patient['firstName'],
              'lastName': patient['lastName'] ?? '',
              'age': patient['age']?.toString(),
              'gender': patient['gender'],
              'contactNumber': patient['contactNumber'],
            },
          });
        }
      }

      // Add home collection service (only once, assigned to the primary user)
      final primaryUserId = userModel.currentUser!['appUserId'].toString();
      final primaryPatient = userModel.getPatientById(primaryUserId);
      if (_requiresHomeCollection) {
        services.add({
          'user_id': primaryUserId,
          'testId': 14,
          'testName': 'Home Sample Collection',
          'price': _homeCollectionCharge,
          'discount': '0',
          'discountFormat': '0',
          'quantity': 1,
          'doctorReference': '',
          'collectionWay': 'Home',
          'testCategory': 'Services',
          'organizationId': orgId,
          'createdBy': primaryUserId,
          'updatedBy': primaryUserId,
          'referencePatientId': '',
          'serviceCategory': 5,
          'btobrate': _homeCollectionCharge,
        });
        subtotal += _homeCollectionCharge;
      }

      // Calculate wallet-related values
      final isWalletEnabled =
          items.isNotEmpty && items.first['isWalletEnabled'] == true;
      final walletBalance = isWalletEnabled ? walletAmount : 0.0;
      final walletDiscountPercentage =
      isWalletEnabled ? this.walletDiscountPercentage : 0.0;
      final walletDiscount =
      isWalletEnabled && walletBalance > 0
          ? subtotal * (walletDiscountPercentage / 100)
          : 0.0;
      final totalAmountPaid = subtotal - walletDiscount;
      final hasWalletDiscount =
          isWalletEnabled && walletBalance > 0 && walletDiscount > 0;

      // Determine payment status and mode
      String paymentStatus;
      String displayPaymentMode;
      double remainingAmount;
      String advancePayment;
      double totalPaymentAmount;

      if (paymentMode == 'Pay Now') {
        paymentStatus = 'Paid';
        displayPaymentMode = 'Online';
        remainingAmount = 0.0;
        advancePayment = (walletDiscount + totalAmountPaid).toStringAsFixed(0);
        totalPaymentAmount = subtotal;
      } else {
        if (hasWalletDiscount) {
          paymentStatus = 'Partial';
          displayPaymentMode = 'Partial';
        } else {
          paymentStatus = 'Pay Later';
          displayPaymentMode = 'Pay Later';
        }
        remainingAmount = totalAmountPaid;
        advancePayment =
        hasWalletDiscount ? walletDiscount.toStringAsFixed(0) : '0';
        totalPaymentAmount = totalAmountPaid;
      }

      // Build invoice payments
      final List<Map<String, dynamic>> invoicePayments = [];
      if (paymentMode == 'Pay Now') {
        if (hasWalletDiscount) {
          invoicePayments.add({
            'payment_mode': 'Wallet',
            'dateandtime': invoiceDate,
            'amount': walletDiscount.toStringAsFixed(0),
          });
        }
        if (totalAmountPaid > 0) {
          invoicePayments.add({
            'payment_mode': 'Online',
            'dateandtime': invoiceDate,
            'amount': totalAmountPaid.toStringAsFixed(0),
          });
        }
      } else {
        if (hasWalletDiscount) {
          invoicePayments.add({
            'payment_mode': 'Partial',
            'dateandtime': invoiceDate,
            'amount': walletDiscount.toStringAsFixed(0),
          });
        } else {
          invoicePayments.add({
            'payment_mode': 'Pay Later',
            'dateandtime': invoiceDate,
            'amount': '0',
          });
        }
      }

      // Use primary user's details for the booking
      final patientName =
      '${primaryPatient?['firstName']} ${primaryPatient?['lastName'] ?? ''}'
          .trim();
      final patientContact = primaryPatient?['contactNumber'] ?? '';

      // Build the single booking request
      final requestBody = {
        'username': patientName,
        'contact': patientContact,
        'request_status': paymentMode == 'Pay Now' ? 'Accepted' : 'Pending',
        'address': _requiresHomeCollection ? _selectedAddress : null,
        'bookingSlot': _requiresHomeCollection ? _selectedTimeSlot : null,
        'raw_booking': {
          // 'bookingDate':
          // _requiresHomeCollection && _selectedBookingDate != null
          //     ? _selectedBookingDate
          //     : bookingDate,
          'bookingDate': bookingDate,
          'doctorReference': 'Self',
          'amount': totalPaymentAmount,
          'paymentDate': paymentDate,
          'paymentStatus': paymentStatus,
          'notes': '',
          'bookingStatus': 'Booked',
          'collectionWay': _requiresHomeCollection ? 'Home' : 'In-Center',
          'paymentMode': displayPaymentMode,
          'organizationId': orgId,
          'createdBy': primaryUserId,
          'updatedBy': primaryUserId,
          'is_web': false,
          'remainingAmount': remainingAmount,
          'advancePayment': advancePayment,
          'labPartner': null,
          'discountBy': 'Lab',
          'discountGiven':
          hasWalletDiscount ? walletDiscount.toStringAsFixed(0) : '0',
          'discountReason': hasWalletDiscount ? 'Wallet discount' : '0',
          'paymentInformation': {
            'invoiceDate': invoiceDate,
            'totalPrice': subtotal.toStringAsFixed(0),
            'totalDiscount': walletDiscount.toStringAsFixed(0),
            'createdBy': primaryUserId,
            'updatedBy': primaryUserId,
            'organizationId': orgId,
            'remainingAmount': remainingAmount.toStringAsFixed(0),
            'advancePayment': advancePayment,
            'invoicepayments': invoicePayments,
            'pointsBalance': walletBalance.toStringAsFixed(0),
            'pointsUsed': hasWalletDiscount ? walletDiscount : 0,
          },
          'services':
          services.map((service) {
            return {
              ...service,
              // 'force_patient_id': service['user_id'],
              // 'skip_patient_creation': true,
            };
          }).toList(),
          'patient_linking': {
            'primary_user_id': primaryUserId,
            'actual_patient_id': primaryUserId,
            // Primary user as the main reference
          },
        },
        'org_id': orgId,
        'user_id': primaryUserId,
      };

      print('Sending order request: ${jsonEncode(requestBody)}');
      logger.d(
        'Services array: ${jsonEncode(requestBody['raw_booking']['services'])}',
      );
      logger.d('Full request: ${jsonEncode(requestBody)}');

      final response = await _dio.post(
        // 'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/register-booking-requests',
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/register-booking-requests',
        data: requestBody,
        cancelToken: _cancelToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      logger.d('API Response: ${jsonEncode(response.data)}');
      print(
        'API Response - Status: ${response.statusCode}, Data: ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['body'] is Map) {
          final responseBody = response.data['body'];
          final requestId = responseBody['request_id']?.toString();
          final bookingId = responseBody['booking_id']?.toString();
          final patientResponseId = responseBody['patient_id']?.toString();

          if (responseBody['status'] == 'success') {
            final message =
                responseBody['message'] ?? 'Order placed successfully';
            // Show order notification
            final notificationService = NotificationService();
            await notificationService.showOrderNotification(
                requestId ?? 'N/A',
                totalAmountPaid
            );
            // Add to order history
            orderHistory.add({
              'id':
              requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
              'request_id': requestId,
              'booking_id': bookingId,
              'user_id': patientResponseId,
              'items': items,
              'date': DateTime.now(),
              'requiresHomeCollection': _requiresHomeCollection,
              'status': paymentMode == 'Pay Now' ? 'Accepted' : 'Pending',
              'subtotal': subtotal,
              'discount': walletDiscount,
              'totalAmountPaid': totalAmountPaid,
              'paymentMode': displayPaymentMode,
              'paymentStatus': paymentStatus,
              'pointsBalanceAfterDeduction':
              (isWalletEnabled && walletBalance >= walletDiscount)
                  ? walletBalance - walletDiscount
                  : walletBalance,
              'walletAmtPercentage': walletDiscountPercentage,
            });

            await _saveOrderHistory();
            items.clear();
            _requiresHomeCollection = false;
            notifyListeners();

            if (requestId != null) {
              _verifyOrderAppearsInList(requestId);
            }

            return {
              'success': true,
              'orders': [
                {
                  'success': true,
                  'orderId': requestId,
                  'bookingId': bookingId,
                  'user_id': patientResponseId,
                  'message': message,
                },
              ],
              'message': message,
            };
          } else {
            print('Order failed with message: ${responseBody['message']}');
            return {
              'success': false,
              'message': 'Failed to place order: ${responseBody['message']}',
            };
          }
        } else {
          print('Unexpected response structure: ${response.data}');
          return {
            'success': false,
            'message': 'Unexpected response from server',
          };
        }
      } else if (response.statusCode == 403) {
        print('403 Forbidden - Check API key and permissions');
        return {
          'success': false,
          'message': 'Access denied. Please check your credentials.',
        };
      } else {
        print('Order failed with HTTP status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to place order: HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      if (e is DioException) {
        print('DioError: ${e.message}');
        print('Response: ${e.response?.data}');
        print('Request: ${e.requestOptions.data}');
        if (e.response?.statusCode == 403) {
          return {
            'success': false,
            'message':
            'Authentication failed. Please check your API key and permissions.',
          };
        }
      }
      print('Error placing order: $e');
      return {
        'success': false,
        'message': 'Error placing order: ${e.toString()}',
      };
    }
  }

  Future<void> _verifyOrderAppearsInList(String requestId) async {
    final orgId = _currentOrganizationId;
    if (orgId == null) return;
    try {
      final verifyResponse = await _dio.get(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
        queryParameters: {
          'org_id': orgId,
          'request_id': requestId,
          'include_family': true,
          'primary_user_id': userModel.currentUser!['appUserId'],
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      logger.d('Detailed order response: ${jsonEncode(verifyResponse.data)}');
      if (verifyResponse.statusCode == 200) {
        final responseData = verifyResponse.data['body'];
        final isOrderVerified =
            responseData['status'] == 'success' &&
                responseData['data'] is List &&
                responseData['data'].any(
                      (order) => order['bookingRequestId'].toString() == requestId,
                );

        if (isOrderVerified) {
          print('Order $requestId successfully verified');
          _updateOrderStatus(
            requestId,
            responseData['data'].firstWhere(
                  (order) => order['bookingRequestId'].toString() == requestId,
            )['requestStatus'] ??
                'Confirmed',
          );
        } else {
          print('Order not found in verification response - will retry');
          await _retryVerification(requestId);
        }
      } else {
        print('Verification failed with status: ${verifyResponse.statusCode}');
        await _retryVerification(requestId);
      }
    } catch (e) {
      print('Error verifying order: $e');
      await _retryVerification(requestId);
    }
  }

  Future<void> _retryVerification(String requestId) async {
    await Future.delayed(Duration(seconds: 5));
    _verifyOrderAppearsInList(requestId);
  }

  void _updateOrderStatus(String requestId, String status) async {
    final orderIndex = orderHistory.indexWhere(
          (o) => o['request_id'] == requestId,
    );
    if (orderIndex != -1) {
      orderHistory[orderIndex]['status'] = status;
      await _saveOrderHistory();
      notifyListeners();
      // Show status update notification
      // final notificationService = NotificationService();
      // await notificationService.showOrderStatusNotification(status, requestId);
    }
  }

  // Future<List<Map<String, dynamic>>> fetchOrders({
  //   String? fromDate,
  //   String? toDate,
  // }) async {
  //   final cartModel = Provider.of<CartModel>(context, listen: false);
  //   final orgId = cartModel.currentOrganizationId;
  //
  //   if (orgId == null) return [];
  //   try {
  //     final queryParameters = {
  //       'org_id': orgId,
  //       'primary_user_id': userModel.currentUser!['appUserId'],
  //       'include_family_details': true,
  //       'show_actual_patient': true,
  //     };
  //
  //     if (fromDate != null && toDate != null) {
  //       queryParameters['from_date'] = fromDate;
  //       queryParameters['to_date'] = toDate;
  //     }
  //
  //     final response = await _dio.get(
  //       'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
  //       queryParameters: queryParameters,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return _processFamilyOrders(response.data['body']);
  //     }
  //     return [];
  //   } catch (e) {
  //     print('Error fetching orders: $e');
  //     return [];
  //   }
  // }
  Future<List<Map<String, dynamic>>> fetchOrders({
    required BuildContext context,
    String? fromDate,
    String? toDate,
  }) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final orgId = cartModel.currentOrganizationId;

    if (orgId == null) return [];

    try {
      final queryParameters = {
        'org_id': orgId,
        'primary_user_id': userModel.currentUser!['appUserId'],
        'include_family_details': true,
        'show_actual_patient': true,
      };

      if (fromDate != null && toDate != null) {
        queryParameters['from_date'] = fromDate;
        queryParameters['to_date'] = toDate;
      }

      final response = await _dio.get(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/list-booking-requests',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return _processFamilyOrders(response.data['body']);
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
  Future<void> updateBookingRequestStatus({
    required String requestId,
    required String bookingId,
    required String requestStatus,
  }) async {
    try {
      final response = await _dio.post(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/booking-request-decisions',
        queryParameters: {
          'request_id': requestId,
          'request_status': requestStatus,
          'booking_id': bookingId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Booking request decision response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderIndex = orderHistory.indexWhere(
              (o) => o['request_id'] == requestId,
        );
        if (orderIndex != -1) {
          orderHistory[orderIndex]['status'] = requestStatus;
          await _saveOrderHistory();
          notifyListeners();
          print('Order $requestId status updated to $requestStatus');
        }
      } else {
        print(
          'Failed to update booking request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating booking request status: $e');
    }
  }

  List<Map<String, dynamic>> _processFamilyOrders(dynamic responseData) {
    if (responseData is List) {
      return responseData.map((order) {
        final patientId = order['actual_patient_id'] ?? order['patient_id'];
        final patient = userModel.getPatientById(patientId.toString());

        return {
          'id': order['bookingRequestId']?.toString(),
          'status': order['requestStatus'],
          'date': order['createdOn'],
          'patient_id': patientId,
          'patient_name':
          patient != null
              ? '${patient['firstName']} ${patient['lastName'] ?? ''}'
              : 'Unknown Patient',
          'patient_age': patient?['age']?.toString(),
          'is_family_order': patientId != userModel.currentUser!['appUserId'],
          'tests':
          order['services']?.map((s) => s['testName']).join(', ') ?? '',
          'amount': order['amount'],
        };
      }).toList();
    }
    return [];
  }

  void cancelOrder(String orderId) async {
    print('Attempting to cancel order: $orderId');
    final orderIndex = orderHistory.indexWhere(
          (order) => order['id'] == orderId,
    );
    if (orderIndex != -1) {
      print('Found order to cancel, updating status');
      orderHistory[orderIndex]['status'] = 'Cancelled';
      orderHistory[orderIndex]['cancelledAt'] = DateTime.now();
      await _saveOrderHistory();
      notifyListeners();
    } else {
      print('Order not found for cancellation');
    }
  }
}