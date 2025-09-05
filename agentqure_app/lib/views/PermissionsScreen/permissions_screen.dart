// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// const Color primaryColor = Color(0xFF3661E2);
// const Color accentColor = Color(0xFF6B7280);
//
// class PermissionHandlerScreen extends StatefulWidget {
//   final Widget nextScreen;
//   final String? pendingReferralCode;
//   const PermissionHandlerScreen({super.key, required this.nextScreen,this.pendingReferralCode,});
//
//   @override
//   State<PermissionHandlerScreen> createState() =>
//       _PermissionHandlerScreenState();
// }
//
// class _PermissionHandlerScreenState extends State<PermissionHandlerScreen>
//     with TickerProviderStateMixin {
//   int _currentPage = 0;
//   bool _isLoading = false;
//   final PageController _pageController = PageController();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   final List<Map<String, dynamic>> _permissions = [
//     {
//       'permission': Permission.location,
//       'icon': Icons.location_on,
//       'title': 'Location Access',
//       'description':
//       'Enable location services to provide personalized content based on your area.',
//     },
//     {
//       'permission': Permission.camera,
//       'icon': Icons.camera_alt,
//       'title': 'Camera Access',
//       'description':
//       'Allow camera access to capture photos and videos within the app.',
//     },
//     {
//       'permission': Permission.photos,
//       'icon': Icons.photo_library,
//       'title': 'Photos Access',
//       'description': 'Access your photos to save and retrieve media files.',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );
//     _animationController.forward();
//     _checkIfPermissionsShown();
//   }
//
//   Future<void> _checkIfPermissionsShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasShownPermissions = prefs.getBool('hasShownPermissions') ?? false;
//     if (hasShownPermissions && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   Future<void> _setPermissionsShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasShownPermissions', true);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _requestPermission(int index) async {
//     setState(() => _isLoading = true);
//     final permission = _permissions[index]['permission'] as Permission;
//     final status = await permission.request();
//
//     setState(() => _isLoading = false);
//
//     if (status.isPermanentlyDenied) {
//       _showSettingsDialog();
//     } else {
//       _goToNextPage();
//     }
//   }
//
//   void _goToNextPage() {
//     if (_currentPage < _permissions.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _setPermissionsShown();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   void _showSettingsDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         backgroundColor: Colors.white.withOpacity(0.95),
//         elevation: 8,
//         title: Text(
//           'Permission Required',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20.sp,
//             color: Colors.black87,
//           ),
//         ),
//         content: Text(
//           'This permission is needed for some features. Please enable it in your device settings.',
//           style: TextStyle(fontSize: 16.sp, height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: accentColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16.sp,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             child: Text(
//               'Open Settings',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(
//       context,
//       designSize: const Size(430, 1000),
//       minTextAdapt: true,
//     );
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               primaryColor.withOpacity(0.15),
//               Colors.white,
//               accentColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'App Permissions',
//                           style: TextStyle(
//                             fontSize: 28.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         Text(
//                           '${_currentPage + 1}/${_permissions.length}',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             color: accentColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12.h),
//                     LinearProgressIndicator(
//                       value: (_currentPage + 1) / _permissions.length,
//                       backgroundColor: accentColor.withOpacity(0.2),
//                       valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//                       minHeight: 4.h,
//                       borderRadius: BorderRadius.circular(2.r),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: PageView.builder(
//                     controller: _pageController,
//                     physics: const NeverScrollableScrollPhysics(),
//                     onPageChanged: (index) {
//                       setState(() => _currentPage = index);
//                       _animationController.reset();
//                       _animationController.forward();
//                     },
//                     itemCount: _permissions.length,
//                     itemBuilder:
//                         (context, index) => PermissionPage(
//                       icon: _permissions[index]['icon'],
//                       title: _permissions[index]['title'],
//                       description: _permissions[index]['description'],
//                       isLoading: _isLoading,
//                       onGrant: () => _requestPermission(index),
//                       onSkip: _goToNextPage,
//                       scaleAnimation: _scaleAnimation,
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 16.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     _permissions.length,
//                         (index) => AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       margin: EdgeInsets.symmetric(horizontal: 4.w),
//                       width: _currentPage == index ? 24.w : 8.w,
//                       height: 8.h,
//                       decoration: BoxDecoration(
//                         color:
//                         _currentPage == index
//                             ? primaryColor
//                             : accentColor.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(4.r),
//                         boxShadow: [
//                           if (_currentPage == index)
//                             BoxShadow(
//                               color: primaryColor.withOpacity(0.3),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class PermissionPage extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final bool isLoading;
//   final VoidCallback onGrant;
//   final VoidCallback onSkip;
//   final Animation<double> scaleAnimation;
//
//   const PermissionPage({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.isLoading,
//     required this.onGrant,
//     required this.onSkip,
//     required this.scaleAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//       child: Card(
//         elevation: 8,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24.r),
//         ),
//         color: Colors.white.withOpacity(0.80),
//         child: Padding(
//           padding: EdgeInsets.all(24.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ScaleTransition(
//                 scale: scaleAnimation,
//                 child: Container(
//                   padding: EdgeInsets.all(24.w),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor.withOpacity(0.3),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(icon, size: 96.w, color: primaryColor),
//                 ),
//               ),
//               SizedBox(height: 32.h),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 30.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                   letterSpacing: 0.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   color: accentColor,
//                   height: 1.5,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 48.h),
//               isLoading
//                   ? CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//               )
//                   : Column(
//                 children: [
//                   MouseRegion(
//                     cursor: SystemMouseCursors.click,
//                     child: GestureDetector(
//                       onTap: onGrant,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         transform: Matrix4.identity()..scale(1.0),
//                         transformAlignment: Alignment.center,
//                         child: Container(
//                           width: double.infinity,
//                           height: 56.h,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 primaryColor,
//                                 primaryColor.withOpacity(0.8),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16.r),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: primaryColor.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Allow',
//                               style: TextStyle(
//                                 fontSize: 25.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   TextButton(
//                     onPressed: onSkip,
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 24.w,
//                         vertical: 12.h,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     child: Text(
//                       'Skip',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: accentColor,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SignInAndSignUpScreens/LoginScreen/login_screen.dart';

const Color primaryColor = Color(0xFF3661E2);
const Color accentColor = Color(0xFF6B7280);

class PermissionHandlerScreen extends StatefulWidget {
  final Widget nextScreen;
  final String? pendingReferralCode;

  const PermissionHandlerScreen({
    super.key,
    required this.nextScreen,
    this.pendingReferralCode,
  });

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  bool _isLoading = false;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _permissions = [
    {
      'permission': Permission.location,
      'icon': Icons.location_on,
      'title': 'Location Access',
      'description':
      'Enable location services to provide personalized content based on your area.',
    },
    {
      'permission': Permission.camera,
      'icon': Icons.camera_alt,
      'title': 'Camera Access',
      'description':
      'Allow camera access to capture photos and videos within the app.',
    },
    {
      'permission': Permission.photos,
      'icon': Icons.photo_library,
      'title': 'Photos Access',
      'description': 'Access your photos to save and retrieve media files.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _checkIfPermissionsShown();
  }

  Future<void> _checkIfPermissionsShown() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPermissions = prefs.getBool('hasShownPermissions') ?? false;
    if (hasShownPermissions && mounted) {
      // Pass the referral code to the next screen
      _navigateToNextScreen();
    }
  }

  Future<void> _setPermissionsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownPermissions', true);
  }

  void _navigateToNextScreen() {
    // Check if nextScreen is LoginScreen and pass the referral code
    if (widget.nextScreen is LoginScreen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            pendingReferralCode: widget.pendingReferralCode,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission(int index) async {
    setState(() => _isLoading = true);
    final permission = _permissions[index]['permission'] as Permission;
    final status = await permission.request();

    setState(() => _isLoading = false);

    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    } else {
      _goToNextPage();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _permissions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _setPermissionsShown();
      _navigateToNextScreen();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 8,
        title: Text(
          'Permission Required',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'This permission is needed for some features. Please enable it in your device settings.',
          style: TextStyle(fontSize: 16.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(430, 1000),
      minTextAdapt: true,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.15),
              Colors.white,
              accentColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Permissions',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${_currentPage + 1}/${_permissions.length}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / _permissions.length,
                      backgroundColor: accentColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 4.h,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemCount: _permissions.length,
                    itemBuilder:
                        (context, index) => PermissionPage(
                      icon: _permissions[index]['icon'],
                      title: _permissions[index]['title'],
                      description: _permissions[index]['description'],
                      isLoading: _isLoading,
                      onGrant: () => _requestPermission(index),
                      onSkip: _goToNextPage,
                      scaleAnimation: _scaleAnimation,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _permissions.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color:
                        _currentPage == index
                            ? primaryColor
                            : accentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          if (_currentPage == index)
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onGrant;
  final VoidCallback onSkip;
  final Animation<double> scaleAnimation;

  const PermissionPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onGrant,
    required this.onSkip,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        color: Colors.white.withOpacity(0.80),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 96.w, color: primaryColor),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: accentColor,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              )
                  : Column(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onGrant,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()..scale(1.0),
                        transformAlignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Allow',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}