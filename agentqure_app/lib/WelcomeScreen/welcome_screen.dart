import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF3661E2);
const Color accentColor = Color(0xFF6B7280);
const Color lightBlueColor = Color(0xFFE0E8FF);

class WelcomeScreen extends StatefulWidget {
  final Widget nextScreen;
  final String? pendingReferralCode;

  const WelcomeScreen({
    super.key,
    required this.nextScreen,
    this.pendingReferralCode,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'AI Intelligence',
      'description': 'Experience cutting-edge artificial intelligence that learns and adapts to your needs, providing smart solutions.',
      'image': 'assets/ai.png',
    },
    {
      'title': 'Smart Automation',
      'description': 'Streamline your workflow with intelligent automation that handles repetitive tasks efficiently.',
      'image': 'assets/automation.png',
    },
    {
      'title': 'Data Security',
      'description': 'Your data is protected with enterprise-grade security measures ensuring complete privacy.',
      'image': 'assets/security.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients && mounted) {
        if (_currentPage < _features.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startAutoScroll();
      }
    });
  }

  Future<void> _setWelcomeShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownWelcome', true);
  }

  void _navigateToNextScreen() async {
    await _setWelcomeShown();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.nextScreen,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(430, 1000),
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Clipped Background Section (Half Screen)
            Stack(
              children: [
                // Background Clipper
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          lightBlueColor,
                        ],
                      ),
                    ),
                  ),
                ),

                // Feature Image Carousel
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      final feature = _features[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Feature Image Container with Gradient Background
                          Container(
                            width: 200.w,
                            height: 200.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor.withOpacity(0.8),
                                  primaryColor.withOpacity(0.4),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: ClipOval(
                                child: Image.asset(
                                  feature['image'],
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback icon if image fails to load
                                    return Container(
                                      color: Colors.white.withOpacity(0.2),
                                      child: Icon(
                                        Icons.image,
                                        size: 60.w,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // Dots Indicator
            Container(
              margin: EdgeInsets.only(bottom: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _features.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? primaryColor
                          : accentColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      _features[_currentPage]['title'],
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),

                    // Description
                    Text(
                      _features[_currentPage]['description'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: accentColor,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Get Started Button (Primary)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToNextScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward_rounded, size: 20.r),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for Wave-like Background
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50.h);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 30.h,
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height - 60.h,
      size.width,
      size.height - 40.h,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}