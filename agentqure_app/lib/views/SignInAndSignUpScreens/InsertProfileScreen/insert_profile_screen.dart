// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../controllers/UserController/user_controller.dart';
// import '../../../models/UserModel/user_model.dart';
//
// class InsertProfileScreen extends StatefulWidget {
//   final String phoneNumber;
//
//   const InsertProfileScreen({required this.phoneNumber});
//
//   @override
//   _InsertProfileScreenState createState() => _InsertProfileScreenState();
// }
//
// class _InsertProfileScreenState extends State<InsertProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _referralController = TextEditingController();
//   String? _selectedGender;
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((prefs) {
//       String? pendingCode = prefs.getString('pending_referral_code');
//       if (pendingCode != null && pendingCode.isNotEmpty) {
//         _referralController.text = pendingCode;
//       }
//     });
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.fastOutSlowIn,
//       ),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     _ageController.dispose();
//     _referralController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveProfile() async {
//     if (_isLoading) return;
//     String? referralCode =
//     _referralController.text.trim().isNotEmpty
//         ? _referralController.text.trim()
//         : null;
//     if (_formKey.currentState!.validate() &&
//         _selectedGender != null &&
//         _ageController.text.isNotEmpty) {
//       setState(() => _isLoading = true);
//       final controller = UserController(
//         Provider.of<UserModel>(context, listen: false),
//         context,
//       );
//       try {
//         await controller.saveProfile(
//           firstName: _firstNameController.text.trim(),
//           lastName: _lastNameController.text.trim(),
//           phoneNumber: widget.phoneNumber,
//           email: _emailController.text.trim(),
//           address: _addressController.text.trim(),
//           gender: _selectedGender!,
//           age:
//           _ageController.text.isNotEmpty
//               ? int.tryParse(_ageController.text.trim())
//               : null,
//           isParent: true,
//           isNewUser: true,
//           referralCode: referralCode,
//         );
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('pending_referral_code');
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to create profile: ${e.toString()}')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all fields correctly')),
//       );
//     }
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(Duration(days: 365 * 30)),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Color(0xFF3661E2),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: Color(0xFF3661E2)),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && mounted) {
//       final now = DateTime.now();
//       int age = now.year - picked.year;
//       if (now.month < picked.month ||
//           (now.month == picked.month && now.day < picked.day)) {
//         age--;
//       }
//       setState(() {
//         _ageController.text = age.toString();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Center(
//         child: SingleChildScrollView(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.blue.withOpacity(0.1),
//                                   blurRadius: 12,
//                                   spreadRadius: 4,
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               Icons.person,
//                               size: 80.w,
//                               color: const Color(0xFF3661E2),
//                             ),
//                           ),
//                           SizedBox(height: 24.h),
//                           Text(
//                             "Complete Profile",
//                             style: GoogleFonts.poppins(
//                               fontSize: 28.sp,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF3661E2),
//                             ),
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             "Please fill in your details",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14.sp,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 40.h),
//                       // First Name Input Field
//                       TextFormField(
//                         controller: _firstNameController,
//                         decoration: InputDecoration(
//                           labelText: 'First Name *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.person_outline,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your first name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Last Name Input Field
//                       TextFormField(
//                         controller: _lastNameController,
//                         decoration: InputDecoration(
//                           labelText: 'Last Name',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.person_outline,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) => null,
//                       ),
//                       SizedBox(height: 16.h),
//                       // Email Input Field
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.email_outlined,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Gender Dropdown
//                       DropdownButtonFormField<String>(
//                         dropdownColor: Colors.white,
//                         value: _selectedGender,
//                         decoration: InputDecoration(
//                           labelText: 'Gender *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           hintText: 'Select Gender',
//                           hintStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.transgender,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                         icon: Padding(
//                           padding: EdgeInsets.only(right: 10.w),
//                           child: Icon(
//                             Icons.arrow_drop_down,
//                             color: Color(0xFF3661E2),
//                             size: 24.w,
//                           ),
//                         ),
//                         items:
//                         ['Male', 'Female', 'Other'].map((gender) {
//                           return DropdownMenuItem(
//                             value: gender,
//                             child: Text(
//                               gender,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() => _selectedGender = value);
//                         },
//                         validator: (value) {
//                           if (value == null) {
//                             return 'Please select your gender';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Age Input Field with Date Picker
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _ageController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: 'Age *',
//                                 labelStyle: GoogleFonts.poppins(
//                                   color: Colors.grey[600],
//                                   fontSize: 14.sp,
//                                 ),
//                                 prefixIcon: Container(
//                                   width: 40.w,
//                                   alignment: Alignment.center,
//                                   child: Icon(
//                                     Icons.calendar_today_outlined,
//                                     color: Colors.grey[600],
//                                     size: 20.w,
//                                   ),
//                                 ),
//                                 suffixIcon: Container(width: 40.w),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: BorderSide(
//                                     color: Colors.grey[400]!,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: BorderSide(
//                                     color: Colors.grey[400]!,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF3661E2),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   vertical: 16.h,
//                                 ),
//                                 errorStyle: GoogleFonts.poppins(
//                                   fontSize: 12.sp,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               keyboardType: TextInputType.number,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your age';
//                                 }
//                                 final age = int.tryParse(value);
//                                 if (age == null || age <= 0 || age > 120) {
//                                   return 'Please enter a valid age (1-120)';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           IconButton(
//                             onPressed: _selectDate,
//                             icon: Icon(
//                               Icons.calendar_today,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             tooltip: "Select Date of Birth",
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16.h),
//                       // Address Input Field
//                       TextFormField(
//                         controller: _addressController,
//                         decoration: InputDecoration(
//                           labelText: 'Address *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.location_on_outlined,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.done,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your address';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Referral Code Input Field
//                       TextFormField(
//                         controller: _referralController,
//                         decoration: InputDecoration(
//                           labelText: 'Referral Code (optional)',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.card_giftcard,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         keyboardType: TextInputType.text,
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.done,
//                         validator: null,
//                       ),
//                       SizedBox(height: 24.h),
//                       // Submit Button
//                       Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _saveProfile,
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               disabledBackgroundColor: Colors.grey[400],
//                             ),
//                             child:
//                             _isLoading
//                                 ? SizedBox(
//                               width: 24.w,
//                               height: 24.h,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.white,
//                               ),
//                             )
//                                 : Text(
//                               "CONTINUE",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.2,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       Text(
//                         "Need help? Contact support",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12.sp,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../controllers/UserController/user_controller.dart';
// import '../../../models/UserModel/user_model.dart';
//
// class InsertProfileScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String? pendingReferralCode;
//   const InsertProfileScreen({
//     required this.phoneNumber,
//     this.pendingReferralCode,
//     super.key
//   });
//
//   @override
//   _InsertProfileScreenState createState() => _InsertProfileScreenState();
// }
//
// class _InsertProfileScreenState extends State<InsertProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _referralController = TextEditingController();
//   String? _selectedGender;
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     SharedPreferences.getInstance().then((prefs) {
//       String? pendingCode = prefs.getString('pending_referral_code');
//
//       // Use the passed referral code or the one from SharedPreferences
//       String? codeToUse = widget.pendingReferralCode ?? pendingCode;
//
//       if (codeToUse != null && codeToUse.isNotEmpty) {
//         _referralController.text = codeToUse;
//       }
//     });
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.fastOutSlowIn,
//       ),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     _ageController.dispose();
//     _referralController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveProfile() async {
//     if (_isLoading) return;
//     String? referralCode = _referralController.text.trim().isNotEmpty
//         ? _referralController.text.trim()
//         : null;
//
//     if (_formKey.currentState!.validate() &&
//         _selectedGender != null &&
//         _ageController.text.isNotEmpty) {
//       setState(() => _isLoading = true);
//       final controller = UserController(
//         Provider.of<UserModel>(context, listen: false),
//         context,
//       );
//       try {
//         await controller.saveProfile(
//           firstName: _firstNameController.text.trim(),
//           lastName: _lastNameController.text.trim(),
//           phoneNumber: widget.phoneNumber,
//           email: _emailController.text.trim(),
//           address: _addressController.text.trim(),
//           gender: _selectedGender!,
//           age: _ageController.text.isNotEmpty
//               ? int.tryParse(_ageController.text.trim())
//               : null,
//           isParent: true,
//           isNewUser: true,
//           referralCode: referralCode,
//         );
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('pending_referral_code'); // Remove after use
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to create profile: ${e.toString()}')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all fields correctly')),
//       );
//     }
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(Duration(days: 365 * 30)),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Color(0xFF3661E2),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: Color(0xFF3661E2)),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && mounted) {
//       final now = DateTime.now();
//       int age = now.year - picked.year;
//       if (now.month < picked.month ||
//           (now.month == picked.month && now.day < picked.day)) {
//         age--;
//       }
//       setState(() {
//         _ageController.text = age.toString();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Center(
//         child: SingleChildScrollView(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.blue.withOpacity(0.1),
//                                   blurRadius: 12,
//                                   spreadRadius: 4,
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               Icons.person,
//                               size: 80.w,
//                               color: const Color(0xFF3661E2),
//                             ),
//                           ),
//                           SizedBox(height: 24.h),
//                           Text(
//                             "Complete Profile",
//                             style: GoogleFonts.poppins(
//                               fontSize: 28.sp,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF3661E2),
//                             ),
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             "Please fill in your details",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14.sp,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 40.h),
//                       // First Name Input Field
//                       TextFormField(
//                         controller: _firstNameController,
//                         decoration: InputDecoration(
//                           labelText: 'First Name *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.person_outline,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your first name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Last Name Input Field
//                       TextFormField(
//                         controller: _lastNameController,
//                         decoration: InputDecoration(
//                           labelText: 'Last Name',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.person_outline,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) => null,
//                       ),
//                       SizedBox(height: 16.h),
//                       // Email Input Field
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.email_outlined,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Gender Dropdown
//                       DropdownButtonFormField<String>(
//                         dropdownColor: Colors.white,
//                         value: _selectedGender,
//                         decoration: InputDecoration(
//                           labelText: 'Gender *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           hintText: 'Select Gender',
//                           hintStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.transgender,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                         icon: Padding(
//                           padding: EdgeInsets.only(right: 10.w),
//                           child: Icon(
//                             Icons.arrow_drop_down,
//                             color: Color(0xFF3661E2),
//                             size: 24.w,
//                           ),
//                         ),
//                         items:
//                         ['Male', 'Female', 'Other'].map((gender) {
//                           return DropdownMenuItem(
//                             value: gender,
//                             child: Text(
//                               gender,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() => _selectedGender = value);
//                         },
//                         validator: (value) {
//                           if (value == null) {
//                             return 'Please select your gender';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Age Input Field with Date Picker
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _ageController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 labelText: 'Age *',
//                                 labelStyle: GoogleFonts.poppins(
//                                   color: Colors.grey[600],
//                                   fontSize: 14.sp,
//                                 ),
//                                 prefixIcon: Container(
//                                   width: 40.w,
//                                   alignment: Alignment.center,
//                                   child: Icon(
//                                     Icons.calendar_today_outlined,
//                                     color: Colors.grey[600],
//                                     size: 20.w,
//                                   ),
//                                 ),
//                                 suffixIcon: Container(width: 40.w),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: BorderSide(
//                                     color: Colors.grey[400]!,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: BorderSide(
//                                     color: Colors.grey[400]!,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFF3661E2),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   vertical: 16.h,
//                                 ),
//                                 errorStyle: GoogleFonts.poppins(
//                                   fontSize: 12.sp,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               keyboardType: TextInputType.number,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your age';
//                                 }
//                                 final age = int.tryParse(value);
//                                 if (age == null || age <= 0 || age > 120) {
//                                   return 'Please enter a valid age (1-120)';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           IconButton(
//                             onPressed: _selectDate,
//                             icon: Icon(
//                               Icons.calendar_today,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             tooltip: "Select Date of Birth",
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16.h),
//                       // Address Input Field
//                       TextFormField(
//                         controller: _addressController,
//                         decoration: InputDecoration(
//                           labelText: 'Address *',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.location_on_outlined,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.done,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your address';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Referral Code Input Field
//                       TextFormField(
//                         controller: _referralController,
//                         decoration: InputDecoration(
//                           labelText: 'Referral Code (optional)',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.grey[600],
//                             fontSize: 14.sp,
//                           ),
//                           prefixIcon: Container(
//                             width: 40.w,
//                             alignment: Alignment.center,
//                             child: Icon(
//                               Icons.card_giftcard,
//                               color: Colors.grey[600],
//                               size: 20.w,
//                             ),
//                           ),
//                           suffixIcon: Container(width: 40.w),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: BorderSide(color: Colors.grey[400]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3661E2),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//                           errorStyle: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                         keyboardType: TextInputType.text,
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         textInputAction: TextInputAction.done,
//                         validator: null,
//                       ),
//                       SizedBox(height: 24.h),
//                       // Submit Button
//                       Material(
//                         elevation: 4,
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _saveProfile,
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               disabledBackgroundColor: Colors.grey[400],
//                             ),
//                             child:
//                             _isLoading
//                                 ? SizedBox(
//                               width: 24.w,
//                               height: 24.h,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.white,
//                               ),
//                             )
//                                 : Text(
//                               "CONTINUE",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.2,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       Text(
//                         "Need help? Contact support",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12.sp,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:email_validator/email_validator.dart';
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

class InsertProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String? pendingReferralCode;
  const InsertProfileScreen({
    required this.phoneNumber,
    this.pendingReferralCode,
    super.key,
  });

  @override
  _InsertProfileScreenState createState() => _InsertProfileScreenState();
}

class _InsertProfileScreenState extends State<InsertProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Track error states
  bool _firstNameHasError = false;
  bool _emailHasError = false;
  bool _genderHasError = false;
  bool _ageHasError = false;
  bool _addressHasError = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      String? pendingCode = prefs.getString('pending_referral_code');
      String? codeToUse = widget.pendingReferralCode ?? pendingCode;
      if (codeToUse != null && codeToUse.isNotEmpty) {
        _referralController.text = codeToUse;
      }
    });
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _referralController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Future<void> _saveProfile() async {
  //   if (_isLoading) return;
  //   String? referralCode = _referralController.text.trim().isNotEmpty
  //       ? _referralController.text.trim()
  //       : null;
  //
  //   if (_formKey.currentState!.validate() &&
  //       _selectedGender != null &&
  //       _ageController.text.isNotEmpty) {
  //     setState(() => _isLoading = true);
  //     final controller = UserController(
  //       Provider.of<UserModel>(context, listen: false),
  //       context,
  //     );
  //     try {
  //       await controller.saveProfile(
  //         firstName: _firstNameController.text.trim(),
  //         lastName: _lastNameController.text.trim(),
  //         phoneNumber: widget.phoneNumber,
  //         email: _emailController.text.trim(),
  //         address: _addressController.text.trim(),
  //         gender: _selectedGender!,
  //         age: _ageController.text.isNotEmpty
  //             ? int.tryParse(_ageController.text.trim())
  //             : null,
  //         isParent: true,
  //         isNewUser: true,
  //         referralCode: referralCode,
  //       );
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.remove('pending_referral_code');
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to create profile: ${e.toString()}')),
  //       );
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill all fields correctly')),
  //     );
  //   }
  // }
  Future<void> _saveProfile() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _ageController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      final controller = UserController(
        Provider.of<UserModel>(context, listen: false),
        context,
      );

      try {
        await controller.saveProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: widget.phoneNumber,
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          gender: _selectedGender!,
          age: _ageController.text.isNotEmpty
              ? int.tryParse(_ageController.text.trim())
              : null,
          isParent: true,
          isNewUser: true,
          referralCode: _referralController.text.trim().isNotEmpty
              ? _referralController.text.trim()
              : null,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pending_referral_code');
      } catch (e) {
        ErrorUtils.showErrorSnackBar(
          context,
          'Failed to create profile. Please try again.',
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Registration failed: ${e.toString()}'),
        //     duration: Duration(seconds: 5),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ErrorUtils.showErrorSnackBar(
        context,
        'Please fill all required fields correctly.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Please fill all required fields correctly'),
      //     backgroundColor: Colors.orange,
      //   ),
      // );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3661E2),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF3661E2)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final now = DateTime.now();
      int age = now.year - picked.year;
      if (now.month < picked.month ||
          (now.month == picked.month && now.day < picked.day)) {
        age--;
      }
      setState(() {
        _ageController.text = age.toString();
        _ageHasError = false;
      });
    }
  }

  // Custom input decoration method
  InputDecoration _buildInputDecoration(
    String labelText,
    IconData icon, {
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.poppins(
        color: hasError ? Colors.red : Colors.grey[600],
        fontSize: 14.sp,
      ),
      prefixIcon: Container(
        width: 40.w,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: hasError ? Colors.red : Color(0xFF3661E2),
          size: 20.w,
        ),
      ),
      suffixIcon: Container(width: 40.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Color(0xFF3661E2),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
      // contentPadding: EdgeInsets.symmetric(vertical: 16.h),
      errorStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red),
      floatingLabelStyle: TextStyle(
        color: hasError ? Colors.red : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                  color: Color(
                                    0xFF3661E2,
                                  ).withOpacity(0.1), // Changed to black
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 80.w,
                              color: Color(0xFF3661E2),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            "Complete Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3661E2),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Please fill in your details",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      // First Name Input Field
                      // TextFormField(
                      //   controller: _firstNameController,
                      //   cursorColor: Colors.black,
                      //   decoration: _buildInputDecoration('First Name *', Icons.person_outline, hasError: _firstNameHasError),
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 16.sp,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      //   textInputAction: TextInputAction.next,
                      //   validator: (value) {
                      //     final hasError = value == null || value.isEmpty;
                      //     setState(() => _firstNameHasError = hasError);
                      //     return hasError ? 'Please enter your first name' : null;
                      //   },
                      // ),
                      TextFormField(
                        controller: _firstNameController,
                        cursorColor: FormFieldUtils.cursorColor,
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: 'First Name',
                          icon: Icons.person_outline,
                          hasError: _firstNameHasError,
                        ),
                        style: FormFieldUtils.formTextStyle(),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final hasError = value == null || value.isEmpty;
                          setState(() => _firstNameHasError = hasError);
                          return hasError
                              ? 'Please enter your first name'
                              : null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      // Last Name Input Field
                      TextFormField(
                        controller: _lastNameController,
                        cursorColor: FormFieldUtils.cursorColor,
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: 'Last Name',
                          icon: Icons.person_outline,
                          isOptional: true,
                        ),
                        // style: GoogleFonts.poppins(
                        //   fontSize: 16.sp,
                        //   fontWeight: FontWeight.w600,
                        // ),
                        style: FormFieldUtils.formTextStyle(),
                        textInputAction: TextInputAction.next,
                        validator: (value) => null,
                      ),
                      // TextFormField(
                      //   controller: _lastNameController,
                      //   cursorColor: Colors.black,
                      //   decoration: _buildInputDecoration('Last Name', Icons.person_outline),
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 16.sp,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      //   textInputAction: TextInputAction.next,
                      //   validator: (value) => null,
                      // ),
                      SizedBox(height: 16.h),
                      // Email Input Field
                      TextFormField(
                        controller: _emailController,
                        cursorColor: FormFieldUtils.cursorColor,
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: 'Email',
                          icon: Icons.email_outlined,
                          hasError: _emailHasError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: FormFieldUtils.formTextStyle(),
                        textInputAction: TextInputAction.next,
                        // validator: (value) {
                        //   bool hasError = false;
                        //   if (value == null || value.isEmpty) {
                        //     hasError = true;
                        //   } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        //     hasError = true;
                        //   }
                        //   setState(() => _emailHasError = hasError);
                        //   return hasError ? 'Please enter a valid email' : null;
                        // },
                        validator: (value) {
                          bool hasError = false;
                          if (value == null || value.isEmpty) {
                            hasError = true;
                          } else if (!EmailValidator.validate(value)) {
                            hasError = true;
                          }
                          setState(() => _emailHasError = hasError);
                          return hasError
                              ? 'Please enter a valid email address'
                              : null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: _selectedGender,
                        decoration:
                            FormFieldUtils.buildInputDecoration(
                              labelText: 'Gender',
                              icon: Icons.transgender,
                              hasError: _genderHasError,
                            ).copyWith(
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: _genderHasError
                                      ? Colors.red
                                      : Colors.black,
                                  size: 24.w,
                                ),
                              ),
                            ),
                        style: FormFieldUtils.formTextStyle(),
                        // style: GoogleFonts.poppins(
                        //   fontSize: 16.sp,
                        //   fontWeight: FontWeight.w600,
                        //   color: Colors.black87,
                        // ),
                        items: ['Male', 'Female', 'Other'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(
                              gender,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _genderHasError = false;
                          });
                        },
                        validator: (value) {
                          final hasError = value == null;
                          setState(() => _genderHasError = hasError);
                          return hasError ? 'Please select your gender' : null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      // Age Input Field with Date Picker
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              // cursorColor: Colors.black,
                              cursorColor: FormFieldUtils.cursorColor,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: FormFieldUtils.buildInputDecoration(
                                labelText: 'Age',
                                icon: Icons.calendar_today_outlined,
                                hasError: _ageHasError,
                              ),
                              keyboardType: TextInputType.number,
                              // style: GoogleFonts.poppins(
                              //   fontSize: 16.sp,
                              //   fontWeight: FontWeight.w600,
                              // ),
                              style: FormFieldUtils.formTextStyle(),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                bool hasError = false;
                                if (value == null || value.isEmpty) {
                                  hasError = true;
                                } else {
                                  final age = int.tryParse(value);
                                  hasError =
                                      age == null || age <= 0 || age > 120;
                                }
                                setState(() => _ageHasError = hasError);
                                return hasError
                                    ? 'Please enter a valid age (1-120)'
                                    : null;
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: _selectDate,
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(0xFF3661E2),
                              size: 24.w,
                            ),
                            tooltip: "Select Date of Birth",
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Address Input Field
                      TextFormField(
                        controller: _addressController,
                        // cursorColor: Colors.black,
                        cursorColor: FormFieldUtils.cursorColor,
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: 'Address',
                          icon: Icons.location_on_outlined,
                          hasError: _addressHasError,
                        ),
                        // style: GoogleFonts.poppins(
                        //   fontSize: 16.sp,
                        //   fontWeight: FontWeight.w600,
                        // ),
                        style: FormFieldUtils.formTextStyle(),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          final hasError = value == null || value.isEmpty;
                          setState(() => _addressHasError = hasError);
                          return hasError ? 'Please enter your address' : null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      // Referral Code Input Field
                      TextFormField(
                        controller: _referralController,
                        // cursorColor: Colors.black,
                        cursorColor: FormFieldUtils.cursorColor,
                        decoration: FormFieldUtils.buildInputDecoration(
                          labelText: 'Referral Code',
                          icon: Icons.card_giftcard,
                          isOptional: true,
                        ),

                        keyboardType: TextInputType.text,
                        style: FormFieldUtils.formTextStyle(),
                        // style: GoogleFonts.poppins(
                        //   fontSize: 16.sp,
                        //   fontWeight: FontWeight.w600,
                        // ),
                        textInputAction: TextInputAction.done,
                        validator: null,
                      ),
                      SizedBox(height: 24.h),
                      // Submit Button
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Color(0xFF3661E2),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.grey[400],
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "CONTINUE",
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
}
