import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/UserModel/user_model.dart';
import '../../views/PermissionsScreen/permissions_screen.dart';
import '../../views/SignInAndSignUpScreens/InsertProfileScreen/insert_profile_screen.dart';
import '../../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
import '../../views/SignInAndSignUpScreens/OTPScreen/otp_screen.dart';
import '../../views/UserDashboard/HomeScreen/home_screen.dart';

class UserController {
  final UserModel userModel;
  final BuildContext context;

  UserController(this.userModel, this.context);

  void initializeApp() {
    userModel.checkLoginStatus().then((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
            userModel.isLoggedIn
                ? HomeScreen()
                : PermissionHandlerScreen(nextScreen: LoginScreen()),
          ),
        );
      });
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
    await [Permission.storage, Permission.camera].request();

    statuses.forEach((permission, status) {
      print('${permission.toString()}: ${status.toString()}');
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      final response = await userModel.sendOtp('91', phoneNumber);

      if (response['message'] == 'SUCCESS') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: response['data']['verificationId'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void handleLogin(String phoneNumber) {
    if (phoneNumber.length == 10) {
      sendOtp(phoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact number must be 10 digits')),
      );
    }
  }

  Future<void> verifyOtp(
      String otp,
      String phoneNumber,
      String verificationId,
      ) async {
    try {
      final response = await userModel.validateOtp(verificationId, otp);

      if (response['message'] == 'SUCCESS' &&
          response['data']['verificationStatus'] == 'VERIFICATION_COMPLETED') {
        await _handleSuccessfulVerification(phoneNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP validation failed: ${response['message']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _handleSuccessfulVerification(String phoneNumber) async {
    try {
      final userExists = await userModel.checkUserExists(phoneNumber);

      if (userExists) {
        final user = await userModel.getUserByPhone(phoneNumber);
        if (user != null) {
          await userModel.login(phoneNumber);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InsertProfileScreen(phoneNumber: phoneNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error after verification: ${e.toString()}')),
      );
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
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> logout() async {
    await userModel.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}