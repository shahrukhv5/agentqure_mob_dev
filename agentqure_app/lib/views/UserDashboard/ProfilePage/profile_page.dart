// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../../controllers/UserController/user_controller.dart';
// import '../../../models/UserModel/user_model.dart';
// import '../../../utils/CustomBottomNavigationBar/custom_bottom_navigation_bar.dart';
// import '../../../utils/ErrorUtils.dart';
// import '../../../utils/NavigationUtils/navigation_utils.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final String phoneNumber;
//
//   const ProfileScreen({super.key, required this.phoneNumber});
//
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   double? _pointBalance;
//   bool _isEditing = false;
//   bool _isUpdating = false;
//   bool _isLoggingOut = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   Map<String, dynamic>? _userData;
//   int _selectedIndex = 2;
//   bool _isDeleting = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPointBalance();
//     });
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     _userData = userModel.currentUser;
//     if (_userData != null) {
//       _firstNameController.text = _userData!['firstName'] ?? '';
//       _lastNameController.text = _userData!['lastName'] ?? '';
//       _addressController.text = _userData!['address'] ?? '';
//       _ageController.text = _userData?['age']?.toString() ?? '';
//     }
//
//     _refreshUserData();
//
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
//   Future<void> _refreshUserData() async {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     final user = await userModel.getUserByPhone(widget.phoneNumber);
//     if (user != null && mounted) {
//       setState(() {
//         _userData = user;
//         _firstNameController.text = user['firstName'] ?? '';
//         _lastNameController.text = user['lastName'] ?? '';
//         _addressController.text = user['address'] ?? '';
//         _ageController.text = user['age']?.toString() ?? '';
//       });
//     }
//   }
//
//   Future<void> _loadPointBalance() async {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     final userId = userModel.currentUser?['appUserId']?.toString();
//
//     if (userId != null) {
//       setState(() {
//         _pointBalance = null;
//       });
//
//       await userModel.fetchPointBalance(userId);
//
//       if (mounted) {
//         setState(() {
//           _pointBalance = userModel.pointBalance;
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _addressController.dispose();
//     _ageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleEdit() {
//     setState(() => _isEditing = !_isEditing);
//     if (!_isEditing) {
//       _formKey.currentState?.reset();
//       _firstNameController.text = _userData?['firstName'] ?? '';
//       _lastNameController.text = _userData?['lastName'] ?? '';
//       _addressController.text = _userData?['address'] ?? '';
//       _ageController.text = _userData?['age']?.toString() ?? '';
//     }
//   }
//
//   void _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isUpdating = true);
//       final controller = UserController(
//         Provider.of<UserModel>(context, listen: false),
//         context,
//       );
//       try {
//         await controller.saveProfile(
//           firstName: _firstNameController.text.trim(),
//           lastName: _lastNameController.text.trim(),
//           phoneNumber: widget.phoneNumber,
//           email: _userData?['emailId'] ?? '',
//           address: _addressController.text.trim(),
//           gender: _userData?['gender'] ?? '',
//           age:
//           _ageController.text.trim().isNotEmpty
//               ? int.tryParse(_ageController.text.trim())
//               : null,
//           isNewUser: false,
//         );
//         setState(() {
//           _isEditing = false;
//           _isUpdating = false;
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: ${e.toString()}')),
//         );
//         setState(() => _isUpdating = false);
//       }
//     }
//   }
//
//   void _logout() async {
//     setState(() => _isLoggingOut = true);
//     final controller = UserController(
//       Provider.of<UserModel>(context, listen: false),
//       context,
//     );
//     await controller.logout();
//     setState(() => _isLoggingOut = false);
//   }
//   void _deleteAccount() async {
//     final bool? confirm = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             "Delete Account",
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             "Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.",
//             style: GoogleFonts.poppins(),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text(
//                 "CANCEL",
//                 style: GoogleFonts.poppins(color: Colors.grey,fontWeight: FontWeight.bold),
//               ),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text(
//                 "DELETE",
//                 style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm == true) {
//       setState(() => _isDeleting = true);
//
//       try {
//         final userModel = Provider.of<UserModel>(context, listen: false);
//         final userId = userModel.currentUser?['appUserId']?.toString();
//
//         if (userId == null) {
//           throw Exception("User ID not found");
//         }
//
//         // Call the delete API using Dio
//         final dio = Dio();
//         final response = await dio.delete(
//           'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user?id=$userId',
//           options: Options(headers: {'Content-Type': 'application/json'}),
//         );
//
//         if (response.statusCode == 200) {
//           // Account deleted successfully, now logout
//           ErrorUtils.showSuccessSnackBar(context, 'Account deleted successfully');
//
//           final controller = UserController(userModel, context);
//           await controller.logout();
//         } else {
//           throw Exception('Failed to delete account: ${response.statusCode}');
//         }
//       } on DioException catch (e) {
//         final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
//         ErrorUtils.showErrorSnackBar(context, 'Error deleting account: $errorMessage');
//       } catch (e) {
//         ErrorUtils.showErrorSnackBar(context, 'Error deleting account: ${e.toString()}');
//       } finally {
//         if (mounted) {
//           setState(() => _isDeleting = false);
//         }
//       }
//     }
//   }
//   void _onItemTapped(int index) {
//     NavigationUtils.handleNavigation(
//       context,
//       index,
//       _selectedIndex,
//           (newIndex) => setState(() => _selectedIndex = newIndex),
//       Provider.of<UserModel>(context, listen: false),
//     );
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
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             'Profile',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 25.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: const Color(0xFF3661E2),
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildEnhancedWalletCard(),
//                     SizedBox(height: 16.h),
//                     _buildReferralCard(),
//                     Text(
//                       "Manage your profile information",
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     _isEditing
//                         ? Row(
//                       children: [
//                         Expanded(
//                           child: _buildEditableField(
//                             controller: _firstNameController,
//                             label: "First Name *",
//                             icon: Icons.person_outline,
//                             validator:
//                                 (value) =>
//                             value == null || value.isEmpty
//                                 ? "Please enter your first name"
//                                 : null,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: _buildEditableField(
//                             controller: _lastNameController,
//                             label: "Last Name",
//                             icon: Icons.person_outline,
//                             validator: (value) => null,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                       ],
//                     )
//                         : _buildDetailCard(
//                       icon: Icons.person_outline,
//                       label: "Name",
//                       value:
//                       "${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}"
//                           .trim(),
//                     ),
//                     SizedBox(height: 12.h),
//                     // Row(
//                     //   children: [
//                     //     Expanded(
//                     //       child:
//                     //       _isEditing
//                     //           ? Row(
//                     //         children: [
//                     //           Expanded(
//                     //             child: _buildEditableField(
//                     //               controller: _ageController,
//                     //               label: "Age",
//                     //               icon: Icons.cake_outlined,
//                     //               validator: (value) {
//                     //                 if (value != null &&
//                     //                     value.isNotEmpty) {
//                     //                   final age = int.tryParse(value);
//                     //                   if (age == null ||
//                     //                       age <= 0 ||
//                     //                       age > 120) {
//                     //                     return "Please enter a valid age";
//                     //                   }
//                     //                 }
//                     //                 return null;
//                     //               },
//                     //               keyboardType: TextInputType.number,
//                     //               textInputAction: TextInputAction.next,
//                     //               inputFormatters: [
//                     //                 FilteringTextInputFormatter.deny(
//                     //                   RegExp(r'\s'),
//                     //                 ),
//                     //                 FilteringTextInputFormatter
//                     //                     .digitsOnly,
//                     //               ],
//                     //             ),
//                     //           ),
//                     //           SizedBox(width: 8.w),
//                     //           IconButton(
//                     //             onPressed: _selectDate,
//                     //             icon: Icon(
//                     //               Icons.calendar_today,
//                     //               color: Color(0xFF3661E2),
//                     //               size: 24.w,
//                     //             ),
//                     //             tooltip: "Select Date of Birth",
//                     //           ),
//                     //         ],
//                     //       )
//                     //           : _buildDetailCard(
//                     //         icon: Icons.cake_outlined,
//                     //         label: "Age",
//                     //         value:
//                     //         _userData?['age']?.toString() ??
//                     //             'Not provided',
//                     //       ),
//                     //     ),
//                     //     SizedBox(width: 12.w),
//                     //     Expanded(
//                     //       child: _buildDetailCard(
//                     //         icon: Icons.transgender,
//                     //         label: "Gender",
//                     //         value: _userData?['gender'] ?? 'Not specified',
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                     SizedBox(height: 12.h),
//                     _isEditing
//                         ? Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildEditableField(
//                                 controller: _ageController,
//                                 label: "Age",
//                                 icon: Icons.cake_outlined,
//                                 validator: (value) {
//                                   if (value != null && value.isNotEmpty) {
//                                     final age = int.tryParse(value);
//                                     if (age == null || age <= 0 || age > 120) {
//                                       return "Please enter a valid age";
//                                     }
//                                   }
//                                   return null;
//                                 },
//                                 keyboardType: TextInputType.number,
//                                 textInputAction: TextInputAction.next,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             IconButton(
//                               onPressed: _selectDate,
//                               icon: Icon(
//                                 Icons.calendar_today,
//                                 color: Color(0xFF3661E2),
//                                 size: 24.w,
//                               ),
//                               tooltip: "Select Date of Birth",
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 12.h),
//                         _buildDetailCard(
//                           icon: Icons.transgender,
//                           label: "Gender",
//                           value: _userData?['gender'] ?? 'Not specified',
//                         ),
//                       ],
//                     )
//                         : Row(
//                       children: [
//                         Expanded(
//                           child: _buildDetailCard(
//                             icon: Icons.cake_outlined,
//                             label: "Age",
//                             value: _userData?['age']?.toString() ?? 'Not provided',
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: _buildDetailCard(
//                             icon: Icons.transgender,
//                             label: "Gender",
//                             value: _userData?['gender'] ?? 'Not specified',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12.h),
//                     _buildDetailCard(
//                       icon: Icons.phone,
//                       label: "Contact Number",
//                       value: _userData?['contactNumber'] ?? '',
//                     ),
//                     SizedBox(height: 12.h),
//                     _buildDetailCard(
//                       icon: Icons.email_outlined,
//                       label: "Email",
//                       value: _userData?['emailId'] ?? '',
//                     ),
//                     SizedBox(height: 12.h),
//                     _isEditing
//                         ? _buildEditableField(
//                       controller: _addressController,
//                       label: "Address *",
//                       icon: Icons.location_on_outlined,
//                       validator:
//                           (value) =>
//                       value == null || value.isEmpty
//                           ? "Please enter your address"
//                           : null,
//                       textInputAction: TextInputAction.done,
//                       onSubmitted: (_) => _updateProfile(),
//                     )
//                         : _buildDetailCard(
//                       icon: Icons.location_on_outlined,
//                       label: "Address",
//                       value: _userData?['address'] ?? '',
//                     ),
//                     SizedBox(height: 20.h),
//                     Row(
//                       children: [
//                         if (_isEditing) ...[
//                           Expanded(
//                             child: Material(
//                               elevation: 4,
//                               borderRadius: BorderRadius.circular(12.r),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   color: Colors.white,
//                                 ),
//                                 child: OutlinedButton(
//                                   onPressed: _toggleEdit,
//                                   style: OutlinedButton.styleFrom(
//                                     foregroundColor: const Color(0xFF3661E2),
//                                     side: BorderSide(
//                                       color: const Color(0xFF3661E2),
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 16.h,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     backgroundColor: Colors.transparent,
//                                     shadowColor: Colors.transparent,
//                                   ),
//                                   child: Text(
//                                     "CANCEL",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.2,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 16.w),
//                         ],
//                         Expanded(
//                           child: Material(
//                             elevation: 4,
//                             borderRadius: BorderRadius.circular(12.r),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     const Color(0xFF3661E2),
//                                     const Color(0xFF5B8DF1),
//                                   ],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                               ),
//                               child: ElevatedButton(
//                                 onPressed:
//                                 _isUpdating
//                                     ? null
//                                     : (_isEditing
//                                     ? _updateProfile
//                                     : _toggleEdit),
//                                 style: ElevatedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   backgroundColor: Colors.transparent,
//                                   shadowColor: Colors.transparent,
//                                   disabledBackgroundColor: Colors.grey[400],
//                                 ),
//                                 child:
//                                 _isUpdating
//                                     ? SizedBox(
//                                   width: 24.w,
//                                   height: 24.h,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                                     : Text(
//                                   _isEditing
//                                       ? "SAVE CHANGES"
//                                       : "EDIT PROFILE",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.2,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
//                     Material(
//                       elevation: 4,
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: const LinearGradient(
//                             colors: [Colors.red, Color(0xFFF15B5B)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: ElevatedButton(
//                           onPressed: _isLoggingOut ? null : _logout,
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16.h),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             disabledBackgroundColor: Colors.grey[400],
//                           ),
//                           child:
//                           _isLoggingOut
//                               ? SizedBox(
//                             width: 24.w,
//                             height: 24.h,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 3,
//                               color: Colors.white,
//                             ),
//                           )
//                               : Text(
//                             "LOGOUT",
//                             style: GoogleFonts.poppins(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.2,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Material(
//                       elevation: 4,
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           color: Colors.white,
//                           border: Border.all(color: Colors.red, width: 1.5),
//                         ),
//                         child: ElevatedButton(
//                           onPressed: _isDeleting ? null : _deleteAccount,
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16.h),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             disabledBackgroundColor: Colors.grey[300],
//                             foregroundColor: Colors.red,
//                           ),
//                           child: _isDeleting
//                               ? SizedBox(
//                             width: 24.w,
//                             height: 24.h,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 3,
//                               color: Colors.red,
//                             ),
//                           )
//                               : Text(
//                             "DELETE ACCOUNT",
//                             style: GoogleFonts.poppins(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.2,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 24.h),
//                     Text(
//                       "Need help? Contact support",
//                       style: GoogleFonts.poppins(
//                         fontSize: 12.sp,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         userModel: Provider.of<UserModel>(context, listen: false),
//       ),
//     );
//   }
//
//   Widget _buildEnhancedWalletCard() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24.r),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF3661E2), Color(0xFF7DA6FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           stops: [0.1, 0.9],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.2),
//             blurRadius: 15,
//             spreadRadius: 3,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -30.w,
//             top: -30.h,
//             child: Container(
//               width: 120.w,
//               height: 120.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -50.h,
//             left: -20.w,
//             child: Container(
//               width: 100.w,
//               height: 100.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Point Balance",
//                       style: GoogleFonts.poppins(
//                         fontSize: 18.sp,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(8.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.account_balance_wallet_rounded,
//                         color: Colors.white,
//                         size: 24.w,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12.h),
//                 Text(
//                   _pointBalance == null
//                       ? 'Loading...'
//                       : '${_pointBalance!.toStringAsFixed(2)}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 36.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     vertical: 8.h,
//                     horizontal: 12.w,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.bolt, color: Colors.amber, size: 18.w),
//                       SizedBox(width: 8.w),
//                       Text(
//                         "Equivalent to ₹${_pointBalance?.toStringAsFixed(0) ?? '0'}",
//                         style: GoogleFonts.poppins(
//                           fontSize: 14.sp,
//                           color: Colors.white.withOpacity(0.9),
//                         ),
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
//
//   Widget _buildDetailCard({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: const Color(0xFF3661E2), size: 24.w),
//         title: Text(
//           label,
//           style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//         subtitle: Text(
//           value.isEmpty ? 'Not provided' : value,
//           style: GoogleFonts.poppins(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEditableField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//     required TextInputAction textInputAction,
//     TextInputType keyboardType = TextInputType.text,
//     void Function(String)? onSubmitted,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return TextFormField(
//       controller: controller,
//       inputFormatters: inputFormatters,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.poppins(
//           color: Colors.grey[600],
//           fontSize: 14.sp,
//         ),
//         prefixIcon: Container(
//           width: 40.w,
//           alignment: Alignment.center,
//           child: Icon(icon, color: Colors.grey[600], size: 20.w),
//         ),
//         suffixIcon: Container(width: 40.w),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: Colors.grey[400]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: Colors.grey[400]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: const BorderSide(color: Color(0xFF3661E2), width: 2),
//         ),
//         // contentPadding: EdgeInsets.symmetric(vertical: 16.h),
//         errorStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red),
//       ),
//       style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
//       textInputAction: textInputAction,
//       keyboardType: keyboardType,
//       onFieldSubmitted: onSubmitted,
//       validator: validator,
//     );
//   }
//
//   Widget _buildReferralCard() {
//     final String referralCode = _userData?['referralCode'] ?? 'LOADING...';
//     final String referralLink =
//         'https://dev-lab-app.web.app/invite?code=$referralCode';
//     final String shareMessage = '''Join me on this awesome app!
//
// Use my referral code: $referralCode
// or click this link: $referralLink
//
// We both get rewards when you sign up!''';
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             spreadRadius: 5,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//               gradient: LinearGradient(
//                 colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.celebration, color: Colors.white, size: 28.w),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Text(
//                     "Invite Friends & Earn",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF3661E2).withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(
//                       color: Color(0xFF3661E2).withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           color: Color(0xFF3661E2).withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.star,
//                           color: Color(0xFFFFD700),
//                           size: 20.w,
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Earn 50 Points per referral",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             SizedBox(height: 4.h),
//                             Text(
//                               "You and your friend both get rewards",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12.sp,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Text(
//                   "YOUR REFERRAL CODE",
//                   style: GoogleFonts.poppins(
//                     fontSize: 12.sp,
//                     color: Colors.grey[500],
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     vertical: 14.h,
//                     horizontal: 16.w,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF3661E2).withOpacity(0.1),
//                         Color(0xFF5B8DF1).withOpacity(0.1),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(
//                       color: Color(0xFF3661E2).withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           referralCode,
//                           style: GoogleFonts.poppins(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF3661E2),
//                             letterSpacing: 2,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           await Clipboard.setData(
//                             ClipboardData(text: referralCode),
//                           );
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Referral code copied!'),
//                               behavior: SnackBarBehavior.floating,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.all(8.w),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF3661E2),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: Icon(
//                             Icons.copy,
//                             size: 18.w,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   "Share this code with friends when they sign up",
//                   style: GoogleFonts.poppins(
//                     fontSize: 12.sp,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _showShareOptions(shareMessage),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF3661E2),
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       elevation: 2,
//                       shadowColor: Color(0xFF3661E2).withOpacity(0.3),
//                     ),
//                     icon: Icon(Icons.share, color: Colors.white, size: 20.w),
//                     label: Text(
//                       "INVITE FRIENDS",
//                       style: GoogleFonts.poppins(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showShareOptions(String shareMessage) {
//     Share.share(shareMessage, subject: 'App Referral');
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../controllers/UserController/user_controller.dart';
import '../../../models/UserModel/user_model.dart';
import '../../../utils/CustomBottomNavigationBar/custom_bottom_navigation_bar.dart';
import '../../../utils/ErrorUtils.dart';
import '../../../utils/NavigationUtils/navigation_utils.dart';

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;

  const ProfileScreen({super.key, required this.phoneNumber});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  double? _pointBalance;
  bool _isEditing = false;
  bool _isUpdating = false;
  bool _isLoggingOut = false;
  bool _isDeleting = false;
  bool _blockNavigation = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic>? _userData;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPointBalance();
    });
    final userModel = Provider.of<UserModel>(context, listen: false);
    _userData = userModel.currentUser;
    if (_userData != null) {
      _firstNameController.text = _userData!['firstName'] ?? '';
      _lastNameController.text = _userData!['lastName'] ?? '';
      _addressController.text = _userData!['address'] ?? '';
      _ageController.text = _userData?['age']?.toString() ?? '';
    }

    _refreshUserData();

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

  Future<void> _refreshUserData() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final user = await userModel.getUserByPhone(widget.phoneNumber);
    if (user != null && mounted) {
      setState(() {
        _userData = user;
        _firstNameController.text = user['firstName'] ?? '';
        _lastNameController.text = user['lastName'] ?? '';
        _addressController.text = user['address'] ?? '';
        _ageController.text = user['age']?.toString() ?? '';
      });
    }
  }

  Future<void> _loadPointBalance() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final userId = userModel.currentUser?['appUserId']?.toString();

    if (userId != null) {
      setState(() {
        _pointBalance = null;
      });

      await userModel.fetchPointBalance(userId);

      if (mounted) {
        setState(() {
          _pointBalance = userModel.pointBalance;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      _formKey.currentState?.reset();
      _firstNameController.text = _userData?['firstName'] ?? '';
      _lastNameController.text = _userData?['lastName'] ?? '';
      _addressController.text = _userData?['address'] ?? '';
      _ageController.text = _userData?['age']?.toString() ?? '';
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUpdating = true);
      final controller = UserController(
        Provider.of<UserModel>(context, listen: false),
        context,
      );
      try {
        await controller.saveProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: widget.phoneNumber,
          email: _userData?['emailId'] ?? '',
          address: _addressController.text.trim(),
          gender: _userData?['gender'] ?? '',
          age: _ageController.text.trim().isNotEmpty
              ? int.tryParse(_ageController.text.trim())
              : null,
          isNewUser: false,
        );
        setState(() {
          _isEditing = false;
          _isUpdating = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
        setState(() => _isUpdating = false);
      }
    }
  }

  void _logout() async {
    setState(() => _isLoggingOut = true);
    final controller = UserController(
      Provider.of<UserModel>(context, listen: false),
      context,
    );
    await controller.logout();
    setState(() => _isLoggingOut = false);
  }

  void _onItemTapped(int index) {
    if (_blockNavigation) {
      ErrorUtils.showErrorSnackBar(
        context,
        'Please wait while we process your account deletion',
      );
      return;
    }
    NavigationUtils.handleNavigation(
      context,
      index,
      _selectedIndex,
      (newIndex) => setState(() => _selectedIndex = newIndex),
      Provider.of<UserModel>(context, listen: false),
    );
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
      });
    }
  }

  void _deleteAccount() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Delete Account",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
        style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.2)),
        ),
              child: Text(
                "CANCEL",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
              ),
              child: Text(
                "DELETE",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirm == true) {
      // Block navigation
      setState(() {
        _isDeleting = true;
        _blockNavigation = true;
      });

      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Processing", style: GoogleFonts.poppins()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF3661E2)),
                SizedBox(height: 16.h),
                Text(
                  "Deleting your account. Please wait...",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          );
        },
      );

      try {
        final userModel = Provider.of<UserModel>(context, listen: false);
        final userId = userModel.currentUser?['appUserId']?.toString();

        if (userId == null) {
          throw Exception("User ID not found");
        }

        final dio = Dio();
        final response = await dio.delete(
          'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user?id=$userId',
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }

        if (response.statusCode == 200) {
          ErrorUtils.showSuccessSnackBar(
            context,
            'Account deleted successfully',
          );

          final controller = UserController(userModel, context);
          await controller.logout();
        } else {
          throw Exception('Failed to delete account: ${response.statusCode}');
        }
      } on DioException catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
        }

        final errorMessage =
            e.response?.data?['message'] ?? e.message ?? 'Unknown error';
        ErrorUtils.showErrorSnackBar(
          context,
          'Error deleting account: $errorMessage',
        );
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
        }

        ErrorUtils.showErrorSnackBar(
          context,
          'Error deleting account: ${e.toString()}',
        );
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
            _blockNavigation = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_blockNavigation) {
          ErrorUtils.showErrorSnackBar(
            context,
            'Please wait while we process your account deletion',
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF3661E2),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEnhancedWalletCard(),
                          SizedBox(height: 16.h),
                          _buildReferralCard(),
                          Text(
                            "Manage your profile information",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _isEditing
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _buildEditableField(
                                        controller: _firstNameController,
                                        label: "First Name *",
                                        icon: Icons.person_outline,
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                            ? "Please enter your first name"
                                            : null,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _buildEditableField(
                                        controller: _lastNameController,
                                        label: "Last Name",
                                        icon: Icons.person_outline,
                                        validator: (value) => null,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                  ],
                                )
                              : _buildDetailCard(
                                  icon: Icons.person_outline,
                                  label: "Name",
                                  value:
                                      "${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}"
                                          .trim(),
                                ),
                          SizedBox(height: 12.h),
                          _isEditing
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildEditableField(
                                            controller: _ageController,
                                            label: "Age",
                                            icon: Icons.cake_outlined,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                final age = int.tryParse(value);
                                                if (age == null ||
                                                    age <= 0 ||
                                                    age > 120) {
                                                  return "Please enter a valid age";
                                                }
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(
                                                RegExp(r'\s'),
                                              ),
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
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
                                    SizedBox(height: 12.h),
                                    _buildDetailCard(
                                      icon: Icons.transgender,
                                      label: "Gender",
                                      value:
                                          _userData?['gender'] ??
                                          'Not specified',
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _buildDetailCard(
                                        icon: Icons.cake_outlined,
                                        label: "Age",
                                        value:
                                            _userData?['age']?.toString() ??
                                            'Not provided',
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _buildDetailCard(
                                        icon: Icons.transgender,
                                        label: "Gender",
                                        value:
                                            _userData?['gender'] ??
                                            'Not specified',
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: 12.h),
                          _buildDetailCard(
                            icon: Icons.phone,
                            label: "Contact Number",
                            value: _userData?['contactNumber'] ?? '',
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailCard(
                            icon: Icons.email_outlined,
                            label: "Email",
                            value: _userData?['emailId'] ?? '',
                          ),
                          SizedBox(height: 12.h),
                          _isEditing
                              ? _buildEditableField(
                                  controller: _addressController,
                                  label: "Address *",
                                  icon: Icons.location_on_outlined,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? "Please enter your address"
                                      : null,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _updateProfile(),
                                )
                              : _buildDetailCard(
                                  icon: Icons.location_on_outlined,
                                  label: "Address",
                                  value: _userData?['address'] ?? '',
                                ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              if (_isEditing) ...[
                                Expanded(
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: OutlinedButton(
                                        onPressed: _blockNavigation
                                            ? null
                                            : _toggleEdit,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF3661E2,
                                          ),
                                          side: BorderSide(
                                            color: const Color(0xFF3661E2),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          "CANCEL",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            color: Color(0xFF3661E2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                              ],
                              Expanded(
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      gradient: _blockNavigation
                                          ? LinearGradient(
                                              colors: [
                                                Colors.grey,
                                                Colors.grey[400]!,
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                const Color(0xFF3661E2),
                                                const Color(0xFF5B8DF1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _blockNavigation
                                          ? null
                                          : (_isUpdating
                                                ? null
                                                : (_isEditing
                                                      ? _updateProfile
                                                      : _toggleEdit)),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.grey[400],
                                      ),
                                      child: _isUpdating
                                          ? SizedBox(
                                              width: 24.w,
                                              height: 24.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              _isEditing
                                                  ? "SAVE CHANGES"
                                                  : "EDIT PROFILE",
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
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: _blockNavigation
                                    ? LinearGradient(
                                        colors: [
                                          Colors.grey,
                                          Colors.grey[400]!,
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [Colors.red, Color(0xFFF15B5B)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: ElevatedButton(
                                onPressed: _blockNavigation ? null : _logout,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.grey[400],
                                ),
                                child: _isLoggingOut
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "LOGOUT",
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
                          SizedBox(height: 16.h),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: _blockNavigation
                                    ? Colors.grey[300]
                                    : Colors.white,
                                border: Border.all(
                                  color: _blockNavigation
                                      ? Colors.grey
                                      : Colors.red,
                                  width: 1.5,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _blockNavigation
                                    ? null
                                    : _deleteAccount,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.red,
                                ),
                                child: _isDeleting
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Text(
                                        "DELETE ACCOUNT",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: Colors.red,
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
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Blocking overlay during deletion
            if (_blockNavigation)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Processing account deletion...\nPlease wait",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _blockNavigation
            ? null
            : CustomBottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                userModel: Provider.of<UserModel>(context, listen: false),
              ),
      ),
    );
  }

  Widget _buildEnhancedWalletCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF3661E2), Color(0xFF7DA6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.9],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30.w,
            top: -30.h,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -20.w,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Point Balance",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  _pointBalance == null
                      ? 'Loading...'
                      : '${_pointBalance!.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 18.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Equivalent to ₹${_pointBalance?.toStringAsFixed(0) ?? '0'}",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3661E2), size: 24.w),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not provided' : value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required TextInputAction textInputAction,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        prefixIcon: Container(
          width: 40.w,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.grey[600], size: 20.w),
        ),
        suffixIcon: Container(width: 40.w),
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
          borderSide: const BorderSide(color: Color(0xFF3661E2), width: 2),
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red),
      ),
      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      validator: validator,
    );
  }

  Widget _buildReferralCard() {
    final String referralCode = _userData?['referralCode'] ?? 'LOADING...';
    final String referralLink =
        'https://dev-lab-app.web.app/invite?code=$referralCode';
    final String shareMessage =
        '''Join me on this awesome app! 

Use my referral code: $referralCode 
or click this link: $referralLink

We both get rewards when you sign up!''';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              gradient: LinearGradient(
                colors: [Color(0xFF3661E2), Color(0xFF5B8DF1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white, size: 28.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "Invite Friends & Earn",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF3661E2).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Color(0xFF3661E2).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF3661E2).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Earn 50 Points per referral",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "You and your friend both get rewards",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "YOUR REFERRAL CODE",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3661E2).withOpacity(0.1),
                        Color(0xFF5B8DF1).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Color(0xFF3661E2).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralCode,
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3661E2),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: referralCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Referral code copied!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF3661E2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.copy,
                            size: 18.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Share this code with friends when they sign up",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showShareOptions(shareMessage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3661E2),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                      shadowColor: Color(0xFF3661E2).withOpacity(0.3),
                    ),
                    icon: Icon(Icons.share, color: Colors.white, size: 20.w),
                    label: Text(
                      "INVITE FRIENDS",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(String shareMessage) {
    Share.share(shareMessage, subject: 'App Referral');
  }
}
