import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/UserController/user_controller.dart';
import '../../../models/UserModel/user_model.dart';
import '../../../utils/ErrorUtils.dart';
import '../../../utils/FormFieldUtils/form_field_utils.dart';
import '../OTPScreen/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? pendingReferralCode;

  const LoginScreen({super.key, this.pendingReferralCode});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  String? _verificationId;
  @override
  void initState() {
    super.initState();
    // Store the referral code if it exists
    if (widget.pendingReferralCode != null) {
      _storeReferralCode(widget.pendingReferralCode!);
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _storeReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_referral_code', code);
  }
  @override
  Widget build(BuildContext context) {
    final controller = UserController(
      Provider.of<UserModel>(context, listen: false),
      context,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/login.png',
                              width: 120.w,
                              height: 120.h,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            "User Verification",
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3661E2),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Enter your phone to continue",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      TextFormField(
                        controller: _phoneController,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: "Phone Number",
                          icon: Icons.phone,
                        ),
                        style: FormFieldUtils.formTextStyle(),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                            return "Enter a valid 10-digit Indian mobile number";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed:
                            _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                _sendOtp(controller);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child:
                            _isLoading
                                ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              "SEND OTP",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      Text(
                        "Need help? Contact support",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp(UserController controller) async {
    setState(() => _isLoading = true);

    try {
      final response = await controller.sendOtp(_phoneController.text);

      if (response['message'] == 'SUCCESS') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: _phoneController.text,
              verificationId: response['data']['verificationId'],
              pendingReferralCode: widget.pendingReferralCode,
            ),
          ),
        );
      } else {
        ErrorUtils.showErrorSnackBar(context, 'Failed to send OTP. Please try again.');
      }
    } catch (e) {
      ErrorUtils.showErrorSnackBar(context, 'Network error. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}