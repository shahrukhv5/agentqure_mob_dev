// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../../controllers/UserController/user_controller.dart';
// import '../../../models/UserModel/user_model.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String verificationId;
//
//   const OtpScreen({
//     required this.phoneNumber,
//     required this.verificationId,
//   });
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
//   final List<TextEditingController> _otpControllers =
//   List.generate(4, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _canResend = false;
//   int _resendCountdown = 30;
//   Timer? _timer;
//   late AnimationController _buttonAnimationController;
//   late Animation<double> _buttonScaleAnimation;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//     _buttonAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(
//         parent: _buttonAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//     _focusNodes[0].requestFocus();
//   }
//
//   void _startResendTimer() {
//     _resendCountdown = 30;
//     _canResend = false;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendCountdown > 0) {
//         setState(() => _resendCountdown--);
//       } else {
//         setState(() => _canResend = true);
//         timer.cancel();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     _timer?.cancel();
//     _buttonAnimationController.dispose();
//     super.dispose();
//   }
//
//   void _verifyOtp() async {
//     final otp = _otpControllers.map((c) => c.text).join();
//     if (otp.length != 4) {
//       setState(() => _errorMessage = 'Please enter complete OTP');
//       return;
//     }
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       await controller.verifyOtp(otp, widget.phoneNumber, widget.verificationId);
//     } catch (e) {
//       setState(() => _errorMessage = e.toString());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.toString(),
//             style: GoogleFonts.poppins(color: Colors.white),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(16.w),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   void _resendOtp() {
//     if (_canResend) {
//       final controller = UserController(
//         Provider.of<UserModel>(context, listen: false),
//         context,
//       );
//       controller.sendOtp(widget.phoneNumber);
//       for (var controller in _otpControllers) {
//         controller.clear();
//       }
//       _focusNodes[0].requestFocus();
//       _startResendTimer();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'OTP resent to ${widget.phoneNumber}',
//             style: GoogleFonts.poppins(color: Colors.white),
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(16.w),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: Text(
//           'OTP Verification',
//           style: GoogleFonts.poppins(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         elevation: 4,
//         shadowColor: Colors.black26,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, size: 24.w, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//           padding: EdgeInsets.all(24.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10.r,
//                 spreadRadius: 2.r,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Enter OTP',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   'We sent a 4-digit code to +91 ${widget.phoneNumber}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14.sp,
//                     color: Colors.grey[600],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (_errorMessage != null) ...[
//                   SizedBox(height: 8.h),
//                   Text(
//                     _errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 12.sp,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//                 SizedBox(height: 32.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(4, (index) => SizedBox(
//                     width: 60.w,
//                     child: TextField(
//                       controller: _otpControllers[index],
//                       focusNode: _focusNodes[index],
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       style: GoogleFonts.poppins(
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide(color: Colors.grey[400]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide(color: Colors.grey[400]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF3661E2),
//                             width: 2,
//                           ),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                       ),
//                       onChanged: (value) {
//                         if (value.length == 1 && index < 3) {
//                           _focusNodes[index + 1].requestFocus();
//                         }
//                         if (value.isEmpty && index > 0) {
//                           _focusNodes[index - 1].requestFocus();
//                         }
//                         if (index == 3 && value.length == 1) {
//                           _verifyOtp();
//                         }
//                       },
//                     ),
//                   )),
//                 ),
//                 SizedBox(height: 24.h),
//                 GestureDetector(
//                   onTapDown: (_) => _buttonAnimationController.forward(),
//                   onTapUp: (_) {
//                     _buttonAnimationController.reverse();
//                     _verifyOtp();
//                   },
//                   onTapCancel: () => _buttonAnimationController.reverse(),
//                   child: ScaleTransition(
//                     scale: _buttonScaleAnimation,
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12.r),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8.r,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: _isLoading
//                             ? SizedBox(
//                           width: 24.w,
//                           height: 24.w,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2.w,
//                           ),
//                         )
//                             : Text(
//                           'Verify OTP',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       _canResend ? 'Resend OTP' : 'Resend OTP in $_resendCountdown s',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: _canResend ? const Color(0xFF3661E2) : Colors.grey[600],
//                         fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
//                       ),
//                     ),
//                     if (_canResend)
//                       Padding(
//                         padding: EdgeInsets.only(left: 8.w),
//                         child: GestureDetector(
//                           onTap: _resendOtp,
//                           child: Icon(
//                             Icons.refresh,
//                             size: 20.w,
//                             color: const Color(0xFF3661E2),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/UserController/user_controller.dart';
import '../../../models/UserModel/user_model.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? pendingReferralCode;
  const OtpScreen({
    required this.phoneNumber,
    required this.verificationId,
    this.pendingReferralCode,
    super.key
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 30;
  Timer? _timer;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _focusNodes[0].requestFocus();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      setState(() => _errorMessage = 'Please enter complete OTP');
      return;
    }
    final controller = UserController(
      Provider.of<UserModel>(context, listen: false),
      context,
    );
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await controller.verifyOtp(
        otp,
        widget.phoneNumber,
        widget.verificationId,
        widget.pendingReferralCode,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resendOtp() {
    if (_canResend) {
      final controller = UserController(
        Provider.of<UserModel>(context, listen: false),
        context,
      );
      controller.sendOtp(widget.phoneNumber);
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to ${widget.phoneNumber}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'OTP Verification',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.r,
                spreadRadius: 2.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'We sent a 4-digit code to +91 ${widget.phoneNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ],
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => SizedBox(
                    width: 60.w,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF3661E2),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 3 && value.length == 1) {
                          _verifyOtp();
                        }
                      },
                    ),
                  )),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTapDown: (_) => _buttonAnimationController.forward(),
                  onTapUp: (_) {
                    _buttonAnimationController.reverse();
                    _verifyOtp();
                  },
                  onTapCancel: () => _buttonAnimationController.reverse(),
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.w,
                          ),
                        )
                            : Text(
                          'Verify OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _canResend ? 'Resend OTP' : 'Resend OTP in $_resendCountdown s',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: _canResend ? const Color(0xFF3661E2) : Colors.grey[600],
                        fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (_canResend)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: GestureDetector(
                          onTap: _resendOtp,
                          child: Icon(
                            Icons.refresh,
                            size: 20.w,
                            color: const Color(0xFF3661E2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}