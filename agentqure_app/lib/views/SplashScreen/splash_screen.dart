// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/animation.dart';
// import '../../controllers/UserController/user_controller.dart';
// import '../../models/UserModel/user_model.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animations
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1500),
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//
//     _controller.forward();
//
//     // Initialize app
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     controller.initializeApp();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Opacity(
//               opacity: _fadeAnimation.value,
//               child: Transform.scale(
//                 scale: _scaleAnimation.value,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ShaderMask(
//                       shaderCallback:
//                           (bounds) => LinearGradient(
//                         colors: [Color(0xFF3661E2), Color(0xFF5B8AF0)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ).createShader(bounds),
//                       child: Text.rich(
//                         TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "Welcome To ",
//                               style: TextStyle(
//                                 fontSize: 30.sp,
//                                 fontWeight: FontWeight.bold,
//                                 // color: Colors.white,
//                               ),
//                             ),
//                             TextSpan(
//                               text: "AQure",
//                               style: TextStyle(
//                                 fontSize: 36.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 30.h),
//
//                     Hero(
//                       tag: 'splash-logo',
//                       child: Image.asset(
//                         'assets/splash_logo.png',
//                         width: 350.w,
//                         height: 350.h,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//
//                     SizedBox(height: 40.h),
//
//                     SizedBox(
//                       width: 100.w,
//                       height: 4.h,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           backgroundColor: Colors.grey[200],
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Color(0xFF3661E2),
//                           ),
//                           minHeight: 4.h,
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 20.h),
//
//                     Text(
//                       "Initializing your experience...",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       bottomNavigationBar: Container(
//         height: 100.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.white.withOpacity(0.1), Colors.white],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/animation.dart';
// import '../../controllers/UserController/user_controller.dart';
// import '../../models/UserModel/user_model.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animations
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1500),
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//
//     _controller.forward();
//
//     // Initialize app
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     controller.initializeApp();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Opacity(
//               opacity: _fadeAnimation.value,
//               child: Transform.scale(
//                 scale: _scaleAnimation.value,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // ShaderMask(
//                     //   shaderCallback:
//                     //       (bounds) => LinearGradient(
//                     //     colors: [Color(0xFF3661E2), Color(0xFF3661E2)],
//                     //     begin: Alignment.topLeft,
//                     //     end: Alignment.bottomRight,
//                     //   ).createShader(bounds),
//                     //   child: Text.rich(
//                     //     TextSpan(
//                     //       children: [
//                     //         TextSpan(
//                     //           text: "Welcome To ",
//                     //           style: TextStyle(
//                     //             fontSize: 30.sp,
//                     //             fontWeight: FontWeight.bold,
//                     //             // color: Colors.white,
//                     //           ),
//                     //         ),
//                     //         // TextSpan(
//                     //         //   text: "AQure",
//                     //         //   style: TextStyle(
//                     //         //     fontSize: 36.sp,
//                     //         //     fontWeight: FontWeight.bold,
//                     //         //     color: Colors.white,
//                     //         //   ),
//                     //         // ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                     Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Welcome To ",
//                             style: TextStyle(
//                               fontSize: 32.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF3661E2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // SizedBox(height: 5.h),
//                     Hero(
//                       tag: 'splash-logo',
//                       child: Image.asset(
//                         'assets/logo_black_aq.png',
//                         width: 350.w,
//                         // height: 350.h,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//
//                     SizedBox(height: 40.h),
//
//                     SizedBox(
//                       width: 100.w,
//                       height: 4.h,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           backgroundColor: Colors.grey[200],
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Color(0xFF3661E2),
//                           ),
//                           minHeight: 4.h,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       bottomNavigationBar: Container(
//         height: 100.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.white.withOpacity(0.1), Colors.white],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/animation.dart';
// import '../../controllers/UserController/user_controller.dart';
// import '../../models/UserModel/user_model.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animations
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1500),
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//
//     _controller.forward();
//
//     // Initialize app
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     controller.initializeApp();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Opacity(
//               opacity: _fadeAnimation.value,
//               child: Transform.scale(
//                 scale: _scaleAnimation.value,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Welcome To ",
//                             style: TextStyle(
//                               fontSize: 32.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF3661E2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Hero(
//                       tag: 'splash-logo',
//                       child: Image.asset(
//                         'assets/logo_black_aq.png',
//                         width: 350.w,
//                         // height: 350.h,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//
//                     SizedBox(height: 40.h),
//
//                     SizedBox(
//                       width: 100.w,
//                       height: 4.h,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           backgroundColor: Colors.grey[200],
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Color(0xFF3661E2),
//                           ),
//                           minHeight: 4.h,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       bottomNavigationBar: Container(
//         height: 100.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.white.withOpacity(0.1), Colors.white],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/animation.dart';
// import '../../controllers/UserController/user_controller.dart';
// import '../../models/UserModel/user_model.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<Color?> _colorAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animations
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 2000),
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
//     ));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.7,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
//     ));
//
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.3, 0.8, curve: Curves.easeOut),
//     ));
//
//     _colorAnimation = ColorTween(
//       begin: Color(0xFF3661E2).withOpacity(0.5),
//       end: Color(0xFF3661E2),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.5, 1.0, curve: Curves.easeIn),
//     ));
//
//     _controller.forward();
//
//     // Initialize app
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     controller.initializeApp();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Background elements
//           Positioned(
//             top: -50.h,
//             right: -50.w,
//             child: Container(
//               width: 200.w,
//               height: 200.h,
//               decoration: BoxDecoration(
//                 color: Color(0xFF3661E2).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -100.h,
//             left: -100.w,
//             child: Container(
//               width: 250.w,
//               height: 250.h,
//               decoration: BoxDecoration(
//                 color: Color(0xFF3661E2).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//
//           Center(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Welcome text with slide animation
//                     SlideTransition(
//                       position: _slideAnimation,
//                       child: Opacity(
//                         opacity: _fadeAnimation.value,
//                         child: Text.rich(
//                           TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: "Welcome To ",
//                                 style: TextStyle(
//                                   fontSize: 32.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF3661E2),
//                                   letterSpacing: 1.2,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 20.h),
//
//                     // Logo with scale and fade animation
//                     Opacity(
//                       opacity: _fadeAnimation.value,
//                       child: ScaleTransition(
//                         scale: _scaleAnimation,
//                         child: Hero(
//                           tag: 'splash-logo',
//                           child: Image.asset(
//                             'assets/logo_black_aq.png',
//                             width: 350.w,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 60.h),
//
//                     // Animated progress indicator
//                     SizedBox(
//                       width: 120.w,
//                       child: LinearProgressIndicator(
//                         backgroundColor: Colors.grey[200],
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           _colorAnimation.value ?? Color(0xFF3661E2),
//                         ),
//                         minHeight: 4.h,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//
//                     SizedBox(height: 20.h),
//
//                     // Loading text with fade animation
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Text(
//                         "Loading...",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/animation.dart';
// import '../../controllers/UserController/user_controller.dart';
// import '../../models/UserModel/user_model.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<Color?> _colorAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animations
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 2000),
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
//     ));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.7,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
//     ));
//
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.3, 0.8, curve: Curves.easeOut),
//     ));
//
//     _colorAnimation = ColorTween(
//       begin: Color(0xFF3661E2).withOpacity(0.5),
//       end: Color(0xFF3661E2),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Interval(0.5, 1.0, curve: Curves.easeIn),
//     ));
//
//     _controller.forward();
//
//     // Initialize app
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     controller.initializeApp();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Center(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Opacity(
//                       opacity: _fadeAnimation.value,
//                       child: ScaleTransition(
//                         scale: _scaleAnimation,
//                         child: Hero(
//                           tag: 'splash-logo',
//                           child: Image.asset(
//                             'assets/white_logo.png',
//                             width: 350.w,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }