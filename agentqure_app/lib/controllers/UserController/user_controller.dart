import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/UserModel/user_model.dart';
import '../../utils/ErrorUtils.dart';
import '../../views/SignInAndSignUpScreens/InsertProfileScreen/insert_profile_screen.dart';
import '../../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
import '../../views/UserDashboard/HomeScreen/home_screen.dart';

class UserController {
  final UserModel userModel;
  final BuildContext context;

  UserController(this.userModel, this.context);

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage, Permission.camera].request();
    statuses.forEach((permission, status) {
      print('${permission.toString()}: ${status.toString()}');
    });
  }

  // Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
  //   try {
  //     final response = await userModel.sendOtp('91', phoneNumber);
  //     print('sendOtp response: ${response.toString()}');
  //     return response;
  //   } catch (e) {
  //     print('Error in sendOtp: $e');
  //     ErrorUtils.showErrorSnackBar(context, 'Failed to send OTP. Please try again.');
  //     rethrow;
  //   }
  // }
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await userModel.sendOtp('91', phoneNumber);
      print('sendOtp response: ${response.toString()}');

      // Extract verificationId from different possible response structures
      String? verificationId;
      if (response['data'] != null) {
        verificationId = response['data']['verificationId'];
      } else if (response['body'] != null && response['body']['data'] != null) {
        verificationId = response['body']['data']['verificationId'];
      }

      if (verificationId == null) {
        throw Exception('Failed to get verification ID');
      }

      return {
        'message': 'SUCCESS',
        'data': {
          'verificationId': verificationId,
        }
      };
    } catch (e) {
      print('Error in sendOtp: $e');
      ErrorUtils.showErrorSnackBar(context, 'Failed to send OTP. Please try again.');
      rethrow;
    }
  }
  void handleLogin(String phoneNumber) {
    if (phoneNumber.length == 10) {
      sendOtp(phoneNumber);
    } else {
      ErrorUtils.showErrorSnackBar(context, 'Contact number must be 10 digits');
    }
  }

  // Future<void> verifyOtp(String otp, String phoneNumber, String verificationId, String? pendingReferralCode) async {
  //   try {
  //     final response = await userModel.validateOtp(verificationId, otp);
  //     print('verifyOtp response: ${response.toString()}');
  //
  //     // Check response structure more carefully
  //     final verificationStatus = response['data']?['verificationStatus'] ?? response['verificationStatus'];
  //     final message = response['message'] ?? response['status'];
  //
  //     if (message == 'SUCCESS' && verificationStatus == 'VERIFICATION_COMPLETED') {
  //       await _handleSuccessfulVerification(phoneNumber, pendingReferralCode);
  //     } else {
  //       final errorMsg = response['message'] ?? 'OTP validation failed';
  //       throw Exception(errorMsg);
  //     }
  //   } catch (e) {
  //     print('Error in verifyOtp: $e');
  //
  //     // Re-throw with more specific error messages
  //     if (e.toString().contains('401') || e.toString().contains('Authentication failed')) {
  //       throw Exception('Session expired. Please try again.');
  //     } else if (e.toString().contains('Network error')) {
  //       throw Exception('Network error. Please check your connection.');
  //     } else {
  //       throw Exception('Invalid OTP. Please try again.');
  //     }
  //   }
  // }
  Future<void> verifyOtp(String otp, String phoneNumber, String verificationId, String? pendingReferralCode) async {
    try {
      final response = await userModel.validateOtp(verificationId, otp);
      print('verifyOtp response: ${response.toString()}');

      // Check response structure more carefully
      final verificationStatus = response['data']?['verificationStatus'] ?? response['verificationStatus'];
      final message = response['message'] ?? response['status'];

      if (message == 'SUCCESS' && verificationStatus == 'VERIFICATION_COMPLETED') {
        await _handleSuccessfulVerification(phoneNumber, pendingReferralCode);
      } else {
        final errorMsg = response['message'] ?? 'OTP validation failed';
        throw errorMsg;
      }
    } catch (e) {
      print('Error in verifyOtp: $e');

      // Re-throw with more specific error messages without "Exception" word
      if (e.toString().contains('401') || e.toString().contains('Authentication failed')) {
        throw 'Session expired. Please try again.';
      } else if (e.toString().contains('Network error')) {
        throw 'Network error. Please check your connection.';
      } else {
        throw 'Invalid OTP. Please try again.';
      }
    }
  }
  Future<void> _handleSuccessfulVerification(String phoneNumber, String? pendingReferralCode) async {
    try {
      final userExists = await userModel.checkUserExists(phoneNumber);
      print('User exists: $userExists for phone: $phoneNumber');

      if (userExists) {
        final user = await userModel.getUserByPhone(phoneNumber);
        if (user != null) {
          await userModel.login(phoneNumber);
          print('Navigating to HomeScreen after successful login');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
          return;
        } else {
          throw Exception('User data could not be retrieved');
        }
      }

      print('Navigating to InsertProfileScreen for new user');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InsertProfileScreen(
            phoneNumber: phoneNumber,
            pendingReferralCode: pendingReferralCode,
          ),
        ),
      );
    } catch (e) {
      print('Error in _handleSuccessfulVerification: $e');
      ErrorUtils.showErrorSnackBar(context, 'Error after verification: ${e.toString()}');
    }
  }

  Future<void> saveProfile({
    required String firstName,
    required String phoneNumber,
    required String email,
    String? lastName,
    String? address,
    required String gender,
    required int? age,
    String? parentChildRelation,
    bool? isParent,
    String? linkingId,
    required bool isNewUser,
    String? referralCode,
  }) async {
    try {
      if (isNewUser) {
        await userModel.registerUser(
          firstName: firstName,
          lastName: lastName ?? '',
          phoneNumber: phoneNumber,
          email: email,
          address: address ?? '',
          gender: gender,
          age: age,
          parentChildRelation: parentChildRelation,
          isParent: isParent,
          linkingId: linkingId,
          referralCode: referralCode,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showWelcomeNotification', true);
        final userExists = await userModel.checkUserExists(phoneNumber);
        if (!userExists) {
          throw Exception('Registration failed. Please try again.');
        }
        ErrorUtils.showSuccessSnackBar(context, 'Profile created successfully!');
      } else {
        await userModel.updateUser(
          firstName: firstName,
          lastName: lastName ?? '',
          phoneNumber: phoneNumber,
          email: email,
          address: address ?? '',
          gender: gender,
          age: age,
          parentChildRelation: parentChildRelation,
          isParent: isParent,
          linkingId: linkingId,
        );
        ErrorUtils.showSuccessSnackBar(context, 'Profile updated successfully!');
      }

      print('Navigating to HomeScreen after saveProfile');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error in saveProfile: $e');
      ErrorUtils.showErrorSnackBar(context, 'Failed to save profile. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      await userModel.logout();
      print('Navigating to LoginScreen after logout');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error in logout: $e');
      ErrorUtils.showErrorSnackBar(context, 'Logout failed. Please try again.');
    }
  }
}