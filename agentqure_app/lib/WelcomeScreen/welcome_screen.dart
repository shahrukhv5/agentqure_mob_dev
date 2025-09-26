// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   final VoidCallback onGetStarted;
//
//   const WelcomeScreen({super.key, required this.onGetStarted});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(24.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo/Icon
//               SizedBox(
//                 width: 200.w,
//                 height: 80.h,
//                 child: Image.asset(
//                   'assets/logo_black_aq.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               SizedBox(height: 40.h),
//
//               // Title
//               Text(
//                 'Welcome to AgentQure',
//                 style: TextStyle(
//                   fontSize: 28.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               SizedBox(height: 16.h),
//
//               // Subtitle
//               Text(
//                 'Your trusted partner for all your business needs. '
//                 'Get started with our comprehensive suite of services.',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   color: Colors.grey.shade600,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               SizedBox(height: 60.h),
//
//               // Get Started Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56.h,
//                 child: ElevatedButton(
//                   onPressed: onGetStarted,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: Text(
//                     'Get Started',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
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
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class WelcomeScreen extends StatefulWidget {
//   final VoidCallback onGetStarted;
//
//   const WelcomeScreen({super.key, required this.onGetStarted});
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final Color primaryColor = const Color(0xFF3661E2);
//   final Color secondaryColor = const Color(0xFF6C8AEC);
//   final Color accentColor = const Color(0xFF4CAF50);
//   late Color lightPrimaryColor;
//
//   final List<DoctorReview> doctorReviews = [
//     DoctorReview(
//       name: 'Dr. Khan',
//       position: 'Chief Medical Officer',
//       review:
//           '"AgentQure helped us streamline patient record management and treatment workflows. Its user-friendly interface improved our efficiency by 40%."',
//       avatarColor: 0xFFFF6B6B,
//     ),
//     DoctorReview(
//       name: 'Dr. Sarah',
//       position: 'Head of Pediatrics',
//       review:
//           '"The analytics feature has transformed how we track patient outcomes. Real-time insights have significantly improved our decision-making process."',
//       avatarColor: 0xFF4ECDC4,
//     ),
//     DoctorReview(
//       name: 'Dr. Michael',
//       position: 'Surgical Director',
//       review:
//           '"The HIPAA compliance gave us peace of mind. AgentQure handles our sensitive data with the highest security standards we\'ve ever seen."',
//       avatarColor: 0xFF45B7D1,
//     ),
//     DoctorReview(
//       name: 'Dr. Emily',
//       position: 'Clinical Research Lead',
//       review:
//           '"Integration was seamless across our 5 healthcare centers. The platform\'s reliability has been exceptional with 99.9% uptime as promised."',
//       avatarColor: 0xFF96CEB4,
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     lightPrimaryColor = primaryColor.withOpacity(0.1);
//
//     // Auto-scroll functionality
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_pageController.hasClients && mounted) {
//         int nextPage = _currentPage + 1;
//         if (nextPage >= doctorReviews.length) {
//           nextPage = 0;
//         }
//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOutQuint,
//         );
//         _startAutoScroll();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Top Section - Logo and Title
//               Column(
//                 children: [
//                   SizedBox(
//                     width: 200.w,
//                     height: 60.h,
//                     child: Image.asset(
//                       'assets/logo_black_aq.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   Text(
//                     'Welcome to AgentQure',
//                     style: TextStyle(
//                       fontSize: 28.sp,
//                       fontWeight: FontWeight.w800,
//                       color: primaryColor,
//                       letterSpacing: 0.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 5.h),
//                   Text(
//                     'Next-Generation Healthcare Management Platform',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//
//               // Middle Section - Features and Stats
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 20.h),
//
//                       // Features Grid
//                       GridView.count(
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         mainAxisSpacing: 10.h,
//                         crossAxisSpacing: 10.w,
//                         childAspectRatio: 1.5,
//                         children: [
//                           _buildFeatureCard(
//                             icon: Icons.security_rounded,
//                             title: 'Enterprise Security',
//                             subtitle: 'HIPAA Compliant',
//                             gradient: [
//                               const Color(0xFF667EEA),
//                               const Color(0xFF764BA2),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.bolt_rounded,
//                             title: 'Lightning Fast',
//                             subtitle: '99.9% Uptime',
//                             gradient: [
//                               const Color(0xFFF093FB),
//                               const Color(0xFFF5576C),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.analytics_rounded,
//                             title: 'Analytics',
//                             subtitle: 'Real-time Insights',
//                             gradient: [
//                               const Color(0xFF4FACFE),
//                               const Color(0xFF00F2FE),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.people_rounded,
//                             title: '10K+',
//                             subtitle: 'Active Users',
//                             gradient: [
//                               const Color(0xFF43E97B),
//                               const Color(0xFF38F9D7),
//                             ],
//                           ),
//                         ],
//                       ),
//
//                       // SizedBox(height: 10.h),
//                       //
//                       // // Statistics Row
//                       // Container(
//                       //   padding: EdgeInsets.all(20.w),
//                       //   decoration: BoxDecoration(
//                       //     gradient: LinearGradient(
//                       //       colors: [
//                       //         lightPrimaryColor.withOpacity(0.5),
//                       //         lightPrimaryColor,
//                       //       ],
//                       //       begin: Alignment.topLeft,
//                       //       end: Alignment.bottomRight,
//                       //     ),
//                       //     borderRadius: BorderRadius.circular(20.r),
//                       //     border: Border.all(
//                       //       color: primaryColor.withOpacity(0.1),
//                       //     ),
//                       //   ),
//                       //   // child: Row(
//                       //   //   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       //   //   children: [
//                       //   //     _buildStatItem(
//                       //   //       '500+',
//                       //   //       'Healthcare\nCenters',
//                       //   //       Icons.medical_services_rounded,
//                       //   //     ),
//                       //   //     Container(
//                       //   //       width: 1.w,
//                       //   //       height: 40.h,
//                       //   //       color: primaryColor.withOpacity(0.2),
//                       //   //     ),
//                       //   //     _buildStatItem(
//                       //   //       '2M+',
//                       //   //       'Patients\nServed',
//                       //   //       Icons.people_alt_rounded,
//                       //   //     ),
//                       //   //   ],
//                       //   // ),
//                       // ),
//
//                       SizedBox(height: 20.h),
//
//                       // Testimonial Carousel
//                       Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.format_quote_rounded,
//                                 color: primaryColor,
//                                 size: 20.r,
//                               ),
//                               SizedBox(width: 8.w),
//                               Text(
//                                 'What Our Doctors Say',
//                                 style: TextStyle(
//                                   fontSize: 18.sp,
//                                   fontWeight: FontWeight.w700,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               Icon(
//                                 Icons.format_quote_rounded,
//                                 color: primaryColor,
//                                 size: 20.r,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20.h),
//                           Container(
//                             height: 180.h,
//                             child: PageView.builder(
//                               controller: _pageController,
//                               itemCount: doctorReviews.length,
//                               onPageChanged: (int page) {
//                                 setState(() {
//                                   _currentPage = page;
//                                 });
//                               },
//                               itemBuilder: (context, index) {
//                                 return AnimatedBuilder(
//                                   animation: _pageController,
//                                   builder: (context, child) {
//                                     double value = 1.0;
//                                     if (_pageController
//                                         .position
//                                         .haveDimensions) {
//                                       value = _pageController.page! - index;
//                                       value = (1 - (value.abs() * 0.3)).clamp(
//                                         0.0,
//                                         1.0,
//                                       );
//                                     }
//                                     return Transform.scale(
//                                       scale: value,
//                                       child: child,
//                                     );
//                                   },
//                                   child: _buildTestimonialCard(
//                                     doctorReviews[index],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 16.h),
//                           // Animated Page Indicators
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(doctorReviews.length, (
//                               index,
//                             ) {
//                               return AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: EdgeInsets.symmetric(horizontal: 4.w),
//                                 width: _currentPage == index ? 24.w : 8.w,
//                                 height: 8.h,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(4.r),
//                                   gradient: _currentPage == index
//                                       ? LinearGradient(
//                                           colors: [
//                                             primaryColor,
//                                             secondaryColor,
//                                           ],
//                                         )
//                                       : null,
//                                   color: _currentPage == index
//                                       ? null
//                                       : primaryColor.withOpacity(0.3),
//                                 ),
//                               );
//                             }),
//                           ),
//                           SizedBox(height: 16.h),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Bottom Section - Get Started Button
//               Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56.h,
//                     child: ElevatedButton(
//                       onPressed: widget.onGetStarted,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16.r),
//                         ),
//                         elevation: 4,
//                         shadowColor: primaryColor.withOpacity(0.5),
//                         animationDuration: const Duration(milliseconds: 300),
//                       ),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Get Started',
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             Icon(Icons.arrow_forward_rounded, size: 20.r),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'Join thousands of healthcare professionals',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required List<Color> gradient,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: gradient,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: gradient.first.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16.r),
//           onTap: () {},
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(12.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(icon, size: 24.r, color: Colors.white),
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white.withOpacity(0.9),
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildStatItem(String value, String label, IconData icon) {
//   //   return Column(
//   //     children: [
//   //       Row(
//   //         mainAxisSize: MainAxisSize.min,
//   //         children: [
//   //           Icon(icon, size: 16.r, color: primaryColor),
//   //           SizedBox(width: 6.w),
//   //           Text(
//   //             value,
//   //             style: TextStyle(
//   //               fontSize: 20.sp,
//   //               fontWeight: FontWeight.w800,
//   //               color: primaryColor,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       SizedBox(height: 4.h),
//   //       Text(
//   //         label,
//   //         style: TextStyle(
//   //           fontSize: 11.sp,
//   //           color: Colors.grey.shade700,
//   //           fontWeight: FontWeight.w500,
//   //           height: 1.3,
//   //         ),
//   //         textAlign: TextAlign.center,
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildTestimonialCard(DoctorReview review) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w),
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, lightPrimaryColor.withOpacity(0.3)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: primaryColor.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40.r,
//                 height: 40.r,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(review.avatarColor),
//                       Color(review.avatarColor).withOpacity(0.7),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     review.name.split(' ')[1].substring(0, 1),
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review.name,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       review.position,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.format_quote_rounded,
//                 color: primaryColor.withOpacity(0.5),
//                 size: 24.r,
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Expanded(
//             child: Text(
//               review.review,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: Colors.grey.shade800,
//                 fontStyle: FontStyle.italic,
//                 height: 1.5,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.start,
//               maxLines: 4,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DoctorReview {
//   final String name;
//   final String position;
//   final String review;
//   final int avatarColor;
//
//   DoctorReview({
//     required this.name,
//     required this.position,
//     required this.review,
//     required this.avatarColor,
//   });
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class WelcomeScreen extends StatefulWidget {
//   final VoidCallback onGetStarted;
//
//   const WelcomeScreen({super.key, required this.onGetStarted});
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final Color primaryColor = const Color(0xFF3661E2);
//   final Color secondaryColor = const Color(0xFF6C8AEC);
//   final Color accentColor = const Color(0xFF4CAF50);
//   late Color lightPrimaryColor;
//
//   final List<DoctorReview> doctorReviews = [
//     DoctorReview(
//       name: 'Dr. Khan',
//       position: 'Chief Medical Officer',
//       review:
//       '"AgentQure helped us streamline patient record management and treatment workflows. Its user-friendly interface improved our efficiency by 40%."',
//       avatarColor: 0xFFFF6B6B,
//     ),
//     DoctorReview(
//       name: 'Dr. Sarah',
//       position: 'Head of Pediatrics',
//       review:
//       '"The analytics feature has transformed how we track patient outcomes. Real-time insights have significantly improved our decision-making process."',
//       avatarColor: 0xFF4ECDC4,
//     ),
//     DoctorReview(
//       name: 'Dr. Michael',
//       position: 'Surgical Director',
//       review:
//       '"The HIPAA compliance gave us peace of mind. AgentQure handles our sensitive data with the highest security standards we\'ve ever seen."',
//       avatarColor: 0xFF45B7D1,
//     ),
//     DoctorReview(
//       name: 'Dr. Emily',
//       position: 'Clinical Research Lead',
//       review:
//       '"Integration was seamless across our 5 healthcare centers. The platform\'s reliability has been exceptional with 99.9% uptime as promised."',
//       avatarColor: 0xFF96CEB4,
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     lightPrimaryColor = primaryColor.withOpacity(0.1);
//
//     // Auto-scroll functionality
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_pageController.hasClients && mounted) {
//         int nextPage = _currentPage + 1;
//         if (nextPage >= doctorReviews.length) {
//           nextPage = 0;
//         }
//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOutQuint,
//         );
//         _startAutoScroll();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Top Section - Logo and Title
//               Column(
//                 children: [
//                   SizedBox(
//                     width: 200.w,
//                     height: 60.h,
//                     child: Image.asset(
//                       'assets/logo_black_aq.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   Text(
//                     'Next-Generation Healthcare Management Platform',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//
//               // Middle Section - Features and Stats
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 20.h),
//
//                       // Features Grid
//                       GridView.count(
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         mainAxisSpacing: 20.h,
//                         crossAxisSpacing: 20.w,
//                         childAspectRatio: 1.1,
//                         children: [
//                           _buildFeatureCard(
//                             icon: Icons.psychology_rounded,
//                             title: 'AI Intelligence',
//                             subtitle: 'Advanced Machine Learning',
//                             gradient: [
//                               const Color(0xFF667EEA),
//                               const Color(0xFF764BA2),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.smart_toy_rounded,
//                             title: 'Smart Automation',
//                             subtitle: 'Intelligent Workflows',
//                             gradient: [
//                               const Color(0xFFF093FB),
//                               const Color(0xFFF5576C),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.security_rounded,
//                             title: 'Data Security',
//                             subtitle: 'Enterprise-Grade Protection',
//                             gradient: [
//                               const Color(0xFF4FACFE),
//                               const Color(0xFF00F2FE),
//                             ],
//                           ),
//                           _buildFeatureCard(
//                             icon: Icons.people_rounded,
//                             title: '10K+',
//                             subtitle: 'Active Users',
//                             gradient: [
//                               const Color(0xFF43E97B),
//                               const Color(0xFF38F9D7),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20.h),
//                       // Testimonial Carousel
//                       Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.format_quote_rounded,
//                                 color: primaryColor,
//                                 size: 20.r,
//                               ),
//                               SizedBox(width: 8.w),
//                               Text(
//                                 'What Our Doctors Say',
//                                 style: TextStyle(
//                                   fontSize: 18.sp,
//                                   fontWeight: FontWeight.w700,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               Icon(
//                                 Icons.format_quote_rounded,
//                                 color: primaryColor,
//                                 size: 20.r,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20.h),
//                           Container(
//                             height: 180.h,
//                             child: PageView.builder(
//                               controller: _pageController,
//                               itemCount: doctorReviews.length,
//                               onPageChanged: (int page) {
//                                 setState(() {
//                                   _currentPage = page;
//                                 });
//                               },
//                               itemBuilder: (context, index) {
//                                 return AnimatedBuilder(
//                                   animation: _pageController,
//                                   builder: (context, child) {
//                                     double value = 1.0;
//                                     if (_pageController
//                                         .position
//                                         .haveDimensions) {
//                                       value = _pageController.page! - index;
//                                       value = (1 - (value.abs() * 0.3)).clamp(
//                                         0.0,
//                                         1.0,
//                                       );
//                                     }
//                                     return Transform.scale(
//                                       scale: value,
//                                       child: child,
//                                     );
//                                   },
//                                   child: _buildTestimonialCard(
//                                     doctorReviews[index],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 16.h),
//                           // Animated Page Indicators
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(doctorReviews.length, (
//                                 index,
//                                 ) {
//                               return AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: EdgeInsets.symmetric(horizontal: 4.w),
//                                 width: _currentPage == index ? 24.w : 8.w,
//                                 height: 8.h,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(4.r),
//                                   gradient: _currentPage == index
//                                       ? LinearGradient(
//                                     colors: [
//                                       primaryColor,
//                                       secondaryColor,
//                                     ],
//                                   )
//                                       : null,
//                                   color: _currentPage == index
//                                       ? null
//                                       : primaryColor.withOpacity(0.3),
//                                 ),
//                               );
//                             }),
//                           ),
//                           SizedBox(height: 16.h),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Bottom Section - Get Started Button
//               Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56.h,
//                     child: ElevatedButton(
//                       onPressed: widget.onGetStarted,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16.r),
//                         ),
//                         elevation: 4,
//                         shadowColor: primaryColor.withOpacity(0.5),
//                         animationDuration: const Duration(milliseconds: 300),
//                       ),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Get Started',
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             Icon(Icons.arrow_forward_rounded, size: 20.r),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'Join thousands of healthcare professionals',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required List<Color> gradient,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF3661E2),
//             const Color(0xFF3661E2).withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF3661E2).withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16.r),
//           onTap: () {},
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(12.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 24.r,
//                     color: Colors.white,
//                     weight: 700,
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white.withOpacity(0.9),
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildTestimonialCard(DoctorReview review) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w),
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF3661E2).withOpacity(0.05), // Very light blue
//             const Color(0xFF3661E2).withOpacity(0.1),  // Slightly darker blue
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: primaryColor.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40.r,
//                 height: 40.r,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(review.avatarColor),
//                       Color(review.avatarColor).withOpacity(0.7),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     review.name.split(' ')[1].substring(0, 1),
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review.name,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       review.position,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.format_quote_rounded,
//                 color: primaryColor.withOpacity(0.5),
//                 size: 24.r,
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Expanded(
//             child: Text(
//               review.review,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: Colors.grey.shade800,
//                 fontStyle: FontStyle.italic,
//                 height: 1.5,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.start,
//               maxLines: 4,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DoctorReview {
//   final String name;
//   final String position;
//   final String review;
//   final int avatarColor;
//
//   DoctorReview({
//     required this.name,
//     required this.position,
//     required this.review,
//     required this.avatarColor,
//   });
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
//
// const Color primaryColor = Color(0xFF3661E2);
// const Color accentColor = Color(0xFF6B7280);
//
// class WelcomeScreen extends StatefulWidget {
//   final Widget nextScreen;
//   final String? pendingReferralCode;
//
//   const WelcomeScreen({
//     super.key,
//     required this.nextScreen,
//     this.pendingReferralCode,
//   });
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _hasSeenWelcome = false;
//
//   final List<Map<String, dynamic>> _features = [
//     {
//       'title': 'AI Intelligence',
//       'description': 'Experience cutting-edge artificial intelligence that learns and adapts to your needs, providing smart solutions.',
//       'image': 'assets/ai_intelligence.png', // You can add these images
//     },
//     {
//       'title': 'Smart Automation',
//       'description': 'Streamline your workflow with intelligent automation that handles repetitive tasks efficiently.',
//       'image': 'assets/smart_automation.png',
//     },
//     {
//       'title': 'Data Security',
//       'description': 'Your data is protected with enterprise-grade security measures ensuring complete privacy.',
//       'image': 'assets/data_security.png',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfWelcomeSeen();
//     _startAutoScroll();
//   }
//
//   Future<void> _checkIfWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
//     setState(() {
//       _hasSeenWelcome = hasSeenWelcome;
//     });
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_pageController.hasClients && mounted) {
//         if (_currentPage < _features.length - 1) {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           _pageController.animateToPage(
//             0,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         }
//         _startAutoScroll();
//       }
//     });
//   }
//
//   Future<void> _setWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenWelcome', true);
//   }
//
//   void _navigateToNextScreen() {
//     _setWelcomeSeen();
//
//     if (widget.nextScreen is LoginScreen) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(
//             pendingReferralCode: widget.pendingReferralCode,
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   void _handleLogin() {
//     // Navigate directly to login
//     _navigateToNextScreen();
//   }
//
//   void _handleGetStarted() {
//     // Navigate to next screen
//     _navigateToNextScreen();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
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
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Main Content
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Feature Image Carousel
//                   Container(
//                     height: 300.h,
//                     child: PageView.builder(
//                       controller: _pageController,
//                       onPageChanged: (index) {
//                         setState(() {
//                           _currentPage = index;
//                         });
//                       },
//                       itemCount: _features.length,
//                       itemBuilder: (context, index) {
//                         final feature = _features[index];
//                         return Column(
//                           children: [
//                             // Feature Image (Placeholder - replace with your images)
//                             Container(
//                               width: 250.w,
//                               height: 200.h,
//                               decoration: BoxDecoration(
//                                 color: primaryColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(20.r),
//                               ),
//                               child: Icon(
//                                 Icons.phone_iphone, // Placeholder icon
//                                 size: 100.w,
//                                 color: primaryColor,
//                               ),
//                             ),
//
//                             SizedBox(height: 40.h),
//
//                             // Dots Indicator
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: List.generate(
//                                 _features.length,
//                                     (index) => AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   margin: EdgeInsets.symmetric(horizontal: 4.w),
//                                   width: _currentPage == index ? 24.w : 8.w,
//                                   height: 8.h,
//                                   decoration: BoxDecoration(
//                                     color: _currentPage == index
//                                         ? primaryColor
//                                         : accentColor.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(4.r),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//
//                   SizedBox(height: 40.h),
//
//                   // Title
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 40.w),
//                     child: Text(
//                       _features[_currentPage]['title'],
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 0.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                   SizedBox(height: 16.h),
//
//                   // Description
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 40.w),
//                     child: Text(
//                       _features[_currentPage]['description'],
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: accentColor,
//                         height: 1.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Bottom Buttons
//             Container(
//               padding: EdgeInsets.all(24.w),
//               child: Column(
//                 children: [
//                   // Get Started Button (Primary)
//                   Container(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _handleGetStarted,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: Text(
//                         'Get started',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
//
// const Color primaryColor = Color(0xFF3661E2);
// const Color accentColor = Color(0xFF6B7280);
//
// class WelcomeScreen extends StatefulWidget {
//   final Widget nextScreen;
//   final String? pendingReferralCode;
//
//   const WelcomeScreen({
//     super.key,
//     required this.nextScreen,
//     this.pendingReferralCode,
//   });
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _hasSeenWelcome = false;
//
//   final List<Map<String, dynamic>> _features = [
//     {
//       'title': 'AI Intelligence',
//       'description': 'Experience cutting-edge artificial intelligence that learns and adapts to your needs, providing smart solutions.',
//       'image': 'assets/ai_intelligence.png',
//     },
//     {
//       'title': 'Smart Automation',
//       'description': 'Streamline your workflow with intelligent automation that handles repetitive tasks efficiently.',
//       'image': 'assets/smart_automation.png',
//     },
//     {
//       'title': 'Data Security',
//       'description': 'Your data is protected with enterprise-grade security measures ensuring complete privacy.',
//       'image': 'assets/data_security.png',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfWelcomeSeen();
//     _startAutoScroll();
//   }
//
//   Future<void> _checkIfWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
//     setState(() {
//       _hasSeenWelcome = hasSeenWelcome;
//     });
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_pageController.hasClients && mounted) {
//         if (_currentPage < _features.length - 1) {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           _pageController.animateToPage(
//             0,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         }
//         _startAutoScroll();
//       }
//     });
//   }
//
//   Future<void> _setWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenWelcome', true);
//   }
//
//   void _navigateToNextScreen() {
//     _setWelcomeSeen();
//
//     if (widget.nextScreen is LoginScreen) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(
//             pendingReferralCode: widget.pendingReferralCode,
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   void _handleLogin() {
//     // Navigate directly to login
//     _navigateToNextScreen();
//   }
//
//   void _handleGetStarted() {
//     // Navigate to next screen
//     _navigateToNextScreen();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
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
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Half-screen clipped background
//           ClipPath(
//             clipper: BottomWaveClipper(),
//             child: Container(
//               height: 500.h, // Approximately half screen based on design size
//               width: double.infinity,
//               color: primaryColor.withOpacity(0.1),
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 // Main Content
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Feature Image Carousel
//                       Container(
//                         height: 300.h,
//                         child: PageView.builder(
//                           controller: _pageController,
//                           onPageChanged: (index) {
//                             setState(() {
//                               _currentPage = index;
//                             });
//                           },
//                           itemCount: _features.length,
//                           itemBuilder: (context, index) {
//                             final feature = _features[index];
//                             return Column(
//                               children: [
//                                 // Feature Image with Custom Clipper Background
//                                 ClipPath(
//                                   clipper: WaveClipper(),
//                                   child: Container(
//                                     width: 250.w,
//                                     height: 200.h,
//                                     decoration: BoxDecoration(
//                                       color: primaryColor.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(20.r),
//                                     ),
//                                     child: Image.asset(
//                                       feature['image'],
//                                       fit: BoxFit.contain, // Adjust fit as needed
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return Icon(
//                                           Icons.phone_iphone, // Fallback to icon if image fails
//                                           size: 100.w,
//                                           color: primaryColor,
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 40.h),
//
//                                 // Dots Indicator
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: List.generate(
//                                     _features.length,
//                                         (index) => AnimatedContainer(
//                                       duration: const Duration(milliseconds: 300),
//                                       margin: EdgeInsets.symmetric(horizontal: 4.w),
//                                       width: _currentPage == index ? 24.w : 8.w,
//                                       height: 8.h,
//                                       decoration: BoxDecoration(
//                                         color: _currentPage == index
//                                             ? primaryColor
//                                             : accentColor.withOpacity(0.3),
//                                         borderRadius: BorderRadius.circular(4.r),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//
//                       SizedBox(height: 40.h),
//
//                       // Title
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 40.w),
//                         child: Text(
//                           _features[_currentPage]['title'],
//                           style: TextStyle(
//                             fontSize: 28.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                             letterSpacing: 0.5,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//
//                       SizedBox(height: 16.h),
//
//                       // Description
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 40.w),
//                         child: Text(
//                           _features[_currentPage]['description'],
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             color: accentColor,
//                             height: 1.5,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Bottom Buttons
//                 Container(
//                   padding: EdgeInsets.all(24.w),
//                   child: Column(
//                     children: [
//                       // Get Started Button (Primary)
//                       Container(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _handleGetStarted,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             elevation: 2,
//                           ),
//                           child: Text(
//                             'Get started',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       // Added Login link for enhancement
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Already have an account? ',
//                             style: TextStyle(
//                               color: accentColor,
//                               fontSize: 14.sp,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: _handleLogin,
//                             child: Text(
//                               'Login',
//                               style: TextStyle(
//                                 color: primaryColor,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Custom Clipper for wavy background enhancement
// class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height);
//     path.quadraticBezierTo(size.width / 4, size.height - 40, size.width / 2, size.height - 20);
//     path.quadraticBezierTo(3 * size.width / 4, size.height, size.width, size.height - 30);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
//
// // New Clipper for half-screen background with bottom wave
// class BottomWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 50.h);
//     path.quadraticBezierTo(
//       size.width / 4,
//       size.height,
//       size.width / 2,
//       size.height - 30.h,
//     );
//     path.quadraticBezierTo(
//       3 * size.width / 4,
//       size.height - 60.h,
//       size.width,
//       size.height - 40.h,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
//
// const Color primaryColor = Color(0xFF3661E2);
// const Color accentColor = Color(0xFF6B7280);
// const Color lightBlueColor = Color(0xFFE0E8FF);
//
// class WelcomeScreen extends StatefulWidget {
//   final Widget nextScreen;
//   final String? pendingReferralCode;
//
//   const WelcomeScreen({
//     super.key,
//     required this.nextScreen,
//     this.pendingReferralCode,
//   });
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _hasSeenWelcome = false;
//
//   final List<Map<String, dynamic>> _features = [
//     {
//       'title': 'AI Intelligence',
//       'description': 'Experience cutting-edge artificial intelligence that learns and adapts to your needs, providing smart solutions.',
//       'image': 'assets/ai_intelligence.png',
//       'icon': Icons.auto_awesome,
//     },
//     {
//       'title': 'Smart Automation',
//       'description': 'Streamline your workflow with intelligent automation that handles repetitive tasks efficiently.',
//       'image': 'assets/smart_automation.png',
//       'icon': Icons.smart_toy,
//     },
//     {
//       'title': 'Data Security',
//       'description': 'Your data is protected with enterprise-grade security measures ensuring complete privacy.',
//       'image': 'assets/data_security.png',
//       'icon': Icons.security,
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfWelcomeSeen();
//     _startAutoScroll();
//   }
//
//   Future<void> _checkIfWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
//     setState(() {
//       _hasSeenWelcome = hasSeenWelcome;
//     });
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_pageController.hasClients && mounted) {
//         if (_currentPage < _features.length - 1) {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           _pageController.animateToPage(
//             0,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         }
//         _startAutoScroll();
//       }
//     });
//   }
//
//   Future<void> _setWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenWelcome', true);
//   }
//
//   void _navigateToNextScreen() {
//     _setWelcomeSeen();
//
//     if (widget.nextScreen is LoginScreen) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(
//             pendingReferralCode: widget.pendingReferralCode,
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   void _handleGetStarted() {
//     _navigateToNextScreen();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
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
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Clipped Background Section (Half Screen)
//             Stack(
//               children: [
//                 // Background Clipper
//                 ClipPath(
//                   clipper: WaveClipper(),
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.5,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           primaryColor.withOpacity(0.8),
//                           lightBlueColor,
//
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Feature Image Carousel
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   child: PageView.builder(
//                     controller: _pageController,
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentPage = index;
//                       });
//                     },
//                     itemCount: _features.length,
//                     itemBuilder: (context, index) {
//                       final feature = _features[index];
//                       return Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Feature Icon Container with Gradient Background
//                           Container(
//                             width: 150.w,
//                             height: 150.h,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   primaryColor.withOpacity(0.8),
//                                   primaryColor.withOpacity(0.4),
//                                 ],
//                               ),
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: primaryColor.withOpacity(0.3),
//                                   blurRadius: 20,
//                                   offset: Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               feature['icon'],
//                               size: 60.w,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             // Dots Indicator (Now placed outside the clipper area)
//             Container(
//               margin: EdgeInsets.only(bottom: 20.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   _features.length,
//                       (index) => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: EdgeInsets.symmetric(horizontal: 4.w),
//                     width: _currentPage == index ? 24.w : 8.w,
//                     height: 8.h,
//                     decoration: BoxDecoration(
//                       color: _currentPage == index
//                           ? primaryColor
//                           : accentColor.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Content Section
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 40.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Title
//                     Text(
//                       _features[_currentPage]['title'],
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 0.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     SizedBox(height: 40.h),
//
//                     // Description
//                     Text(
//                       _features[_currentPage]['description'],
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: accentColor,
//                         height: 1.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     SizedBox(height: 40.h),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Bottom Buttons
//             Container(
//               padding: EdgeInsets.all(24.w),
//               child: Column(
//                 children: [
//                   // Get Started Button (Primary)
//                   Container(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _handleGetStarted,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         elevation: 2,
//                       ),
//                       // child:
//                       // Text(
//                       //   'Get started',
//                       //   style: TextStyle(
//                       //     fontSize: 16.sp,
//                       //     fontWeight: FontWeight.w600,
//                       //   ),
//                       // ),
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Get Started',
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             Icon(Icons.arrow_forward_rounded, size: 20.r),
//                           ],
//                         ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Custom Clipper for Wave-like Background
// class WaveClipper extends CustomClipper<Path> {
//   @override
//   // Path getClip(Size size) {
//   //   var path = Path();
//   //   path.lineTo(0, size.height * 0.7);
//   //
//   //   var firstControlPoint = Offset(size.width * 0.25, size.height * 0.9);
//   //   var firstEndPoint = Offset(size.width * 0.5, size.height * 0.7);
//   //   path.quadraticBezierTo(
//   //     firstControlPoint.dx,
//   //     firstControlPoint.dy,
//   //     firstEndPoint.dx,
//   //     firstEndPoint.dy,
//   //   );
//   //
//   //   var secondControlPoint = Offset(size.width * 0.75, size.height * 0.5);
//   //   var secondEndPoint = Offset(size.width, size.height * 0.7);
//   //   path.quadraticBezierTo(
//   //     secondControlPoint.dx,
//   //     secondControlPoint.dy,
//   //     secondEndPoint.dx,
//   //     secondEndPoint.dy,
//   //   );
//   //
//   //   path.lineTo(size.width, 0);
//   //   path.close();
//   //
//   //   return path;
//   // }
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 50.h);
//     path.quadraticBezierTo(
//       size.width / 4,
//       size.height,
//       size.width / 2,
//       size.height - 30.h,
//     );
//     path.quadraticBezierTo(
//       3 * size.width / 4,
//       size.height - 60.h,
//       size.width,
//       size.height - 40.h,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
//
// const Color primaryColor = Color(0xFF3661E2);
// const Color accentColor = Color(0xFF6B7280);
// const Color lightBlueColor = Color(0xFFE0E8FF);
//
// class WelcomeScreen extends StatefulWidget {
//   final Widget nextScreen;
//   final String? pendingReferralCode;
//
//   const WelcomeScreen({
//     super.key,
//     required this.nextScreen,
//     this.pendingReferralCode,
//   });
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _hasSeenWelcome = false;
//
//   final List<Map<String, dynamic>> _features = [
//     {
//       'title': 'AI Intelligence',
//       'description': 'Experience cutting-edge artificial intelligence that learns and adapts to your needs, providing smart solutions.',
//       'image': 'assets/ai.png',
//     },
//     {
//       'title': 'Smart Automation',
//       'description': 'Streamline your workflow with intelligent automation that handles repetitive tasks efficiently.',
//       'image': 'assets/automation.png',
//     },
//     {
//       'title': 'Data Security',
//       'description': 'Your data is protected with enterprise-grade security measures ensuring complete privacy.',
//       'image': 'assets/security.png',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfWelcomeSeen();
//     _startAutoScroll();
//   }
//
//   Future<void> _checkIfWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
//     setState(() {
//       _hasSeenWelcome = hasSeenWelcome;
//     });
//   }
//
//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_pageController.hasClients && mounted) {
//         if (_currentPage < _features.length - 1) {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           _pageController.animateToPage(
//             0,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         }
//         _startAutoScroll();
//       }
//     });
//   }
//
//   Future<void> _setWelcomeSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenWelcome', true);
//   }
//
//   void _navigateToNextScreen() {
//     _setWelcomeSeen();
//
//     if (widget.nextScreen is LoginScreen) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(
//             pendingReferralCode: widget.pendingReferralCode,
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => widget.nextScreen),
//       );
//     }
//   }
//
//   void _handleGetStarted() {
//     _navigateToNextScreen();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
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
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Clipped Background Section (Half Screen)
//             Stack(
//               children: [
//                 // Background Clipper
//                 ClipPath(
//                   clipper: WaveClipper(),
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.5,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           primaryColor.withOpacity(0.8),
//                           lightBlueColor,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Feature Image Carousel
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   child: PageView.builder(
//                     controller: _pageController,
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentPage = index;
//                       });
//                     },
//                     itemCount: _features.length,
//                     itemBuilder: (context, index) {
//                       final feature = _features[index];
//                       return Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Feature Image Container with Gradient Background
//                           Container(
//                             width: 200.w,
//                             height: 200.h,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   primaryColor.withOpacity(0.8),
//                                   primaryColor.withOpacity(0.4),
//                                 ],
//                               ),
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: primaryColor.withOpacity(0.3),
//                                   blurRadius: 20,
//                                   offset: Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(24.w),
//                               child: ClipOval(
//                                 child: Image.asset(
//                                   feature['image'],
//                                   width: 120.w,
//                                   height: 120.h,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     // Fallback icon if image fails to load
//                                     return Container(
//                                       color: Colors.white.withOpacity(0.2),
//                                       child: Icon(
//                                         Icons.image,
//                                         size: 60.w,
//                                         color: Colors.white,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             // Dots Indicator (Now placed outside the clipper area)
//             Container(
//               margin: EdgeInsets.only(bottom: 20.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   _features.length,
//                       (index) => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: EdgeInsets.symmetric(horizontal: 4.w),
//                     width: _currentPage == index ? 24.w : 8.w,
//                     height: 8.h,
//                     decoration: BoxDecoration(
//                       color: _currentPage == index
//                           ? primaryColor
//                           : accentColor.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Content Section
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 40.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Title
//                     Text(
//                       _features[_currentPage]['title'],
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 0.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     SizedBox(height: 40.h),
//
//                     // Description
//                     Text(
//                       _features[_currentPage]['description'],
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: accentColor,
//                         height: 1.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     SizedBox(height: 40.h),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Bottom Buttons
//             Container(
//               padding: EdgeInsets.all(24.w),
//               child: Column(
//                 children: [
//                   // Get Started Button (Primary)
//                   Container(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _handleGetStarted,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Get Started',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           Icon(Icons.arrow_forward_rounded, size: 20.r),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Custom Clipper for Wave-like Background
// class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 50.h);
//     path.quadraticBezierTo(
//       size.width / 4,
//       size.height,
//       size.width / 2,
//       size.height - 30.h,
//     );
//     path.quadraticBezierTo(
//       3 * size.width / 4,
//       size.height - 60.h,
//       size.width,
//       size.height - 40.h,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
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