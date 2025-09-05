// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../../models/UserModel/user_model.dart';
// import '../../models/CartModel/cart_model.dart';
// import '../../services/MemberService/AddMemberForm/add_member_form.dart';
// import '../../services/MemberService/member_service.dart';
// import '../../utils/routes/custom_page_route.dart';
// import '../OrderSuccessPopup/order_success_popup.dart';
// import '../TestListScreen/TestListDetails/test_list_details.dart';
// import 'package:intl/intl.dart';
// import '../UserDashboard/BookingsScreen/bookings_screen.dart';
//
// class CartScreen extends StatelessWidget {
//   final UserModel userModel;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final MemberService _memberService = MemberService(Dio());
//
//   CartScreen({super.key, required this.userModel});
//
//   void _showPatientSelectionDialog(
//       BuildContext context,
//       Map<String, dynamic> item,
//       CartModel cart,
//       ) {
//     final selectedPatients = <String, bool>{};
//     final primaryMember = userModel.currentUser;
//     final children = userModel.children ?? [];
//     final itemId = item['itemId'];
//     final List<String> previouslySelectedPatientIds = List<String>.from(
//       item['selectedPatientIds'] ?? [],
//     );
//
//     if (primaryMember == null && children.isEmpty) {
//       _showAddMemberForm(context);
//       return;
//     }
//
//     if (primaryMember != null) {
//       selectedPatients[primaryMember['appUserId']
//           .toString()] = previouslySelectedPatientIds.contains(
//         primaryMember['appUserId'].toString(),
//       );
//     }
//     for (var child in children) {
//       selectedPatients[child['appUserId'].toString()] =
//           previouslySelectedPatientIds.contains(child['appUserId'].toString());
//     }
//
//     final totalMembers = (primaryMember != null ? 1 : 0) + children.length;
//     final showAddPatientButton = totalMembers < 5;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               elevation: 4,
//               child: Container(
//                 padding: EdgeInsets.all(20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Select Patients",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, size: 24.w),
//                           onPressed: () => Navigator.pop(context),
//                           padding: EdgeInsets.zero,
//                           constraints: BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
//                     Divider(color: Colors.grey[200], height: 1.h),
//                     SizedBox(height: 16.h),
//                     Container(
//                       constraints: BoxConstraints(maxHeight: 300.h),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (primaryMember != null)
//                               _buildPatientTile(
//                                 context,
//                                 "${primaryMember['firstName']} ${primaryMember['lastName'] ?? ''}",
//                                 "(Primary)",
//                                 selectedPatients[primaryMember['appUserId']
//                                     .toString()] ??
//                                     false,
//                                     (value) {
//                                   setState(() {
//                                     selectedPatients[primaryMember['appUserId']
//                                         .toString()] =
//                                         value ?? false;
//                                   });
//                                 },
//                               ),
//                             ...children
//                                 .map(
//                                   (child) => _buildPatientTile(
//                                 context,
//                                 "${child['firstName']} ${child['lastName'] ?? ''}",
//                                 "",
//                                 selectedPatients[child['appUserId']
//                                     .toString()] ??
//                                     false,
//                                     (value) {
//                                   setState(() {
//                                     selectedPatients[child['appUserId']
//                                         .toString()] =
//                                         value ?? false;
//                                   });
//                                 },
//                               ),
//                             )
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     if (showAddPatientButton) ...[
//                       OutlinedButton.icon(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _showAddMemberForm(context);
//                         },
//                         icon: Icon(
//                           Icons.person_add_outlined,
//                           size: 20.w,
//                           color: Color(0xFF3661E2),
//                         ),
//                         label: Text(
//                           "Add Patient",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(vertical: 12.h),
//                           side: BorderSide(color: Color(0xFF3661E2), width: 1),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                     ],
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               cart.removeFromCart(itemId);
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     "${item['name']} removed from cart",
//                                   ),
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: OutlinedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 12.h),
//                               side: BorderSide(color: Colors.red, width: 1),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                             ),
//                             child: Text(
//                               "Remove",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed:
//                             selectedPatients.values.any(
//                                   (selected) => selected,
//                             )
//                                 ? () {
//                               final selectedPatientIds =
//                               selectedPatients.entries
//                                   .where((entry) => entry.value)
//                                   .map((entry) => entry.key)
//                                   .toList();
//                               cart.removeFromCart(itemId);
//                               cart.addToCart({
//                                 ...item,
//                                 'selectedPatientIds':
//                                 selectedPatientIds,
//                                 'quantity': selectedPatientIds.length,
//                               });
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(
//                                 context,
//                               ).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     "Patient selection updated for ${item['name']}",
//                                   ),
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       10.r,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF3661E2),
//                               padding: EdgeInsets.symmetric(vertical: 12.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               "Confirm",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildPatientTile(
//       BuildContext context,
//       String name,
//       String subtitle,
//       bool value,
//       Function(bool?) onChanged,
//       ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       decoration: BoxDecoration(
//         color: value ? Color(0xFF3661E2).withOpacity(0.1) : Colors.grey[50],
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: value ? Color(0xFF3661E2) : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: CheckboxListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
//         title: Text(
//           name,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: value ? Color(0xFF3661E2) : Colors.black,
//           ),
//         ),
//         subtitle:
//         subtitle.isNotEmpty
//             ? Text(
//           subtitle,
//           style: GoogleFonts.poppins(
//             fontSize: 12.sp,
//             color:
//             value
//                 ? Color(0xFF3661E2).withOpacity(0.8)
//                 : Colors.grey,
//           ),
//         )
//             : null,
//         value: value,
//         onChanged: onChanged,
//         activeColor: Color(0xFF3661E2),
//         controlAffinity: ListTileControlAffinity.trailing,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//       ),
//     );
//   }
//
//   void _showAddMemberForm(BuildContext context) {
//     final primaryUser = userModel.currentUser;
//     if (primaryUser == null) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return AddMemberForm(
//           linkingId: primaryUser['appUserId'].toString(),
//           memberService: _memberService,
//           onMemberAdded: (newMember) {
//             // Refresh user data to get the new member
//             userModel.getUserByPhone(primaryUser['contactNumber']);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Member added successfully'),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showAddressSelectionBottomSheet(BuildContext context, CartModel cart) {
//     final primaryUser = userModel.currentUser;
//     final currentAddress = primaryUser?['address'] ?? '';
//     final selectedAddress = cart.selectedAddress ?? currentAddress;
//
//     final addressController = TextEditingController(text: selectedAddress);
//     final _formKey = GlobalKey<FormState>();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24.r),
//               topRight: Radius.circular(24.r),
//             ),
//           ),
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header
//                 Container(
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF3661E2),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24.r),
//                       topRight: Radius.circular(24.r),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Select Address",
//                         style: GoogleFonts.poppins(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           size: 24.w,
//                           color: Colors.white,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints(),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Content
//                 Padding(
//                   padding: EdgeInsets.all(20.w),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Delivery Address",
//                           style: GoogleFonts.poppins(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         Text(
//                           "Enter the address where you'd like your samples to be collected",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 20.h),
//
//                         // Address Input Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: TextFormField(
//                             controller: addressController,
//                             maxLines: 4,
//                             minLines: 3,
//                             decoration: InputDecoration(
//                               hintText: "Enter your complete address...",
//                               hintStyle: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey[500],
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(16.w),
//                               prefixIcon: Icon(
//                                 Icons.location_on,
//                                 color: Color(0xFF3661E2),
//                                 size: 25.w,
//                               ),
//                             ),
//                             style: GoogleFonts.poppins(
//                               fontSize: 14.sp,
//                               color: Colors.black87,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Please enter your address';
//                               }
//                               if (value.trim().length < 4) {
//                                 return 'Please enter a complete address';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//
//                         // Action Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                                   side: BorderSide(
//                                     color: Colors.grey[400]!,
//                                     width: 1.5,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   backgroundColor: Colors.grey[50],
//                                 ),
//                                 child: Text(
//                                   "Cancel",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16.w),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     cart.setSelectedAddress(
//                                       addressController.text.trim(),
//                                     );
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           "Address saved successfully",
//                                           style: GoogleFonts.poppins(),
//                                         ),
//                                         backgroundColor: Color(0xFF3661E2),
//                                         behavior: SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             10.r,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFF3661E2),
//                                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   elevation: 2,
//                                 ),
//                                 child: Text(
//                                   "Save Address",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showTimeSlotSelectionBottomSheet(BuildContext context, CartModel cart) {
//     if (cart.timeSlots.isEmpty) {
//       cart.fetchTimeSlots();
//     }
//
//     // Set today's date as default if not already set
//     if (cart.selectedBookingDate == null) {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       cart.setSelectedBookingDate(today);
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24.r),
//                   topRight: Radius.circular(24.r),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Header
//                     Container(
//                       padding: EdgeInsets.all(20.w),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF3661E2),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(24.r),
//                           topRight: Radius.circular(24.r),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Select Time Slot",
//                             style: GoogleFonts.poppins(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.close,
//                               size: 24.w,
//                               color: Colors.white,
//                             ),
//                             onPressed: () => Navigator.pop(context),
//                             padding: EdgeInsets.zero,
//                             constraints: BoxConstraints(),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Content
//                     Padding(
//                       padding: EdgeInsets.all(20.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Date Picker Section
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(16.r),
//                               border: Border.all(
//                                 color: Colors.grey[200]!,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.calendar_today,
//                                       size: 18.w,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       "Select Date",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 12.h),
//                                 InkWell(
//                                   onTap: () async {
//                                     final selectedDate = await showDatePicker(
//                                       context: context,
//                                       initialDate: DateTime.now(),
//                                       firstDate: DateTime.now(),
//                                       lastDate: DateTime.now().add(
//                                         Duration(days: 30),
//                                       ),
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme: ColorScheme.light(
//                                               primary: Color(0xFF3661E2),
//                                               onPrimary: Colors.white,
//                                               surface: Colors.white,
//                                               onSurface: Colors.black,
//                                             ),
//                                             dialogBackgroundColor: Colors.white,
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                     );
//
//                                     if (selectedDate != null) {
//                                       final formattedDate = DateFormat(
//                                         'yyyy-MM-dd',
//                                       ).format(selectedDate);
//                                       cart.setSelectedBookingDate(
//                                         formattedDate,
//                                       );
//                                       setState(() {});
//                                     }
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.all(16.w),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: Color(
//                                           0xFF3661E2,
//                                         ).withOpacity(0.3),
//                                         width: 1.5,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.1),
//                                           blurRadius: 6,
//                                           offset: Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Selected Date",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 12.sp,
//                                                   color: Colors.grey[600],
//                                                 ),
//                                               ),
//                                               SizedBox(height: 4.h),
//                                               Text(
//                                                 _formatDisplayDate(
//                                                   cart.selectedBookingDate,
//                                                 ),
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 16.sp,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Color(0xFF3661E2),
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           padding: EdgeInsets.all(8.w),
//                                           decoration: BoxDecoration(
//                                             color: Color(
//                                               0xFF3661E2,
//                                             ).withOpacity(0.1),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Icon(
//                                             Icons.edit,
//                                             size: 18.w,
//                                             color: Color(0xFF3661E2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20.h),
//
//                           // Time Slots Section
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(16.r),
//                               border: Border.all(
//                                 color: Colors.grey[200]!,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.access_time,
//                                       size: 18.w,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       "Available Time Slots",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     if (cart.isLoadingTimeSlots)
//                                       SizedBox(
//                                         width: 16.w,
//                                         height: 16.w,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Color(0xFF3661E2),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 12.h),
//
//                                 if (cart.isLoadingTimeSlots)
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 40.h,
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         CircularProgressIndicator(
//                                           color: Color(0xFF3661E2),
//                                           strokeWidth: 3,
//                                         ),
//                                         SizedBox(height: 16.h),
//                                         Text(
//                                           "Loading available slots...",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 else if (cart.timeSlots.isEmpty)
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 40.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: Colors.grey[200]!,
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.schedule,
//                                           size: 48.w,
//                                           color: Colors.grey[400],
//                                         ),
//                                         SizedBox(height: 12.h),
//                                         Text(
//                                           "No time slots available",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 16.sp,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         SizedBox(height: 8.h),
//                                         Text(
//                                           "Please try another date",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             color: Colors.grey[500],
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 else
//                                   Container(
//                                     constraints: BoxConstraints(
//                                       maxHeight: 200.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: Colors.grey[200]!,
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                     child: ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: BouncingScrollPhysics(),
//                                       itemCount: cart.timeSlots.length,
//                                       itemBuilder: (context, index) {
//                                         final slot = cart.timeSlots[index];
//                                         final isSelected =
//                                             cart.selectedTimeSlot ==
//                                                 slot['slotName'];
//                                         final isAvailable =
//                                             slot['available'] != false;
//
//                                         return InkWell(
//                                           onTap:
//                                           isAvailable
//                                               ? () {
//                                             cart.setSelectedTimeSlot(
//                                               slot['slotName']!,
//                                             );
//                                             setState(() {});
//                                           }
//                                               : null,
//                                           child: Container(
//                                             padding: EdgeInsets.all(16.w),
//                                             decoration: BoxDecoration(
//                                               color:
//                                               isSelected
//                                                   ? Color(
//                                                 0xFF3661E2,
//                                               ).withOpacity(0.1)
//                                                   : Colors.white,
//                                               border: Border(
//                                                 bottom:
//                                                 index <
//                                                     cart
//                                                         .timeSlots
//                                                         .length -
//                                                         1
//                                                     ? BorderSide(
//                                                   color:
//                                                   Colors.grey[100]!,
//                                                   width: 1,
//                                                 )
//                                                     : BorderSide.none,
//                                               ),
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 // Selection Indicator
//                                                 Container(
//                                                   width: 22.w,
//                                                   height: 22.w,
//                                                   decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                       color:
//                                                       isSelected
//                                                           ? Color(
//                                                         0xFF3661E2,
//                                                       )
//                                                           : isAvailable
//                                                           ? Colors
//                                                           .grey[400]!
//                                                           : Colors
//                                                           .grey[300]!,
//                                                       width: 2,
//                                                     ),
//                                                     color:
//                                                     isSelected
//                                                         ? Color(0xFF3661E2)
//                                                         : Colors
//                                                         .transparent,
//                                                   ),
//                                                   child:
//                                                   isSelected
//                                                       ? Icon(
//                                                     Icons.check,
//                                                     size: 14.w,
//                                                     color: Colors.white,
//                                                   )
//                                                       : null,
//                                                 ),
//                                                 SizedBox(width: 16.w),
//
//                                                 // Slot Info
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                     CrossAxisAlignment
//                                                         .start,
//                                                     children: [
//                                                       Text(
//                                                         slot['slotName'] ??
//                                                             'Unknown Slot',
//                                                         style: GoogleFonts.poppins(
//                                                           fontSize: 15.sp,
//                                                           fontWeight:
//                                                           FontWeight.w500,
//                                                           color:
//                                                           isSelected
//                                                               ? Color(
//                                                             0xFF3661E2,
//                                                           )
//                                                               : isAvailable
//                                                               ? Colors
//                                                               .black87
//                                                               : Colors
//                                                               .grey[400]!,
//                                                         ),
//                                                       ),
//                                                       if (slot['timing'] !=
//                                                           null)
//                                                         Text(
//                                                           slot['timing'],
//                                                           style: GoogleFonts.poppins(
//                                                             fontSize: 12.sp,
//                                                             color:
//                                                             isAvailable
//                                                                 ? Colors
//                                                                 .grey[600]
//                                                                 : Colors
//                                                                 .grey[400],
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ),
//
//                                                 // Availability Status
//                                                 if (!isAvailable)
//                                                   Container(
//                                                     padding:
//                                                     EdgeInsets.symmetric(
//                                                       horizontal: 10.w,
//                                                       vertical: 6.h,
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.red
//                                                           .withOpacity(0.1),
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                         6.r,
//                                                       ),
//                                                       border: Border.all(
//                                                         color: Colors.red
//                                                             .withOpacity(0.3),
//                                                         width: 1,
//                                                       ),
//                                                     ),
//                                                     child: Text(
//                                                       "Full",
//                                                       style:
//                                                       GoogleFonts.poppins(
//                                                         fontSize: 11.sp,
//                                                         color: Colors.red,
//                                                         fontWeight:
//                                                         FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20.h),
//
//                           // Selected Info Banner
//                           if (cart.selectedTimeSlot != null &&
//                               cart.selectedBookingDate != null)
//                             Container(
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF3661E2).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 border: Border.all(
//                                   color: Color(0xFF3661E2).withOpacity(0.2),
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.check_circle,
//                                     size: 20.w,
//                                     color: Color(0xFF3661E2),
//                                   ),
//                                   SizedBox(width: 12.w),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Selected Time Slot",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12.sp,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             fontWeight: FontWeight.w600,
//                                             color: Color(0xFF3661E2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           SizedBox(height: 24.h),
//
//                           // Action Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 16.h,
//                                     ),
//                                     side: BorderSide(
//                                       color: Colors.grey[400]!,
//                                       width: 1.5,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     backgroundColor: Colors.grey[50],
//                                   ),
//                                   child: Text(
//                                     "Cancel",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.grey[700],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 16.w),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed:
//                                   cart.selectedTimeSlot != null &&
//                                       cart.selectedBookingDate != null
//                                       ? () {
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(
//                                       context,
//                                     ).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           "Time slot selected successfully",
//                                           style: GoogleFonts.poppins(),
//                                         ),
//                                         behavior:
//                                         SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                             10.r,
//                                           ),
//                                         ),
//                                         backgroundColor: Color(
//                                           0xFF3661E2,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                       : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF3661E2),
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 16.h,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     elevation: 2,
//                                   ),
//                                   child: Text(
//                                     "Confirm Slot",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   String _formatDisplayDate(String? dateString) {
//     if (dateString == null) return "Select a date";
//
//     try {
//       final date = DateFormat('yyyy-MM-dd').parse(dateString);
//       final today = DateTime.now();
//       final tomorrow = today.add(Duration(days: 1));
//
//       if (date.year == today.year &&
//           date.month == today.month &&
//           date.day == today.day) {
//         return "Today, ${DateFormat('MMM dd, yyyy').format(date)}";
//       } else if (date.year == tomorrow.year &&
//           date.month == tomorrow.month &&
//           date.day == tomorrow.day) {
//         return "Tomorrow, ${DateFormat('MMM dd, yyyy').format(date)}";
//       } else {
//         return DateFormat('EEE, MMM dd, yyyy').format(date);
//       }
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ScrollController _scrollController = ScrollController();
//     final GlobalKey _walletSummaryKey = GlobalKey();
//     final GlobalKey _orderSummaryKey = GlobalKey();
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.grey[200],
//         title: Text(
//           "Cart",
//           style: GoogleFonts.poppins(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF3661E2),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
//       ),
//       body: Consumer<CartModel>(
//         builder: (context, cart, child) {
//           if (cart.items.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_cart_outlined,
//                     size: 80.w,
//                     color: Colors.grey[400],
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "Your Cart is Empty",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     "Add some tests to get started",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14.sp,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF3661E2),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 24.w,
//                         vertical: 12.h,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     child: Text(
//                       "Browse Tests",
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final isWalletEnabled =
//               cart.items.isNotEmpty &&
//                   cart.items.first['isWalletEnabled'] == true;
//           final walletAmount = isWalletEnabled ? cart.walletAmount : 0.0;
//           final walletDiscount =
//           isWalletEnabled && walletAmount > 0
//               ? cart.totalPrice * (cart.walletDiscountPercentage / 100)
//               : 0.0;
//           final payableAmount = cart.totalPrice - walletDiscount;
//           final walletAmountAfterDeduction =
//           isWalletEnabled ? walletAmount - walletDiscount : 0.0;
//           final hasSufficientBalance =
//               !isWalletEnabled || walletAmountAfterDeduction >= 0;
//           return Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   controller: _scrollController,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 16.h,
//                   ),
//                   children: [
//                     ...List.generate(cart.items.length, (index) {
//                       final item = cart.items[index];
//                       final itemId = item['itemId'];
//                       final quantity = item['quantity'] as int;
//                       final discountPrice = item["discountPrice"] as double;
//                       final originalPrice = item["originalPrice"] as double;
//                       final discountPercentage =
//                       ((originalPrice - discountPrice) /
//                           originalPrice *
//                           100)
//                           .round();
//                       final totalItemPrice = discountPrice * quantity;
//                       final selectedPatientCount =
//                           (item['selectedPatientIds'] as List?)?.length ?? 0;
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             CustomPageRoute(
//                               child: TestListDetails(
//                                 test: item,
//                                 provider: item["provider"],
//                                 service: item["service"],
//                                 userModel: userModel,
//                               ),
//                               direction: AxisDirection.right,
//                             ),
//                           );
//                         },
//                         child: Card(
//                           elevation: 4,
//                           margin: EdgeInsets.only(bottom: 12.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16.r),
//                               color: Colors.white,
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Flexible(
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.all(8.w),
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey.shade300,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Icon(
//                                               Icons.science,
//                                               color: Color(0xFF3661E2),
//                                               size: 25.w,
//                                             ),
//                                           ),
//                                           SizedBox(width: 12.w),
//                                           Flexible(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   item["name"],
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 18.sp,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Color(0xFF3661E2),
//                                                   ),
//                                                   maxLines: 1,
//                                                   overflow:
//                                                   TextOverflow.ellipsis,
//                                                 ),
//                                                 SizedBox(height: 4.h),
//                                                 Text(
//                                                   "Provider: ${item['provider']}",
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 14.sp,
//                                                     color: Colors.black,
//                                                   ),
//                                                   maxLines: 1,
//                                                   overflow:
//                                                   TextOverflow.ellipsis,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed:
//                                           () => _showPatientSelectionDialog(
//                                         context,
//                                         item,
//                                         cart,
//                                       ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                         selectedPatientCount > 0
//                                             ? Colors.white
//                                             : Color(0xFF3661E2),
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 24.w,
//                                           vertical: 12.h,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8.r,
//                                           ),
//                                           side:
//                                           selectedPatientCount > 0
//                                               ? BorderSide(
//                                             color: Color(0xFF3661E2),
//                                             width: 1,
//                                           )
//                                               : BorderSide.none,
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: Text(
//                                         selectedPatientCount > 0
//                                             ? "$selectedPatientCount Patient${selectedPatientCount == 1 ? '' : 's'}"
//                                             : "Select Patients",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w600,
//                                           color:
//                                           selectedPatientCount > 0
//                                               ? Color(0xFF3661E2)
//                                               : Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Flexible(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Price per patient: ₹${discountPrice.toStringAsFixed(0)}",
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 "₹${originalPrice.toStringAsFixed(0)}",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 14.sp,
//                                                   color: Colors.grey,
//                                                   decoration:
//                                                   TextDecoration
//                                                       .lineThrough,
//                                                 ),
//                                               ),
//                                               SizedBox(width: 8.w),
//                                               Text(
//                                                 "${discountPercentage.toStringAsFixed(0)}% OFF",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 14.sp,
//                                                   color: Color(0xFF3661E2),
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Text(
//                                             "Total for $selectedPatientCount patient${selectedPatientCount == 1 ? '' : 's'}: ₹${totalItemPrice.toStringAsFixed(0)}",
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                     SizedBox(height: 16.h),
//                     Card(
//                       key: _walletSummaryKey,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Wallet Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             _buildAmountRow(
//                               "Wallet Balance",
//                               "₹${walletAmount.toStringAsFixed(0)}",
//                               Colors.black87,
//                             ),
//
//                             // Only show these if wallet has balance
//                             if (walletAmount > 0) ...[
//                               SizedBox(height: 8.h),
//
//                               // Wallet Points Utilised WITH TOOLTIP
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Wallet Points Utilised",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       _buildInfoTooltip(
//                                         "Amount of wallet points being used from your ${_getOrganizationName(cart)} balance for this order",
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     "₹${walletDiscount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               SizedBox(height: 8.h),
//                               _buildAmountRow(
//                                 "Remaining Wallet Balance",
//                                 "₹${walletAmountAfterDeduction.toStringAsFixed(0)}",
//                                 hasSufficientBalance
//                                     ? Colors.black87
//                                     : Colors.red,
//                                 isBold: true,
//                               ),
//                               if (!hasSufficientBalance)
//                                 Padding(
//                                   padding: EdgeInsets.only(top: 8.h),
//                                   child: Text(
//                                     "Please add funds to your wallet to proceed.",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ),
//                             ] else if (isWalletEnabled &&
//                                 walletAmount == 0) ...[
//                               SizedBox(height: 8.h),
//                               Text(
//                                 "No wallet balance available",
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Price Details",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//
//                             // Calculate total original price and total discount
//                             _buildPriceDetailRow(
//                               "Total Original Price",
//                               "₹${_calculateTotalOriginalPrice(cart).toStringAsFixed(0)}",
//                             ),
//                             SizedBox(height: 4.h),
//                             _buildPriceDetailRow(
//                               "Total Discount",
//                               "-₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                               valueColor: Colors.green,
//                             ),
//                             SizedBox(height: 4.h),
//                             if (cart.requiresHomeCollection)
//                               _buildPriceDetailRow(
//                                 "Home Collection Charge",
//                                 "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                               ),
//                             Divider(height: 16.h, thickness: 1),
//                             _buildPriceDetailRow(
//                               "Subtotal",
//                               "₹${cart.totalPrice.toStringAsFixed(0)}",
//                               isBold: true,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Card(
//                       key: _orderSummaryKey,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Order Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             _buildAmountRow(
//                               "Subtotal",
//                               "₹${cart.totalPrice.toStringAsFixed(0)}",
//                               Colors.black87,
//                             ),
//                             // Only show wallet discount if there's wallet balance
//                             if (walletAmount > 0) ...[
//                               SizedBox(height: 8.h),
//
//                               // Wallet Points Discount WITH TOOLTIP
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Wallet Points Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       _buildInfoTooltip(
//                                         "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     "-₹${walletDiscount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                             if (cart.requiresHomeCollection)
//                               SizedBox(height: 4.h),
//                             _buildAmountRow(
//                               "Home Collection Charge",
//                               "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                               Colors.black87,
//                             ),
//                             Divider(height: 16.h, thickness: 1),
//                             _buildAmountRow(
//                               "Amount to Pay",
//                               "₹${payableAmount.toStringAsFixed(0)}",
//                               Color(0xFF3661E2),
//                               isBold: true,
//                             ),
//
//                             // Add savings information
//                             SizedBox(height: 8.h),
//                             Container(
//                               padding: EdgeInsets.all(8.w),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.discount,
//                                     size: 16.w,
//                                     color: Colors.green,
//                                   ),
//                                   SizedBox(width: 4.w),
//                                   Text(
//                                     "You saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SafeArea(
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16.r),
//                       topRight: Radius.circular(16.r),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Home Sample Collection with proper padding
//                       Container(
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: Row(
//                           children: [
//                             // Checkbox
//                             SizedBox(
//                               width: 24.w,
//                               height: 24.w,
//                               child: Checkbox(
//                                 value: cart.requiresHomeCollection,
//                                 onChanged: (bool? value) {
//                                   final newValue = value ?? false;
//                                   cart.setRequiresHomeCollection(newValue);
//                                   if (!newValue) {
//                                     cart.clearHomeCollectionDetails();
//                                   }
//                                 },
//                                 activeColor: Color(0xFF3661E2),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4.r),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             // Text with proper alignment
//                             Expanded(
//                               child: RichText(
//                                 text: TextSpan(
//                                   text: "Home Sample Collection",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF3661E2),
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                       " (+₹${cart.homeCollectionCharge.toStringAsFixed(0)})",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.sp,
//                                         color: Colors.grey[600],
//                                         fontWeight: FontWeight.normal,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Show address and time slot selection only if home collection is required
//                       if (cart.requiresHomeCollection) ...[
//                         SizedBox(height: 16.h),
//                         // Address Selection
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 8.h,
//                             ),
//                             leading: Icon(
//                               Icons.location_on,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             title: Text(
//                               "Delivery Address",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             subtitle: Text(
//                               cart.selectedAddress ?? "Tap to select address",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 color:
//                                 cart.selectedAddress != null
//                                     ? Colors.grey[700]
//                                     : Colors.grey[500],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 18.w,
//                               color: Colors.grey[600],
//                             ),
//                             onTap:
//                                 () => _showAddressSelectionBottomSheet(
//                               context,
//                               cart,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         // Time Slot Selection
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 8.h,
//                             ),
//                             leading: Icon(
//                               Icons.access_time,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             title: Text(
//                               "Time Slot",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             subtitle: Text(
//                               cart.selectedTimeSlot != null &&
//                                   cart.selectedBookingDate != null
//                                   ? "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}"
//                                   : "Tap to select time slot",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 color:
//                                 cart.selectedTimeSlot != null
//                                     ? Colors.grey[700]
//                                     : Colors.grey[500],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 18.w,
//                               color: Colors.grey[600],
//                             ),
//                             onTap:
//                                 () => _showTimeSlotSelectionBottomSheet(
//                               context,
//                               cart,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                         ),
//                       ],
//                       SizedBox(height: 16.h),
//
//                       // Total Amount and Checkout Button
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           vertical: 12.h,
//                           horizontal: 4.w,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             top: BorderSide(color: Colors.grey[200]!, width: 1),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Total Amount Section
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     "Total Amount",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.grey[700],
//                                     ),
//                                   ),
//                                   SizedBox(height: 4.h),
//                                   Text(
//                                     "₹${payableAmount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 20.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                   SizedBox(height: 4.h),
//                                   Text(
//                                     "Saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             // Checkout Button
//                             ElevatedButton(
//                               onPressed:
//                               hasSufficientBalance &&
//                                   (!cart.requiresHomeCollection ||
//                                       (cart.selectedAddress != null &&
//                                           cart.selectedTimeSlot !=
//                                               null &&
//                                           cart.selectedBookingDate !=
//                                               null))
//                                   ? () {
//                                 _showPaymentOptionsDialog(
//                                   context,
//                                   cart,
//                                   payableAmount,
//                                 );
//                               }
//                                   : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                 hasSufficientBalance
//                                     ? Color(0xFF3661E2)
//                                     : Colors.grey[400],
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 20.w,
//                                   vertical: 14.h,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                 ),
//                                 elevation: hasSufficientBalance ? 2 : 0,
//                                 minimumSize: Size(0, 50.h),
//                               ),
//                               child: Text(
//                                 hasSufficientBalance
//                                     ? "Proceed to Checkout"
//                                     : "Insufficient Balance",
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showPaymentOptionsDialog(
//       BuildContext context,
//       CartModel cart,
//       double payableAmount,
//       ) {
//     final isWalletEnabled =
//         cart.items.isNotEmpty && cart.items.first['isWalletEnabled'] == true;
//     final walletBalance = isWalletEnabled ? cart.walletAmount : 0.0;
//     final walletDiscount =
//     isWalletEnabled && walletBalance > 0
//         ? cart.totalPrice * (cart.walletDiscountPercentage / 100)
//         : 0.0;
//     final hasSufficientBalance =
//         !isWalletEnabled || walletBalance >= walletDiscount;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (context) {
//           bool isLoading = false;
//
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return Scaffold(
//                 // backgroundColor: Colors.white,
//                 backgroundColor: Colors.grey[200],
//                 appBar: AppBar(
//                   elevation: 0,
//                   backgroundColor: Colors.grey[200],
//                   leading: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Color(0xFF3661E2)),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   title: Text(
//                     "Select Payment Option",
//                     style: GoogleFonts.poppins(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3661E2),
//                     ),
//                   ),
//                   centerTitle: true,
//                 ),
//                 body: SingleChildScrollView(
//                   padding: EdgeInsets.all(16.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Payment Summary Card
//                       Container(
//                         padding: EdgeInsets.all(16.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: Colors.grey[200]!),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Payment Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             SizedBox(height: 16.h),
//                             _buildPaymentRow(
//                               "Amount to Pay",
//                               "₹${payableAmount.toStringAsFixed(0)}",
//                               isBold: true,
//                             ),
//                             if (isWalletEnabled) ...[
//                               SizedBox(height: 8.h),
//                               _buildPaymentRow(
//                                 "Wallet Balance",
//                                 "₹${walletBalance.toStringAsFixed(0)}",
//                                 valueColor:
//                                 hasSufficientBalance
//                                     ? Colors.green
//                                     : Colors.red,
//                               ),
//                               if (walletBalance > 0) ...[
//                                 SizedBox(height: 8.h),
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "Wallet Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                         SizedBox(width: 4.w),
//                                         _buildInfoTooltip(
//                                           "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       "-₹${walletDiscount.toStringAsFixed(0)}",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.sp,
//                                         color: Color(0xFF3661E2),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ] else ...[
//                               SizedBox(height: 8.h),
//                               _buildPaymentRow(
//                                 "Wallet",
//                                 "Disabled",
//                                 valueColor: Colors.grey,
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       // Payment Options
//                       Text(
//                         "Choose Payment Method",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       if (isLoading)
//                         Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//                       // Pay Later Option
//                       _buildPaymentOptionCard(
//                         context,
//                         icon: Icons.credit_card,
//                         title: "Pay Later",
//                         subtitle: "Pay after service completion",
//                         onTap:
//                         isLoading
//                             ? null
//                             : () async {
//                           setState(() => isLoading = true);
//                           final result = await cart.placeOrder(
//                             'Pay Later',
//                           );
//                           setState(() => isLoading = false);
//
//                           if (!context.mounted) return;
//                           Navigator.pop(context);
//
//                           if (result['success'] == true) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 fullscreenDialog: true,
//                                 builder:
//                                     (context) => OrderSuccessPopup(
//                                   onContinue: () {
//                                     Navigator.pushAndRemoveUntil(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder:
//                                             (context) =>
//                                                 BookingsScreen(
//                                               userModel:
//                                               userModel,
//                                             ),
//                                       ),
//                                           (route) => route.isFirst,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   result['message'] ??
//                                       "Failed to place order",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                   ),
//                                 ),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16.h),
//                       // Pay Now Option
//                       _buildPaymentOptionCard(
//                         context,
//                         icon: Icons.payment,
//                         title: "Pay Now",
//                         subtitle: "Secure payment via Razorpay",
//                         isDisabled: !hasSufficientBalance,
//                         onTap:
//                         isLoading || !hasSufficientBalance
//                             ? null
//                             : () {
//                           Navigator.pop(context);
//                           _initiateRazorpayPayment(cart, payableAmount);
//                         },
//                       ),
//                       if (!hasSufficientBalance) ...[
//                         SizedBox(height: 8.h),
//                         Text(
//                           "Insufficient wallet balance to use this option",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                       SizedBox(height: 24.h),
//                       // Terms and Conditions
//                       Text(
//                         "By proceeding, you agree to our Terms of Service and Privacy Policy",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12.sp,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildPaymentRow(
//       String label,
//       String value, {
//         Color valueColor = Colors.black87,
//         bool isBold = false,
//       }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             color: valueColor,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentOptionCard(
//       BuildContext context, {
//         required IconData icon,
//         required String title,
//         required String subtitle,
//         bool isDisabled = false,
//         VoidCallback? onTap,
//       }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: isDisabled ? Colors.grey[100] : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: onTap,
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   color:
//                   isDisabled
//                       ? Colors.grey[300]
//                       : Color(0xFF3661E2).withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   color: isDisabled ? Colors.grey : Color(0xFF3661E2),
//                   size: 24.w,
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: GoogleFonts.poppins(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: isDisabled ? Colors.grey : Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       subtitle,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12.sp,
//                         color: isDisabled ? Colors.grey : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: isDisabled ? Colors.grey : Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _initiateRazorpayPayment(CartModel cart, double payableAmount) {
//     final razorpay = Razorpay();
//     bool isProcessing = false;
//
//     void handlePaymentSuccess(PaymentSuccessResponse response) async {
//       if (isProcessing) return;
//       isProcessing = true;
//
//       final context = _scaffoldKey.currentContext;
//       if (context == null || !context.mounted) {
//         razorpay.clear();
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder:
//             (context) => Center(
//           child: CircularProgressIndicator(color: Color(0xFF3661E2)),
//         ),
//       );
//
//       try {
//         final result = await cart.placeOrder('Pay Now');
//
//         if (!context.mounted) {
//           razorpay.clear();
//           return;
//         }
//
//         if (result['success'] == true) {
//           // Show success popup
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               fullscreenDialog: true,
//               builder:
//                   (context) => OrderSuccessPopup(
//                 onContinue: () {
//                   // Navigate to orders screen
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (context) => BookingsScreen(userModel: userModel),
//                     ),
//                         (route) => route.isFirst,
//                   );
//                 },
//               ),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 result['message'] ?? "Failed to place order after payment",
//                 style: GoogleFonts.poppins(fontSize: 14.sp),
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Error processing order: ${e.toString()}",
//                 style: GoogleFonts.poppins(fontSize: 14.sp),
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         razorpay.clear();
//         isProcessing = false;
//       }
//     }
//
//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
//
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Payment failed: ${response.message}",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       razorpay.clear();
//     });
//
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "External wallet selected: ${response.walletName}",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }
//       razorpay.clear();
//     });
//
//     final options = {
//       'key': 'rzp_test_LeshFtPDPl49hb',
//       'amount': (payableAmount * 100).toInt(),
//       'name': 'Aqure',
//       'description': 'Payment for Aqure',
//       'prefill': {
//         'contact': userModel.currentUser?['contactNumber'] ?? '',
//         'email': userModel.currentUser?['email'] ?? '',
//       },
//     };
//
//     try {
//       razorpay.open(options);
//     } catch (e) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Error initiating payment: $e",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       razorpay.clear();
//     }
//   }
//
//   Widget _buildAmountRow(
//       String label,
//       String value,
//       Color color, {
//         bool isBold = false,
//       }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// double _calculateTotalOriginalPrice(CartModel cart) {
//   return cart.items.fold(0.0, (sum, item) {
//     final originalPrice = item['originalPrice'] as double;
//     final quantity = item['quantity'] as int;
//     return sum + (originalPrice * quantity);
//   });
// }
//
// double _calculateTotalDiscount(CartModel cart) {
//   return cart.items.fold(0.0, (sum, item) {
//     final originalPrice = item['originalPrice'] as double;
//     final discountPrice = item['discountPrice'] as double;
//     final quantity = item['quantity'] as int;
//     return sum + ((originalPrice - discountPrice) * quantity);
//   });
// }
//
// Widget _buildPriceDetailRow(
//     String label,
//     String value, {
//       Color valueColor = Colors.black87,
//       bool isBold = false,
//     }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         label,
//         style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
//       ),
//       Text(
//         value,
//         style: GoogleFonts.poppins(
//           fontSize: 14.sp,
//           color: valueColor,
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildInfoTooltip(
//     String message, {
//       Color color = const Color(0xFF3661E2),
//     }) {
//   return Tooltip(
//     message: message,
//     padding: EdgeInsets.all(12.w),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8.r),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 8,
//           spreadRadius: 2,
//         ),
//       ],
//     ),
//     textStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87),
//     child: Icon(Icons.info_outline, size: 16.w, color: color),
//   );
// }
//
// // Helper method to get organization name safely
// String _getOrganizationName(CartModel cart) {
//   if (cart.items.isEmpty) return 'the provider';
//   final organizationName =
//       cart.items.first['organizationName'] ?? cart.items.first['provider'];
//   return organizationName ?? 'the provider';
// }
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../../models/UserModel/user_model.dart';
// import '../../models/CartModel/cart_model.dart';
// import '../../services/MemberService/AddMemberForm/add_member_form.dart';
// import '../../services/MemberService/member_service.dart';
// import '../../utils/routes/custom_page_route.dart';
// import '../OrderSuccessPopup/order_success_popup.dart';
// import '../TestListScreen/TestListDetails/test_list_details.dart';
// import 'package:intl/intl.dart';
// import '../UserDashboard/BookingsScreen/bookings_screen.dart';
//
// class CartScreen extends StatelessWidget {
//   final UserModel userModel;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final MemberService _memberService = MemberService(Dio());
//
//   CartScreen({super.key, required this.userModel});
//
//   void _showPatientSelectionDialog(
//       BuildContext context,
//       Map<String, dynamic> item,
//       CartModel cart,
//       ) {
//     final selectedPatients = <String, bool>{};
//     final primaryMember = userModel.currentUser;
//     final children = userModel.children ?? [];
//     final itemId = item['itemId'];
//     final List<String> previouslySelectedPatientIds = List<String>.from(
//       item['selectedPatientIds'] ?? [],
//     );
//
//     if (primaryMember == null && children.isEmpty) {
//       _showAddMemberForm(context);
//       return;
//     }
//
//     if (primaryMember != null) {
//       selectedPatients[primaryMember['appUserId']
//           .toString()] = previouslySelectedPatientIds.contains(
//         primaryMember['appUserId'].toString(),
//       );
//     }
//     for (var child in children) {
//       selectedPatients[child['appUserId'].toString()] =
//           previouslySelectedPatientIds.contains(child['appUserId'].toString());
//     }
//
//     final totalMembers = (primaryMember != null ? 1 : 0) + children.length;
//     final showAddPatientButton = totalMembers < 5;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               elevation: 4,
//               child: Container(
//                 padding: EdgeInsets.all(20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Select Patients",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, size: 24.w),
//                           onPressed: () => Navigator.pop(context),
//                           padding: EdgeInsets.zero,
//                           constraints: BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
//                     Divider(color: Colors.grey[200], height: 1.h),
//                     SizedBox(height: 16.h),
//                     Container(
//                       constraints: BoxConstraints(maxHeight: 300.h),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (primaryMember != null)
//                               _buildPatientTile(
//                                 context,
//                                 "${primaryMember['firstName']} ${primaryMember['lastName'] ?? ''}",
//                                 "(Primary)",
//                                 selectedPatients[primaryMember['appUserId']
//                                     .toString()] ??
//                                     false,
//                                     (value) {
//                                   setState(() {
//                                     selectedPatients[primaryMember['appUserId']
//                                         .toString()] =
//                                         value ?? false;
//                                   });
//                                 },
//                               ),
//                             ...children
//                                 .map(
//                                   (child) => _buildPatientTile(
//                                 context,
//                                 "${child['firstName']} ${child['lastName'] ?? ''}",
//                                 "",
//                                 selectedPatients[child['appUserId']
//                                     .toString()] ??
//                                     false,
//                                     (value) {
//                                   setState(() {
//                                     selectedPatients[child['appUserId']
//                                         .toString()] =
//                                         value ?? false;
//                                   });
//                                 },
//                               ),
//                             )
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     if (showAddPatientButton) ...[
//                       OutlinedButton.icon(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _showAddMemberForm(context);
//                         },
//                         icon: Icon(
//                           Icons.person_add_outlined,
//                           size: 20.w,
//                           color: Color(0xFF3661E2),
//                         ),
//                         label: Text(
//                           "Add Patient",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(vertical: 12.h),
//                           side: BorderSide(color: Color(0xFF3661E2), width: 1),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                     ],
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               cart.removeFromCart(itemId);
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     "${item['name']} removed from cart",
//                                   ),
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: OutlinedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 12.h),
//                               side: BorderSide(color: Colors.red, width: 1),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                             ),
//                             child: Text(
//                               "Remove",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed:
//                             selectedPatients.values.any(
//                                   (selected) => selected,
//                             )
//                                 ? () {
//                               final selectedPatientIds =
//                               selectedPatients.entries
//                                   .where((entry) => entry.value)
//                                   .map((entry) => entry.key)
//                                   .toList();
//                               cart.removeFromCart(itemId);
//                               cart.addToCart({
//                                 ...item,
//                                 'selectedPatientIds':
//                                 selectedPatientIds,
//                                 'quantity': selectedPatientIds.length,
//                               });
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(
//                                 context,
//                               ).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     "Patient selection updated for ${item['name']}",
//                                   ),
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       10.r,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF3661E2),
//                               padding: EdgeInsets.symmetric(vertical: 12.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               "Confirm",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildPatientTile(
//       BuildContext context,
//       String name,
//       String subtitle,
//       bool value,
//       Function(bool?) onChanged,
//       ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       decoration: BoxDecoration(
//         color: value ? Color(0xFF3661E2).withOpacity(0.1) : Colors.grey[50],
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: value ? Color(0xFF3661E2) : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: CheckboxListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
//         title: Text(
//           name,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: value ? Color(0xFF3661E2) : Colors.black,
//           ),
//         ),
//         subtitle:
//         subtitle.isNotEmpty
//             ? Text(
//           subtitle,
//           style: GoogleFonts.poppins(
//             fontSize: 12.sp,
//             color:
//             value
//                 ? Color(0xFF3661E2).withOpacity(0.8)
//                 : Colors.grey,
//           ),
//         )
//             : null,
//         value: value,
//         onChanged: onChanged,
//         activeColor: Color(0xFF3661E2),
//         controlAffinity: ListTileControlAffinity.trailing,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//       ),
//     );
//   }
//
//   void _showAddMemberForm(BuildContext context) {
//     final primaryUser = userModel.currentUser;
//     if (primaryUser == null) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return AddMemberForm(
//           linkingId: primaryUser['appUserId'].toString(),
//           memberService: _memberService,
//           onMemberAdded: (newMember) {
//             // Refresh user data to get the new member
//             userModel.getUserByPhone(primaryUser['contactNumber']);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Member added successfully'),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showAddressSelectionBottomSheet(BuildContext context, CartModel cart) {
//     final primaryUser = userModel.currentUser;
//     final currentAddress = primaryUser?['address'] ?? '';
//     final selectedAddress = cart.selectedAddress ?? currentAddress;
//
//     final addressController = TextEditingController(text: selectedAddress);
//     final _formKey = GlobalKey<FormState>();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24.r),
//               topRight: Radius.circular(24.r),
//             ),
//           ),
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header
//                 Container(
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF3661E2),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24.r),
//                       topRight: Radius.circular(24.r),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Select Address",
//                         style: GoogleFonts.poppins(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           size: 24.w,
//                           color: Colors.white,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints(),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Content
//                 Padding(
//                   padding: EdgeInsets.all(20.w),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Delivery Address",
//                           style: GoogleFonts.poppins(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         Text(
//                           "Enter the address where you'd like your samples to be collected",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 20.h),
//
//                         // Address Input Field
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: TextFormField(
//                             controller: addressController,
//                             maxLines: 4,
//                             minLines: 3,
//                             decoration: InputDecoration(
//                               hintText: "Enter your complete address...",
//                               hintStyle: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey[500],
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(16.w),
//                               prefixIcon: Icon(
//                                 Icons.location_on,
//                                 color: Color(0xFF3661E2),
//                                 size: 25.w,
//                               ),
//                             ),
//                             style: GoogleFonts.poppins(
//                               fontSize: 14.sp,
//                               color: Colors.black87,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return 'Please enter your address';
//                               }
//                               if (value.trim().length < 4) {
//                                 return 'Please enter a complete address';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//
//                         // Action Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                                   side: BorderSide(
//                                     color: Colors.grey[400]!,
//                                     width: 1.5,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   backgroundColor: Colors.grey[50],
//                                 ),
//                                 child: Text(
//                                   "Cancel",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16.w),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     cart.setSelectedAddress(
//                                       addressController.text.trim(),
//                                     );
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           "Address saved successfully",
//                                           style: GoogleFonts.poppins(),
//                                         ),
//                                         backgroundColor: Color(0xFF3661E2),
//                                         behavior: SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             10.r,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFF3661E2),
//                                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   elevation: 2,
//                                 ),
//                                 child: Text(
//                                   "Save Address",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showTimeSlotSelectionBottomSheet(BuildContext context, CartModel cart) {
//     if (cart.timeSlots.isEmpty) {
//       cart.fetchTimeSlots();
//     }
//
//     // Set today's date as default if not already set
//     if (cart.selectedBookingDate == null) {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       cart.setSelectedBookingDate(today);
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24.r),
//                   topRight: Radius.circular(24.r),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Header
//                     Container(
//                       padding: EdgeInsets.all(20.w),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF3661E2),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(24.r),
//                           topRight: Radius.circular(24.r),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Select Time Slot",
//                             style: GoogleFonts.poppins(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.close,
//                               size: 24.w,
//                               color: Colors.white,
//                             ),
//                             onPressed: () => Navigator.pop(context),
//                             padding: EdgeInsets.zero,
//                             constraints: BoxConstraints(),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Content
//                     Padding(
//                       padding: EdgeInsets.all(20.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Date Picker Section
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(16.r),
//                               border: Border.all(
//                                 color: Colors.grey[200]!,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.calendar_today,
//                                       size: 18.w,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       "Select Date",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 12.h),
//                                 InkWell(
//                                   // onTap: () async {
//                                   //   final selectedDate = await showDatePicker(
//                                   //     context: context,
//                                   //     initialDate: DateTime.now(),
//                                   //     firstDate: DateTime.now(),
//                                   //     lastDate: DateTime.now().add(
//                                   //       Duration(days: 30),
//                                   //     ),
//                                   //     builder: (context, child) {
//                                   //       return Theme(
//                                   //         data: Theme.of(context).copyWith(
//                                   //           colorScheme: ColorScheme.light(
//                                   //             primary: Color(0xFF3661E2),
//                                   //             onPrimary: Colors.white,
//                                   //             surface: Colors.white,
//                                   //             onSurface: Colors.black,
//                                   //           ),
//                                   //           dialogBackgroundColor: Colors.white,
//                                   //         ),
//                                   //         child: child!,
//                                   //       );
//                                   //     },
//                                   //   );
//                                   //
//                                   //   if (selectedDate != null) {
//                                   //     final formattedDate = DateFormat(
//                                   //       'yyyy-MM-dd',
//                                   //     ).format(selectedDate);
//                                   //     cart.setSelectedBookingDate(
//                                   //       formattedDate,
//                                   //     );
//                                   //     setState(() {});
//                                   //   }
//                                   // },
//                                   onTap: () async {
//                                     final selectedDate = await showDatePicker(
//                                       context: context,
//                                       initialDate: DateTime.now(),
//                                       firstDate: DateTime.now(),
//                                       lastDate: DateTime.now().add(Duration(days: 30)),
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme: ColorScheme.light(
//                                               primary: Color(0xFF3661E2),
//                                               onPrimary: Colors.white,
//                                               surface: Colors.white,
//                                               onSurface: Colors.black,
//                                             ),
//                                             dialogBackgroundColor: Colors.white,
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                     );
//
//                                     if (selectedDate != null) {
//                                       final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//                                       cart.setSelectedBookingDate(formattedDate);
//
//                                       // Refresh time slots with new date
//                                       cart.fetchTimeSlots();
//                                       setState(() {});
//                                     }
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.all(16.w),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: Color(
//                                           0xFF3661E2,
//                                         ).withOpacity(0.3),
//                                         width: 1.5,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.1),
//                                           blurRadius: 6,
//                                           offset: Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Selected Date",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 12.sp,
//                                                   color: Colors.grey[600],
//                                                 ),
//                                               ),
//                                               SizedBox(height: 4.h),
//                                               Text(
//                                                 _formatDisplayDate(
//                                                   cart.selectedBookingDate,
//                                                 ),
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 16.sp,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Color(0xFF3661E2),
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           padding: EdgeInsets.all(8.w),
//                                           decoration: BoxDecoration(
//                                             color: Color(
//                                               0xFF3661E2,
//                                             ).withOpacity(0.1),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Icon(
//                                             Icons.edit,
//                                             size: 18.w,
//                                             color: Color(0xFF3661E2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20.h),
//
//                           // Time Slots Section
//                           Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(16.r),
//                               border: Border.all(
//                                 color: Colors.grey[200]!,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.access_time,
//                                       size: 18.w,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       "Available Time Slots",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     if (cart.isLoadingTimeSlots)
//                                       SizedBox(
//                                         width: 16.w,
//                                         height: 16.w,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Color(0xFF3661E2),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 12.h),
//
//                                 if (cart.isLoadingTimeSlots)
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 40.h,
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         CircularProgressIndicator(
//                                           color: Color(0xFF3661E2),
//                                           strokeWidth: 3,
//                                         ),
//                                         SizedBox(height: 16.h),
//                                         Text(
//                                           "Loading available slots...",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 else if (cart.timeSlots.isEmpty)
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 40.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: Colors.grey[200]!,
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.schedule,
//                                           size: 48.w,
//                                           color: Colors.grey[400],
//                                         ),
//                                         SizedBox(height: 12.h),
//                                         Text(
//                                           "No time slots available",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 16.sp,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         SizedBox(height: 8.h),
//                                         Text(
//                                           "Please try another date",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             color: Colors.grey[500],
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 else
//                                   Container(
//                                     constraints: BoxConstraints(maxHeight: 200.h),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: Colors.grey[200]!,
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                     child: ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: BouncingScrollPhysics(),
//                                       itemCount: cart.timeSlots.length,
//                                       itemBuilder: (context, index) {
//                                         final slot = cart.timeSlots[index];
//                                         final isSelected = cart.selectedTimeSlot == slot['slotName'];
//                                         final isAvailable = slot['available'] != false;
//
//                                         return InkWell(
//                                           onTap: isAvailable ? () {
//                                             cart.setSelectedTimeSlot(slot['slotName']!);
//                                             setState(() {});
//                                           } : null,
//                                           child: Container(
//                                             padding: EdgeInsets.all(16.w),
//                                             decoration: BoxDecoration(
//                                               color: isSelected
//                                                   ? Color(0xFF3661E2).withOpacity(0.1)
//                                                   : Colors.white,
//                                               border: Border(
//                                                 bottom: index < cart.timeSlots.length - 1
//                                                     ? BorderSide(color: Colors.grey[100]!, width: 1)
//                                                     : BorderSide.none,
//                                               ),
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 // Selection Indicator
//                                                 Container(
//                                                   width: 22.w,
//                                                   height: 22.w,
//                                                   decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                       color: isSelected
//                                                           ? Color(0xFF3661E2)
//                                                           : isAvailable
//                                                           ? Colors.grey[400]!
//                                                           : Colors.grey[300]!,
//                                                       width: 2,
//                                                     ),
//                                                     color: isSelected ? Color(0xFF3661E2) : Colors.transparent,
//                                                   ),
//                                                   child: isSelected
//                                                       ? Icon(Icons.check, size: 14.w, color: Colors.white)
//                                                       : null,
//                                                 ),
//                                                 SizedBox(width: 16.w),
//
//                                                 // Slot Info
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         slot['slotName'] ?? 'Unknown Slot',
//                                                         style: GoogleFonts.poppins(
//                                                           fontSize: 15.sp,
//                                                           fontWeight: FontWeight.w500,
//                                                           color: isSelected
//                                                               ? Color(0xFF3661E2)
//                                                               : isAvailable
//                                                               ? Colors.black87
//                                                               : Colors.grey[400]!,
//                                                         ),
//                                                       ),
//                                                       if (slot['timing'] != null)
//                                                         Text(
//                                                           slot['timing'],
//                                                           style: GoogleFonts.poppins(
//                                                             fontSize: 12.sp,
//                                                             color: isAvailable
//                                                                 ? Colors.grey[600]
//                                                                 : Colors.grey[400],
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ),
//
//                                                 // Availability Status
//                                                 if (!isAvailable)
//                                                   Container(
//                                                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.red.withOpacity(0.1),
//                                                       borderRadius: BorderRadius.circular(6.r),
//                                                       border: Border.all(
//                                                         color: Colors.red.withOpacity(0.3),
//                                                         width: 1,
//                                                       ),
//                                                     ),
//                                                     child: Text(
//                                                       "Passed",
//                                                       style: GoogleFonts.poppins(
//                                                         fontSize: 11.sp,
//                                                         color: Colors.red,
//                                                         fontWeight: FontWeight.w500,
//                                                       ),
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   // Container(
//                                   //   constraints: BoxConstraints(
//                                   //     maxHeight: 200.h,
//                                   //   ),
//                                   //   decoration: BoxDecoration(
//                                   //     color: Colors.white,
//                                   //     borderRadius: BorderRadius.circular(12.r),
//                                   //     border: Border.all(
//                                   //       color: Colors.grey[200]!,
//                                   //       width: 1.5,
//                                   //     ),
//                                   //   ),
//                                   //   child: ListView.builder(
//                                   //     shrinkWrap: true,
//                                   //     physics: BouncingScrollPhysics(),
//                                   //     itemCount: cart.timeSlots.length,
//                                   //     itemBuilder: (context, index) {
//                                   //       final slot = cart.timeSlots[index];
//                                   //       final isSelected =
//                                   //           cart.selectedTimeSlot ==
//                                   //               slot['slotName'];
//                                   //       final isAvailable =
//                                   //           slot['available'] != false;
//                                   //
//                                   //       return InkWell(
//                                   //         onTap:
//                                   //         isAvailable
//                                   //             ? () {
//                                   //           cart.setSelectedTimeSlot(
//                                   //             slot['slotName']!,
//                                   //           );
//                                   //           setState(() {});
//                                   //         }
//                                   //             : null,
//                                   //         child: Container(
//                                   //           padding: EdgeInsets.all(16.w),
//                                   //           decoration: BoxDecoration(
//                                   //             color:
//                                   //             isSelected
//                                   //                 ? Color(
//                                   //               0xFF3661E2,
//                                   //             ).withOpacity(0.1)
//                                   //                 : Colors.white,
//                                   //             border: Border(
//                                   //               bottom:
//                                   //               index <
//                                   //                   cart
//                                   //                       .timeSlots
//                                   //                       .length -
//                                   //                       1
//                                   //                   ? BorderSide(
//                                   //                 color:
//                                   //                 Colors.grey[100]!,
//                                   //                 width: 1,
//                                   //               )
//                                   //                   : BorderSide.none,
//                                   //             ),
//                                   //           ),
//                                   //           child: Row(
//                                   //             children: [
//                                   //               // Selection Indicator
//                                   //               Container(
//                                   //                 width: 22.w,
//                                   //                 height: 22.w,
//                                   //                 decoration: BoxDecoration(
//                                   //                   shape: BoxShape.circle,
//                                   //                   border: Border.all(
//                                   //                     color:
//                                   //                     isSelected
//                                   //                         ? Color(
//                                   //                       0xFF3661E2,
//                                   //                     )
//                                   //                         : isAvailable
//                                   //                         ? Colors
//                                   //                         .grey[400]!
//                                   //                         : Colors
//                                   //                         .grey[300]!,
//                                   //                     width: 2,
//                                   //                   ),
//                                   //                   color:
//                                   //                   isSelected
//                                   //                       ? Color(0xFF3661E2)
//                                   //                       : Colors
//                                   //                       .transparent,
//                                   //                 ),
//                                   //                 child:
//                                   //                 isSelected
//                                   //                     ? Icon(
//                                   //                   Icons.check,
//                                   //                   size: 14.w,
//                                   //                   color: Colors.white,
//                                   //                 )
//                                   //                     : null,
//                                   //               ),
//                                   //               SizedBox(width: 16.w),
//                                   //
//                                   //               // Slot Info
//                                   //               Expanded(
//                                   //                 child: Column(
//                                   //                   crossAxisAlignment:
//                                   //                   CrossAxisAlignment
//                                   //                       .start,
//                                   //                   children: [
//                                   //                     Text(
//                                   //                       slot['slotName'] ??
//                                   //                           'Unknown Slot',
//                                   //                       style: GoogleFonts.poppins(
//                                   //                         fontSize: 15.sp,
//                                   //                         fontWeight:
//                                   //                         FontWeight.w500,
//                                   //                         color:
//                                   //                         isSelected
//                                   //                             ? Color(
//                                   //                           0xFF3661E2,
//                                   //                         )
//                                   //                             : isAvailable
//                                   //                             ? Colors
//                                   //                             .black87
//                                   //                             : Colors
//                                   //                             .grey[400]!,
//                                   //                       ),
//                                   //                     ),
//                                   //                     if (slot['timing'] !=
//                                   //                         null)
//                                   //                       Text(
//                                   //                         slot['timing'],
//                                   //                         style: GoogleFonts.poppins(
//                                   //                           fontSize: 12.sp,
//                                   //                           color:
//                                   //                           isAvailable
//                                   //                               ? Colors
//                                   //                               .grey[600]
//                                   //                               : Colors
//                                   //                               .grey[400],
//                                   //                         ),
//                                   //                       ),
//                                   //                   ],
//                                   //                 ),
//                                   //               ),
//                                   //
//                                   //               // Availability Status
//                                   //               if (!isAvailable)
//                                   //                 Container(
//                                   //                   padding:
//                                   //                   EdgeInsets.symmetric(
//                                   //                     horizontal: 10.w,
//                                   //                     vertical: 6.h,
//                                   //                   ),
//                                   //                   decoration: BoxDecoration(
//                                   //                     color: Colors.red
//                                   //                         .withOpacity(0.1),
//                                   //                     borderRadius:
//                                   //                     BorderRadius.circular(
//                                   //                       6.r,
//                                   //                     ),
//                                   //                     border: Border.all(
//                                   //                       color: Colors.red
//                                   //                           .withOpacity(0.3),
//                                   //                       width: 1,
//                                   //                     ),
//                                   //                   ),
//                                   //                   child: Text(
//                                   //                     "Full",
//                                   //                     style:
//                                   //                     GoogleFonts.poppins(
//                                   //                       fontSize: 11.sp,
//                                   //                       color: Colors.red,
//                                   //                       fontWeight:
//                                   //                       FontWeight.w500,
//                                   //                     ),
//                                   //                   ),
//                                   //                 ),
//                                   //             ],
//                                   //           ),
//                                   //         ),
//                                   //       );
//                                   //     },
//                                   //   ),
//                                   // ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20.h),
//
//                           // Selected Info Banner
//                           if (cart.selectedTimeSlot != null &&
//                               cart.selectedBookingDate != null)
//                             Container(
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF3661E2).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 border: Border.all(
//                                   color: Color(0xFF3661E2).withOpacity(0.2),
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.check_circle,
//                                     size: 20.w,
//                                     color: Color(0xFF3661E2),
//                                   ),
//                                   SizedBox(width: 12.w),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Selected Time Slot",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12.sp,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14.sp,
//                                             fontWeight: FontWeight.w600,
//                                             color: Color(0xFF3661E2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           SizedBox(height: 24.h),
//
//                           // Action Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 16.h,
//                                     ),
//                                     side: BorderSide(
//                                       color: Colors.grey[400]!,
//                                       width: 1.5,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     backgroundColor: Colors.grey[50],
//                                   ),
//                                   child: Text(
//                                     "Cancel",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.grey[700],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 16.w),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed:
//                                   cart.selectedTimeSlot != null &&
//                                       cart.selectedBookingDate != null
//                                       ? () {
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(
//                                       context,
//                                     ).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           "Time slot selected successfully",
//                                           style: GoogleFonts.poppins(),
//                                         ),
//                                         behavior:
//                                         SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                             10.r,
//                                           ),
//                                         ),
//                                         backgroundColor: Color(
//                                           0xFF3661E2,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                       : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF3661E2),
//                                     padding: EdgeInsets.symmetric(
//                                       vertical: 16.h,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     elevation: 2,
//                                   ),
//                                   child: Text(
//                                     "Confirm Slot",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   String _formatDisplayDate(String? dateString) {
//     if (dateString == null) return "Select a date";
//
//     try {
//       final date = DateFormat('yyyy-MM-dd').parse(dateString);
//       final today = DateTime.now();
//       final tomorrow = today.add(Duration(days: 1));
//
//       if (date.year == today.year &&
//           date.month == today.month &&
//           date.day == today.day) {
//         return "Today, ${DateFormat('MMM dd, yyyy').format(date)}";
//       } else if (date.year == tomorrow.year &&
//           date.month == tomorrow.month &&
//           date.day == tomorrow.day) {
//         return "Tomorrow, ${DateFormat('MMM dd, yyyy').format(date)}";
//       } else {
//         return DateFormat('EEE, MMM dd, yyyy').format(date);
//       }
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   final ScrollController _scrollController = ScrollController();
//   //   final GlobalKey _walletSummaryKey = GlobalKey();
//   //   final GlobalKey _orderSummaryKey = GlobalKey();
//   //
//   //   return Scaffold(
//   //     key: _scaffoldKey,
//   //     backgroundColor: Colors.grey[200],
//   //     appBar: AppBar(
//   //       elevation: 0,
//   //       backgroundColor: Colors.grey[200],
//   //       title: Consumer<CartModel>(
//   //         builder: (context, cart, child) => Text(
//   //           "Cart (${cart.selectedItemCount}/${cart.itemCount})",
//   //           style: GoogleFonts.poppins(
//   //             fontSize: 20.sp,
//   //             fontWeight: FontWeight.bold,
//   //             color: Color(0xFF3661E2),
//   //           ),
//   //         ),
//   //       ),
//   //       iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
//   //     ),
//   //     body: Consumer<CartModel>(
//   //       builder: (context, cart, child) {
//   //         if (cart.items.isEmpty) {
//   //           return Center(
//   //             child: Column(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: [
//   //                 Icon(
//   //                   Icons.shopping_cart_outlined,
//   //                   size: 80.w,
//   //                   color: Colors.grey[400],
//   //                 ),
//   //                 SizedBox(height: 16.h),
//   //                 Text(
//   //                   "Your Cart is Empty",
//   //                   style: GoogleFonts.poppins(
//   //                     fontSize: 18.sp,
//   //                     fontWeight: FontWeight.w600,
//   //                     color: Colors.grey[600],
//   //                   ),
//   //                 ),
//   //                 SizedBox(height: 8.h),
//   //                 Text(
//   //                   "Add some tests to get started",
//   //                   style: GoogleFonts.poppins(
//   //                     fontSize: 14.sp,
//   //                     color: Colors.grey[500],
//   //                   ),
//   //                 ),
//   //                 SizedBox(height: 24.h),
//   //                 ElevatedButton(
//   //                   onPressed: () => Navigator.pop(context),
//   //                   style: ElevatedButton.styleFrom(
//   //                     backgroundColor: Color(0xFF3661E2),
//   //                     padding: EdgeInsets.symmetric(
//   //                       horizontal: 24.w,
//   //                       vertical: 12.h,
//   //                     ),
//   //                     shape: RoundedRectangleBorder(
//   //                       borderRadius: BorderRadius.circular(12.r),
//   //                     ),
//   //                   ),
//   //                   child: Text(
//   //                     "Browse Tests",
//   //                     style: GoogleFonts.poppins(
//   //                       fontSize: 14.sp,
//   //                       fontWeight: FontWeight.w600,
//   //                       color: Colors.white,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           );
//   //         }
//   //
//   //         final isWalletEnabled =
//   //             cart.items.isNotEmpty &&
//   //                 cart.items.first['isWalletEnabled'] == true;
//   //         final walletAmount = isWalletEnabled ? cart.walletAmount : 0.0;
//   //
//   //         // final walletDiscount =
//   //         // isWalletEnabled && walletAmount > 0
//   //         //     ? cart.selectedTotalPrice  * (cart.walletDiscountPercentage / 100)
//   //         //     : 0.0;
//   //         // final payableAmount = cart.selectedTotalPrice  - walletDiscount;
//   //         final walletDiscount = isWalletEnabled && walletAmount > 0
//   //             ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
//   //             : 0.0;
//   //
//   //         final payableAmount = (cart.selectedSubtotal - walletDiscount) +
//   //             (cart.requiresHomeCollection ? cart.homeCollectionCharge : 0);
//   //         final walletAmountAfterDeduction =
//   //         isWalletEnabled ? walletAmount - walletDiscount : 0.0;
//   //         final hasSufficientBalance =
//   //             !isWalletEnabled || walletAmountAfterDeduction >= 0;
//   //         return Column(
//   //           children: [
//   //             Expanded(
//   //               child: ListView(
//   //                 controller: _scrollController,
//   //                 padding: EdgeInsets.symmetric(
//   //                   horizontal: 16.w,
//   //                   vertical: 16.h,
//   //                 ),
//   //                 children: [
//   //                   ...List.generate(cart.items.length, (index) {
//   //                     final item = cart.items[index];
//   //                     final itemId = item['itemId'];
//   //                     final isSelected = cart.isItemSelected(itemId);
//   //                     final quantity = item['quantity'] as int;
//   //                     final discountPrice = item["discountPrice"] as double;
//   //                     final originalPrice = item["originalPrice"] as double;
//   //                     final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();
//   //                     final totalItemPrice = discountPrice * quantity;
//   //                     final selectedPatientCount = (item['selectedPatientIds'] as List?)?.length ?? 0;
//   //
//   //                     return GestureDetector(
//   //                       onTap: () {
//   //                         Navigator.push(
//   //                           context,
//   //                           CustomPageRoute(
//   //                             child: TestListDetails(
//   //                               test: item,
//   //                               provider: item["provider"],
//   //                               service: item["service"],
//   //                               userModel: userModel,
//   //                             ),
//   //                             direction: AxisDirection.right,
//   //                           ),
//   //                         );
//   //                       },
//   //                       child: Card(
//   //                         elevation: isSelected ? 4 : 2,
//   //                         margin: EdgeInsets.only(bottom: 12.h),
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(16.r),
//   //                           side: BorderSide(
//   //                             color: isSelected ? Color(0xFF3661E2) : Colors.grey[200]!,
//   //                             width: isSelected ? 2 : 1,
//   //                           ),
//   //                         ),
//   //                         child: Container(
//   //                           padding: EdgeInsets.all(16.w),
//   //                           decoration: BoxDecoration(
//   //                             borderRadius: BorderRadius.circular(16.r),
//   //                             color: isSelected ? Color(0xFF3661E2).withOpacity(0.05) : Colors.white,
//   //                           ),
//   //                           child: Row(
//   //                             crossAxisAlignment: CrossAxisAlignment.start,
//   //                             children: [
//   //                               // Checkbox for selection
//   //                               SizedBox(
//   //                                 width: 24.w,
//   //                                 height: 24.w,
//   //                                 child: Checkbox(
//   //                                   value: isSelected,
//   //                                   onChanged: (value) {
//   //                                     cart.toggleItemSelection(itemId, value ?? false);
//   //                                   },
//   //                                   activeColor: Color(0xFF3661E2),
//   //                                   shape: RoundedRectangleBorder(
//   //                                     borderRadius: BorderRadius.circular(4.r),
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                               SizedBox(width: 12.w),
//   //
//   //                               Expanded(
//   //                                 child: Column(
//   //                                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                                   children: [
//   //                                     Row(
//   //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                                       children: [
//   //                                         Flexible(
//   //                                           child: Row(
//   //                                             children: [
//   //                                               Container(
//   //                                                 padding: EdgeInsets.all(8.w),
//   //                                                 decoration: BoxDecoration(
//   //                                                   color: Colors.grey.shade300,
//   //                                                   shape: BoxShape.circle,
//   //                                                 ),
//   //                                                 child: Icon(
//   //                                                   Icons.science,
//   //                                                   color: Color(0xFF3661E2),
//   //                                                   size: 25.w,
//   //                                                 ),
//   //                                               ),
//   //                                               SizedBox(width: 12.w),
//   //                                               Flexible(
//   //                                                 child: Column(
//   //                                                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                                                   children: [
//   //                                                     Text(
//   //                                                       item["name"],
//   //                                                       style: GoogleFonts.poppins(
//   //                                                         fontSize: 18.sp,
//   //                                                         fontWeight: FontWeight.bold,
//   //                                                         color: Color(0xFF3661E2),
//   //                                                       ),
//   //                                                       maxLines: 1,
//   //                                                       overflow: TextOverflow.ellipsis,
//   //                                                     ),
//   //                                                     SizedBox(height: 4.h),
//   //                                                     Text(
//   //                                                       "Provider: ${item['provider']}",
//   //                                                       style: GoogleFonts.poppins(
//   //                                                         fontSize: 14.sp,
//   //                                                         color: Colors.black,
//   //                                                       ),
//   //                                                       maxLines: 1,
//   //                                                       overflow: TextOverflow.ellipsis,
//   //                                                     ),
//   //                                                   ],
//   //                                                 ),
//   //                                               ),
//   //                                             ],
//   //                                           ),
//   //                                         ),
//   //                                         ElevatedButton(
//   //                                           onPressed: () => _showPatientSelectionDialog(
//   //                                             context,
//   //                                             item,
//   //                                             cart,
//   //                                           ),
//   //                                           style: ElevatedButton.styleFrom(
//   //                                             backgroundColor: selectedPatientCount > 0
//   //                                                 ? Colors.white
//   //                                                 : Color(0xFF3661E2),
//   //                                             padding: EdgeInsets.symmetric(
//   //                                               horizontal: 24.w,
//   //                                               vertical: 12.h,
//   //                                             ),
//   //                                             shape: RoundedRectangleBorder(
//   //                                               borderRadius: BorderRadius.circular(8.r),
//   //                                               side: selectedPatientCount > 0
//   //                                                   ? BorderSide(
//   //                                                 color: Color(0xFF3661E2),
//   //                                                 width: 1,
//   //                                               )
//   //                                                   : BorderSide.none,
//   //                                             ),
//   //                                             elevation: 0,
//   //                                           ),
//   //                                           child: Text(
//   //                                             selectedPatientCount > 0
//   //                                                 ? "$selectedPatientCount Patient${selectedPatientCount == 1 ? '' : 's'}"
//   //                                                 : "Select Patients",
//   //                                             style: GoogleFonts.poppins(
//   //                                               fontSize: 14.sp,
//   //                                               fontWeight: FontWeight.w600,
//   //                                               color: selectedPatientCount > 0
//   //                                                   ? Color(0xFF3661E2)
//   //                                                   : Colors.white,
//   //                                             ),
//   //                                           ),
//   //                                         ),
//   //                                       ],
//   //                                     ),
//   //                                     SizedBox(height: 8.h),
//   //                                     Row(
//   //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                                       crossAxisAlignment: CrossAxisAlignment.center,
//   //                                       children: [
//   //                                         Flexible(
//   //                                           child: Column(
//   //                                             crossAxisAlignment: CrossAxisAlignment.start,
//   //                                             children: [
//   //                                               Text(
//   //                                                 "Price per patient: ₹${discountPrice.toStringAsFixed(0)}",
//   //                                                 style: GoogleFonts.poppins(
//   //                                                   fontSize: 14.sp,
//   //                                                   fontWeight: FontWeight.w600,
//   //                                                   color: Colors.black87,
//   //                                                 ),
//   //                                               ),
//   //                                               Row(
//   //                                                 children: [
//   //                                                   Text(
//   //                                                     "₹${originalPrice.toStringAsFixed(0)}",
//   //                                                     style: GoogleFonts.poppins(
//   //                                                       fontSize: 14.sp,
//   //                                                       color: Colors.grey,
//   //                                                       decoration: TextDecoration.lineThrough,
//   //                                                     ),
//   //                                                   ),
//   //                                                   SizedBox(width: 8.w),
//   //                                                   Text(
//   //                                                     "${discountPercentage.toStringAsFixed(0)}% OFF",
//   //                                                     style: GoogleFonts.poppins(
//   //                                                       fontSize: 14.sp,
//   //                                                       color: Color(0xFF3661E2),
//   //                                                       fontWeight: FontWeight.w600,
//   //                                                     ),
//   //                                                   ),
//   //                                                 ],
//   //                                               ),
//   //                                               Text(
//   //                                                 "Total for $selectedPatientCount patient${selectedPatientCount == 1 ? '' : 's'}: ₹${totalItemPrice.toStringAsFixed(0)}",
//   //                                                 style: GoogleFonts.poppins(
//   //                                                   fontSize: 14.sp,
//   //                                                   fontWeight: FontWeight.bold,
//   //                                                   color: Colors.black,
//   //                                                 ),
//   //                                               ),
//   //                                             ],
//   //                                           ),
//   //                                         ),
//   //                                       ],
//   //                                     ),
//   //                                   ],
//   //                                 ),
//   //                               ),
//   //                             ],
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     );
//   //                   }),
//   @override
//   Widget build(BuildContext context) {
//     final ScrollController _scrollController = ScrollController();
//     final GlobalKey _walletSummaryKey = GlobalKey();
//     final GlobalKey _orderSummaryKey = GlobalKey();
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.grey[200],
//         title: Consumer<CartModel>(
//           builder: (context, cart, child) => Text(
//             "Cart (${cart.selectedItemCount}/${cart.itemCount})",
//             style: GoogleFonts.poppins(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF3661E2),
//             ),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
//       ),
//       body: Consumer<CartModel>(
//         builder: (context, cart, child) {
//           if (cart.items.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_cart_outlined,
//                     size: 80.w,
//                     color: Colors.grey[400],
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "Your Cart is Empty",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     "Add some tests to get started",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14.sp,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF3661E2),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 24.w,
//                         vertical: 12.h,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     child: Text(
//                       "Browse Tests",
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final isWalletEnabled =
//               cart.items.isNotEmpty &&
//                   cart.items.first['isWalletEnabled'] == true;
//           final walletAmount = isWalletEnabled ? cart.walletAmount : 0.0;
//
//           final walletDiscount = isWalletEnabled && walletAmount > 0
//               ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
//               : 0.0;
//
//           final payableAmount = (cart.selectedSubtotal - walletDiscount) +
//               (cart.requiresHomeCollection ? cart.homeCollectionCharge : 0);
//           final walletAmountAfterDeduction =
//           isWalletEnabled ? walletAmount - walletDiscount : 0.0;
//           final hasSufficientBalance =
//               !isWalletEnabled || walletAmountAfterDeduction >= 0;
//
//           return Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   controller: _scrollController,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 16.h,
//                   ),
//                   children: [
//                     ...List.generate(cart.items.length, (index) {
//                       final item = cart.items[index];
//                       final itemId = item['itemId'];
//                       final isSelected = cart.isItemSelected(itemId);
//                       final quantity = item['quantity'] as int;
//                       final discountPrice = item["discountPrice"] as double;
//                       final originalPrice = item["originalPrice"] as double;
//                       final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();
//                       final totalItemPrice = discountPrice * quantity;
//                       final selectedPatientCount = (item['selectedPatientIds'] as List?)?.length ?? 0;
//
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             CustomPageRoute(
//                               child: TestListDetails(
//                                 test: item,
//                                 provider: item["provider"],
//                                 service: item["service"],
//                                 userModel: userModel,
//                               ),
//                               direction: AxisDirection.right,
//                             ),
//                           );
//                         },
//                         child: Card(
//                           elevation: isSelected ? 4 : 2,
//                           margin: EdgeInsets.only(bottom: 12.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16.r),
//                             side: BorderSide(
//                               color: isSelected ? Color(0xFF3661E2) : Colors.grey[200]!,
//                               width: isSelected ? 2 : 1,
//                             ),
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16.r),
//                               color: Colors.white
//                               // color: isSelected ? Color(0xFF3661E2).withOpacity(0.05) : Colors.white,
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Header row with checkbox, test icon and select patients button
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     // Checkbox for selection - Moved to top right
//                                     Container(
//                                       width: 24.w,
//                                       height: 24.w,
//                                       child: Checkbox(
//                                         value: isSelected,
//                                         onChanged: (value) {
//                                           cart.toggleItemSelection(itemId, value ?? false);
//                                         },
//                                         activeColor: Color(0xFF3661E2),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(6.r),
//                                         ),
//                                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                       ),
//                                     ),
//                                     SizedBox(width: 12.w),
//
//                                     // Test icon
//                                     Container(
//                                       padding: EdgeInsets.all(8.w),
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey.shade300,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         Icons.science,
//                                         color: Color(0xFF3661E2),
//                                         size: 25.w,
//                                       ),
//                                     ),
//                                     SizedBox(width: 12.w),
//
//                                     // Test name and provider
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             item["name"],
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 18.sp,
//                                               fontWeight: FontWeight.bold,
//                                               color: Color(0xFF3661E2),
//                                             ),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           SizedBox(height: 4.h),
//                                           Text(
//                                             "Provider: ${item['provider']}",
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 14.sp,
//                                               color: Colors.black,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//
//                                     // Select Patients button
//                                     ElevatedButton(
//                                       onPressed: () => _showPatientSelectionDialog(
//                                         context,
//                                         item,
//                                         cart,
//                                       ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: selectedPatientCount > 0
//                                             ? Colors.white
//                                             : Color(0xFF3661E2),
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 16.w,
//                                           vertical: 10.h,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8.r),
//                                           side: selectedPatientCount > 0
//                                               ? BorderSide(
//                                             color: Color(0xFF3661E2),
//                                             width: 1,
//                                           )
//                                               : BorderSide.none,
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: Text(
//                                         selectedPatientCount > 0
//                                             ? "$selectedPatientCount"
//                                             : "Select",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w600,
//                                           color: selectedPatientCount > 0
//                                               ? Color(0xFF3661E2)
//                                               : Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 SizedBox(height: 12.h),
//
//                                 // Price information
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 "Price per patient: ",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 14.sp,
//                                                   color: Colors.grey[700],
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "₹${discountPrice.toStringAsFixed(0)}",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 14.sp,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 4.h),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 "₹${originalPrice.toStringAsFixed(0)}",
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 12.sp,
//                                                   color: Colors.grey,
//                                                   decoration: TextDecoration.lineThrough,
//                                                 ),
//                                               ),
//                                               SizedBox(width: 8.w),
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//                                                 decoration: BoxDecoration(
//                                                   color: Color(0xFF3661E2).withOpacity(0.1),
//                                                   borderRadius: BorderRadius.circular(4.r),
//                                                 ),
//                                                 child: Text(
//                                                   "${discountPercentage.toStringAsFixed(0)}% OFF",
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 12.sp,
//                                                     color: Color(0xFF3661E2),
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           "Total for $selectedPatientCount patient${selectedPatientCount == 1 ? '' : 's'}",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12.sp,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           "₹${totalItemPrice.toStringAsFixed(0)}",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 16.sp,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xFF3661E2),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                     // if (cart.items.isNotEmpty) ...[
//                     //   Container(
//                     //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                     //     decoration: BoxDecoration(
//                     //       color: Colors.white,
//                     //       border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//                     //     ),
//                     //     child: Row(
//                     //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     //       children: [
//                     //         Row(
//                     //           children: [
//                     //             Text(
//                     //               "Select: ",
//                     //               style: GoogleFonts.poppins(
//                     //                 fontSize: 14.sp,
//                     //                 color: Colors.grey[700],
//                     //               ),
//                     //             ),
//                     //             TextButton(
//                     //               onPressed: () => cart.selectAllItems(),
//                     //               child: Text(
//                     //                 "All",
//                     //                 style: GoogleFonts.poppins(
//                     //                   fontSize: 14.sp,
//                     //                   color: Color(0xFF3661E2),
//                     //                   fontWeight: FontWeight.w600,
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //             TextButton(
//                     //               onPressed: () => cart.deselectAllItems(),
//                     //               child: Text(
//                     //                 "None",
//                     //                 style: GoogleFonts.poppins(
//                     //                   fontSize: 14.sp,
//                     //                   color: Color(0xFF3661E2),
//                     //                   fontWeight: FontWeight.w600,
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //           ],
//                     //         ),
//                     //         Text(
//                     //           "${cart.selectedItemCount} of ${cart.itemCount} selected",
//                     //           style: GoogleFonts.poppins(
//                     //             fontSize: 14.sp,
//                     //             color: Colors.grey[600],
//                     //           ),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     //   SizedBox(height: 16.h),
//                     // ],
//                     if (cart.items.isNotEmpty) ...[
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 8.r,
//                               offset: Offset(0, 2.h),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Selection controls with improved visual feedback
//                             Row(
//                               children: [
//                                 Text(
//                                   "Select: ",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14.sp,
//                                     color: Colors.grey[700],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 // All button with selection state indicator
//                                 _buildSelectionButton(
//                                   text: "All",
//                                   onPressed: () => cart.selectAllItems(),
//                                   isActive: cart.selectedItemCount == cart.itemCount,
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 // None button with selection state indicator
//                                 _buildSelectionButton(
//                                   text: "None",
//                                   onPressed: () => cart.deselectAllItems(),
//                                   isActive: cart.selectedItemCount == 0,
//                                 ),
//                               ],
//                             ),
//
//                             // Selection counter with progress indicator
//                             Row(
//                               children: [
//                                 // Animated progress indicator
//                                 Container(
//                                   width: 24.w,
//                                   height: 24.h,
//                                   margin: EdgeInsets.only(right: 8.w),
//                                   child: CircularProgressIndicator(
//                                     value: cart.itemCount > 0 ? cart.selectedItemCount / cart.itemCount : 0,
//                                     strokeWidth: 2.w,
//                                     backgroundColor: Colors.grey[200],
//                                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3661E2)),
//                                   ),
//                                 ),
//                                 // Selection count with animation
//                                 AnimatedSwitcher(
//                                   duration: Duration(milliseconds: 300),
//                                   child: Text(
//                                     "${cart.selectedItemCount} of ${cart.itemCount} selected",
//                                     key: ValueKey(cart.selectedItemCount),
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 13.sp,
//                                       color: Colors.grey[700],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                     ],
//                     SizedBox(height: 16.h),
//                     Card(
//                       key: _walletSummaryKey,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Wallet Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             _buildAmountRow(
//                               "Wallet Balance",
//                               "₹${walletAmount.toStringAsFixed(0)}",
//                               Colors.black87,
//                             ),
//
//                             // Only show these if wallet has balance
//                             if (walletAmount > 0) ...[
//                               SizedBox(height: 8.h),
//
//                               // Wallet Points Utilised WITH TOOLTIP
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Wallet Points Utilised",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       _buildInfoTooltip(
//                                         "Amount of wallet points being used from your ${_getOrganizationName(cart)} balance for this order",
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     "₹${walletDiscount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               SizedBox(height: 8.h),
//                               _buildAmountRow(
//                                 "Remaining Wallet Balance",
//                                 "₹${walletAmountAfterDeduction.toStringAsFixed(0)}",
//                                 hasSufficientBalance
//                                     ? Colors.black87
//                                     : Colors.red,
//                                 isBold: true,
//                               ),
//                               if (!hasSufficientBalance)
//                                 Padding(
//                                   padding: EdgeInsets.only(top: 8.h),
//                                   child: Text(
//                                     "Please add funds to your wallet to proceed.",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ),
//                             ] else if (isWalletEnabled &&
//                                 walletAmount == 0) ...[
//                               SizedBox(height: 8.h),
//                               Text(
//                                 "No wallet balance available",
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Price Details",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//
//                             // Calculate total original price and total discount
//                             _buildPriceDetailRow(
//                               "Total Original Price",
//                               "₹${_calculateTotalOriginalPrice(cart).toStringAsFixed(0)}",
//                             ),
//                             SizedBox(height: 4.h),
//                             _buildPriceDetailRow(
//                               "Total Discount",
//                               "-₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                               valueColor: Colors.green,
//                             ),
//                             SizedBox(height: 4.h),
//                             if (cart.requiresHomeCollection)
//                               _buildPriceDetailRow(
//                                 "Home Collection Charge",
//                                 "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                               ),
//                             Divider(height: 16.h, thickness: 1),
//                             _buildPriceDetailRow(
//                               "Subtotal",
//                               "₹${cart.selectedTotalPrice .toStringAsFixed(0)}",
//                               isBold: true,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Card(
//                       key: _orderSummaryKey,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[50]!, Colors.white],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Order Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF3661E2),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             _buildAmountRow(
//                               "Subtotal",
//                               "₹${cart.selectedTotalPrice.toStringAsFixed(0)}",
//                               Colors.black87,
//                             ),
//                             // Only show wallet discount if there's wallet balance
//                             if (walletAmount > 0) ...[
//                               SizedBox(height: 8.h),
//                               // Wallet Points Discount WITH TOOLTIP
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Wallet Points Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       _buildInfoTooltip(
//                                         "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     "-₹${walletDiscount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                             // Only show home collection charge if it's enabled
//                             if (cart.requiresHomeCollection) ...[
//                               SizedBox(height: 8.h),
//                               _buildAmountRow(
//                                 "Home Collection Charge",
//                                 "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                                 Colors.black87,
//                               ),
//                             ],
//                             Divider(height: 16.h, thickness: 1),
//                             _buildAmountRow(
//                               "Amount to Pay",
//                               "₹${payableAmount.toStringAsFixed(0)}",
//                               Color(0xFF3661E2),
//                               isBold: true,
//                             ),
//
//                             // Add savings information
//                             SizedBox(height: 8.h),
//                             Container(
//                               padding: EdgeInsets.all(8.w),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.discount,
//                                     size: 16.w,
//                                     color: Colors.green,
//                                   ),
//                                   SizedBox(width: 4.w),
//                                   Text(
//                                     "You saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12.sp,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SafeArea(
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16.r),
//                       topRight: Radius.circular(16.r),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Home Sample Collection with proper padding
//                       Container(
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: Row(
//                           children: [
//                             // Checkbox
//                             SizedBox(
//                               width: 24.w,
//                               height: 24.w,
//                               child: Checkbox(
//                                 value: cart.requiresHomeCollection,
//                                 onChanged: (bool? value) {
//                                   final newValue = value ?? false;
//                                   cart.setRequiresHomeCollection(newValue);
//                                   if (!newValue) {
//                                     cart.clearHomeCollectionDetails();
//                                   }
//                                 },
//                                 activeColor: Color(0xFF3661E2),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4.r),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             // Text with proper alignment
//                             Expanded(
//                               child: RichText(
//                                 text: TextSpan(
//                                   text: "Home Sample Collection",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF3661E2),
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                       " (+₹${cart.homeCollectionCharge.toStringAsFixed(0)})",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.sp,
//                                         color: Colors.grey[600],
//                                         fontWeight: FontWeight.normal,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Show address and time slot selection only if home collection is required
//                       if (cart.requiresHomeCollection) ...[
//                         SizedBox(height: 16.h),
//                         // Address Selection
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 8.h,
//                             ),
//                             leading: Icon(
//                               Icons.location_on,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             title: Text(
//                               "Delivery Address",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             subtitle: Text(
//                               cart.selectedAddress ?? "Tap to select address",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 color:
//                                 cart.selectedAddress != null
//                                     ? Colors.grey[700]
//                                     : Colors.grey[500],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 18.w,
//                               color: Colors.grey[600],
//                             ),
//                             onTap:
//                                 () => _showAddressSelectionBottomSheet(
//                               context,
//                               cart,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         // Time Slot Selection
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 8.h,
//                             ),
//                             leading: Icon(
//                               Icons.access_time,
//                               color: Color(0xFF3661E2),
//                               size: 24.w,
//                             ),
//                             title: Text(
//                               "Time Slot",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             subtitle: Text(
//                               cart.selectedTimeSlot != null &&
//                                   cart.selectedBookingDate != null
//                                   ? "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}"
//                                   : "Tap to select time slot",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.sp,
//                                 color:
//                                 cart.selectedTimeSlot != null
//                                     ? Colors.grey[700]
//                                     : Colors.grey[500],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 18.w,
//                               color: Colors.grey[600],
//                             ),
//                             onTap:
//                                 () => _showTimeSlotSelectionBottomSheet(
//                               context,
//                               cart,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                         ),
//                       ],
//                       SizedBox(height: 16.h),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           vertical: 12.h,
//                           horizontal: 4.w,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             top: BorderSide(color: Colors.grey[200]!, width: 1),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Only show home collection charge if it's enabled
//                             if (cart.requiresHomeCollection) ...[
//                               _buildAmountRow(
//                                 "Home Collection Charge",
//                                 "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                                 Colors.black87,
//                               ),
//                               SizedBox(height: 8.h),
//                             ],
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // Total Amount Section
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         "Total Amount",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(height: 4.h),
//                                       Text(
//                                         "₹${payableAmount.toStringAsFixed(0)}",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 20.sp,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF3661E2),
//                                         ),
//                                       ),
//                                       SizedBox(height: 4.h),
//                                       Text(
//                                         "Saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12.sp,
//                                           color: Colors.green,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(width: 12.w),
//                                 // Checkout Button
//                                 ElevatedButton(
//                                   onPressed: cart.selectedItemCount > 0 &&
//                                       hasSufficientBalance &&
//                                       (!cart.requiresHomeCollection ||
//                                           (cart.selectedAddress != null &&
//                                               cart.selectedTimeSlot != null &&
//                                               cart.selectedBookingDate != null))
//                                       ? () {
//                                     _showPaymentOptionsDialog(
//                                       context,
//                                       cart,
//                                       payableAmount,
//                                     );
//                                   }
//                                       : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: cart.selectedItemCount > 0 && hasSufficientBalance
//                                         ? Color(0xFF3661E2)
//                                         : Colors.grey[400],
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 20.w,
//                                       vertical: 14.h,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     elevation: cart.selectedItemCount > 0 && hasSufficientBalance ? 2 : 0,
//                                     minimumSize: Size(0, 50.h),
//                                   ),
//                                   child: Text(
//                                     cart.selectedItemCount > 0
//                                         ? (hasSufficientBalance
//                                         ? "Proceed to Checkout"
//                                         : "Insufficient Balance")
//                                         : "Select Items",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//   void _showPaymentOptionsDialog(
//       BuildContext context,
//       CartModel cart,
//       double payableAmount,
//       ) {
//     final isWalletEnabled =
//         cart.items.isNotEmpty && cart.items.first['isWalletEnabled'] == true;
//     final walletBalance = isWalletEnabled ? cart.walletAmount : 0.0;
//
//     // Calculate wallet discount on subtotal (not including home collection)
//     final walletDiscount =
//     isWalletEnabled && walletBalance > 0
//         ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
//         : 0.0;
//
//     final hasSufficientBalance =
//         !isWalletEnabled || walletBalance >= walletDiscount;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (context) {
//           bool isLoading = false;
//
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return Scaffold(
//                 backgroundColor: Colors.grey[200],
//                 appBar: AppBar(
//                   elevation: 0,
//                   backgroundColor: Colors.grey[200],
//                   leading: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Color(0xFF3661E2)),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   title: Text(
//                     "Select Payment Option",
//                     style: GoogleFonts.poppins(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3661E2),
//                     ),
//                   ),
//                   centerTitle: true,
//                 ),
//                 body: SingleChildScrollView(
//                   padding: EdgeInsets.all(16.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Payment Summary Card
//                       Container(
//                         padding: EdgeInsets.all(16.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: Colors.grey[200]!),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Payment Summary",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             SizedBox(height: 16.h),
//
//                             // Subtotal
//                             _buildPaymentRow(
//                               "Subtotal",
//                               "₹${cart.selectedSubtotal.toStringAsFixed(0)}",
//                             ),
//
//                             // Home Collection Charge (if applicable)
//                             if (cart.requiresHomeCollection) ...[
//                               SizedBox(height: 8.h),
//                               _buildPaymentRow(
//                                 "Home Collection Charge",
//                                 "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
//                               ),
//                             ],
//
//                             // Wallet Discount (if applicable)
//                             if (walletDiscount > 0) ...[
//                               SizedBox(height: 8.h),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Wallet Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       _buildInfoTooltip(
//                                         "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     "-₹${walletDiscount.toStringAsFixed(0)}",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14.sp,
//                                       color: Color(0xFF3661E2),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//
//                             // Wallet Balance
//                             if (isWalletEnabled) ...[
//                               SizedBox(height: 8.h),
//                               _buildPaymentRow(
//                                 "Wallet Balance",
//                                 "₹${walletBalance.toStringAsFixed(0)}",
//                                 valueColor: hasSufficientBalance
//                                     ? Colors.green
//                                     : Colors.red,
//                               ),
//                             ],
//
//                             Divider(height: 20.h, thickness: 1),
//
//                             // Total Amount to Pay
//                             _buildPaymentRow(
//                               "Amount to Pay",
//                               "₹${payableAmount.toStringAsFixed(0)}",
//                               isBold: true,
//                               valueColor: Color(0xFF3661E2),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 24.h),
//
//                       // Payment Options
//                       Text(
//                         "Choose Payment Method",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//
//                       if (isLoading)
//                         Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF3661E2),
//                           ),
//                         ),
//
//                       // Pay Later Option
//                       _buildPaymentOptionCard(
//                         context,
//                         icon: Icons.credit_card,
//                         title: "Pay Later",
//                         subtitle: "Pay after service completion",
//                         onTap: isLoading
//                             ? null
//                             : () async {
//                           setState(() => isLoading = true);
//                           final result = await cart.placeOrder('Pay Later');
//                           setState(() => isLoading = false);
//
//                           if (!context.mounted) return;
//                           Navigator.pop(context);
//
//                           if (result['success'] == true) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 fullscreenDialog: true,
//                                 builder: (context) => OrderSuccessPopup(
//                                   onContinue: () {
//                                     Navigator.pushAndRemoveUntil(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => BookingsScreen(
//                                           userModel: userModel,
//                                         ),
//                                       ),
//                                           (route) => route.isFirst,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   result['message'] ?? "Failed to place order",
//                                   style: GoogleFonts.poppins(fontSize: 14.sp),
//                                 ),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           }
//                         },
//                       ),
//
//                       SizedBox(height: 16.h),
//
//                       // Pay Now Option
//                       _buildPaymentOptionCard(
//                         context,
//                         icon: Icons.payment,
//                         title: "Pay Now",
//                         subtitle: "Secure payment via Razorpay",
//                         isDisabled: !hasSufficientBalance,
//                         onTap: isLoading || !hasSufficientBalance
//                             ? null
//                             : () {
//                           Navigator.pop(context);
//                           _initiateRazorpayPayment(cart, payableAmount);
//                         },
//                       ),
//
//                       if (!hasSufficientBalance) ...[
//                         SizedBox(height: 8.h),
//                         Text(
//                           "Insufficient wallet balance to use this option",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12.sp,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//
//                       SizedBox(height: 24.h),
//
//                       // Terms and Conditions
//                       Text(
//                         "By proceeding, you agree to our Terms of Service and Privacy Policy",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12.sp,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//   // void _showPaymentOptionsDialog(
//   //     BuildContext context,
//   //     CartModel cart,
//   //     double payableAmount,
//   //     ) {
//   //   final isWalletEnabled =
//   //       cart.items.isNotEmpty && cart.items.first['isWalletEnabled'] == true;
//   //   final walletBalance = isWalletEnabled ? cart.walletAmount : 0.0;
//   //   final walletDiscount =
//   //   isWalletEnabled && walletBalance > 0
//   //       ? cart.selectedTotalPrice  * (cart.walletDiscountPercentage / 100)
//   //       : 0.0;
//   //   final hasSufficientBalance =
//   //       !isWalletEnabled || walletBalance >= walletDiscount;
//   //
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       fullscreenDialog: true,
//   //       builder: (context) {
//   //         bool isLoading = false;
//   //
//   //         return StatefulBuilder(
//   //           builder: (context, setState) {
//   //             return Scaffold(
//   //               // backgroundColor: Colors.white,
//   //               backgroundColor: Colors.grey[200],
//   //               appBar: AppBar(
//   //                 elevation: 0,
//   //                 backgroundColor: Colors.grey[200],
//   //                 leading: IconButton(
//   //                   icon: Icon(Icons.arrow_back, color: Color(0xFF3661E2)),
//   //                   onPressed: () => Navigator.pop(context),
//   //                 ),
//   //                 title: Text(
//   //                   "Select Payment Option",
//   //                   style: GoogleFonts.poppins(
//   //                     fontSize: 20.sp,
//   //                     fontWeight: FontWeight.bold,
//   //                     color: Color(0xFF3661E2),
//   //                   ),
//   //                 ),
//   //                 centerTitle: true,
//   //               ),
//   //               body: SingleChildScrollView(
//   //                 padding: EdgeInsets.all(16.w),
//   //                 child: Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     // Payment Summary Card
//   //                     Container(
//   //                       padding: EdgeInsets.all(16.w),
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.white,
//   //                         borderRadius: BorderRadius.circular(12.r),
//   //                         border: Border.all(color: Colors.grey[200]!),
//   //                       ),
//   //                       child: Column(
//   //                         crossAxisAlignment: CrossAxisAlignment.start,
//   //                         children: [
//   //                           Text(
//   //                             "Payment Summary",
//   //                             style: GoogleFonts.poppins(
//   //                               fontSize: 16.sp,
//   //                               fontWeight: FontWeight.bold,
//   //                               color: Colors.black87,
//   //                             ),
//   //                           ),
//   //                           SizedBox(height: 16.h),
//   //                           _buildPaymentRow(
//   //                             "Amount to Pay",
//   //                             "₹${payableAmount.toStringAsFixed(0)}",
//   //                             isBold: true,
//   //                           ),
//   //                           if (isWalletEnabled) ...[
//   //                             SizedBox(height: 8.h),
//   //                             _buildPaymentRow(
//   //                               "Wallet Balance",
//   //                               "₹${walletBalance.toStringAsFixed(0)}",
//   //                               valueColor:
//   //                               hasSufficientBalance
//   //                                   ? Colors.green
//   //                                   : Colors.red,
//   //                             ),
//   //                             if (walletBalance > 0) ...[
//   //                               SizedBox(height: 8.h),
//   //                               Row(
//   //                                 mainAxisAlignment:
//   //                                 MainAxisAlignment.spaceBetween,
//   //                                 children: [
//   //                                   Row(
//   //                                     children: [
//   //                                       Text(
//   //                                         "Wallet Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
//   //                                         style: GoogleFonts.poppins(
//   //                                           fontSize: 14.sp,
//   //                                           color: Colors.grey[700],
//   //                                         ),
//   //                                       ),
//   //                                       SizedBox(width: 4.w),
//   //                                       _buildInfoTooltip(
//   //                                         "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                   Text(
//   //                                     "-₹${walletDiscount.toStringAsFixed(0)}",
//   //                                     style: GoogleFonts.poppins(
//   //                                       fontSize: 14.sp,
//   //                                       color: Color(0xFF3661E2),
//   //                                     ),
//   //                                   ),
//   //                                 ],
//   //                               ),
//   //                             ],
//   //                           ] else ...[
//   //                             SizedBox(height: 8.h),
//   //                             _buildPaymentRow(
//   //                               "Wallet",
//   //                               "Disabled",
//   //                               valueColor: Colors.grey,
//   //                             ),
//   //                           ],
//   //                         ],
//   //                       ),
//   //                     ),
//   //                     SizedBox(height: 24.h),
//   //                     // Payment Options
//   //                     Text(
//   //                       "Choose Payment Method",
//   //                       style: GoogleFonts.poppins(
//   //                         fontSize: 16.sp,
//   //                         fontWeight: FontWeight.bold,
//   //                         color: Colors.black87,
//   //                       ),
//   //                     ),
//   //                     SizedBox(height: 16.h),
//   //                     if (isLoading)
//   //                       Center(
//   //                         child: CircularProgressIndicator(
//   //                           color: Color(0xFF3661E2),
//   //                         ),
//   //                       ),
//   //                     // Pay Later Option
//   //                     _buildPaymentOptionCard(
//   //                       context,
//   //                       icon: Icons.credit_card,
//   //                       title: "Pay Later",
//   //                       subtitle: "Pay after service completion",
//   //                       onTap:
//   //                       isLoading
//   //                           ? null
//   //                           : () async {
//   //                         setState(() => isLoading = true);
//   //                         final result = await cart.placeOrder(
//   //                           'Pay Later',
//   //                         );
//   //                         setState(() => isLoading = false);
//   //
//   //                         if (!context.mounted) return;
//   //                         Navigator.pop(context);
//   //
//   //                         if (result['success'] == true) {
//   //                           Navigator.push(
//   //                             context,
//   //                             MaterialPageRoute(
//   //                               fullscreenDialog: true,
//   //                               builder:
//   //                                   (context) => OrderSuccessPopup(
//   //                                 onContinue: () {
//   //                                   Navigator.pushAndRemoveUntil(
//   //                                     context,
//   //                                     MaterialPageRoute(
//   //                                       builder:
//   //                                           (context) =>
//   //                                           BookingsScreen(
//   //                                             userModel:
//   //                                             userModel,
//   //                                           ),
//   //                                     ),
//   //                                         (route) => route.isFirst,
//   //                                   );
//   //                                 },
//   //                               ),
//   //                             ),
//   //                           );
//   //                         } else {
//   //                           ScaffoldMessenger.of(context).showSnackBar(
//   //                             SnackBar(
//   //                               content: Text(
//   //                                 result['message'] ??
//   //                                     "Failed to place order",
//   //                                 style: GoogleFonts.poppins(
//   //                                   fontSize: 14.sp,
//   //                                 ),
//   //                               ),
//   //                               backgroundColor: Colors.red,
//   //                             ),
//   //                           );
//   //                         }
//   //                       },
//   //                     ),
//   //                     SizedBox(height: 16.h),
//   //                     // Pay Now Option
//   //                     _buildPaymentOptionCard(
//   //                       context,
//   //                       icon: Icons.payment,
//   //                       title: "Pay Now",
//   //                       subtitle: "Secure payment via Razorpay",
//   //                       isDisabled: !hasSufficientBalance,
//   //                       onTap:
//   //                       isLoading || !hasSufficientBalance
//   //                           ? null
//   //                           : () {
//   //                         Navigator.pop(context);
//   //                         _initiateRazorpayPayment(cart, payableAmount);
//   //                       },
//   //                     ),
//   //                     if (!hasSufficientBalance) ...[
//   //                       SizedBox(height: 8.h),
//   //                       Text(
//   //                         "Insufficient wallet balance to use this option",
//   //                         style: GoogleFonts.poppins(
//   //                           fontSize: 12.sp,
//   //                           color: Colors.red,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                     SizedBox(height: 24.h),
//   //                     // Terms and Conditions
//   //                     Text(
//   //                       "By proceeding, you agree to our Terms of Service and Privacy Policy",
//   //                       style: GoogleFonts.poppins(
//   //                         fontSize: 12.sp,
//   //                         color: Colors.grey,
//   //                       ),
//   //                       textAlign: TextAlign.center,
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             );
//   //           },
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }
//
//   Widget _buildPaymentRow(
//       String label,
//       String value, {
//         Color valueColor = Colors.black87,
//         bool isBold = false,
//       }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             color: valueColor,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentOptionCard(
//       BuildContext context, {
//         required IconData icon,
//         required String title,
//         required String subtitle,
//         bool isDisabled = false,
//         VoidCallback? onTap,
//       }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: isDisabled ? Colors.grey[100] : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: onTap,
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   color:
//                   isDisabled
//                       ? Colors.grey[300]
//                       : Color(0xFF3661E2).withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   color: isDisabled ? Colors.grey : Color(0xFF3661E2),
//                   size: 24.w,
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: GoogleFonts.poppins(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: isDisabled ? Colors.grey : Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       subtitle,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12.sp,
//                         color: isDisabled ? Colors.grey : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: isDisabled ? Colors.grey : Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _initiateRazorpayPayment(CartModel cart, double payableAmount) {
//     final razorpay = Razorpay();
//     bool isProcessing = false;
//
//     void handlePaymentSuccess(PaymentSuccessResponse response) async {
//       if (isProcessing) return;
//       isProcessing = true;
//
//       final context = _scaffoldKey.currentContext;
//       if (context == null || !context.mounted) {
//         razorpay.clear();
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder:
//             (context) => Center(
//           child: CircularProgressIndicator(color: Color(0xFF3661E2)),
//         ),
//       );
//
//       try {
//         final result = await cart.placeOrder('Pay Now');
//
//         if (!context.mounted) {
//           razorpay.clear();
//           return;
//         }
//
//         if (result['success'] == true) {
//           // Show success popup
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               fullscreenDialog: true,
//               builder:
//                   (context) => OrderSuccessPopup(
//                 onContinue: () {
//                   // Navigate to orders screen
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (context) => BookingsScreen(userModel: userModel),
//                     ),
//                         (route) => route.isFirst,
//                   );
//                 },
//               ),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 result['message'] ?? "Failed to place order after payment",
//                 style: GoogleFonts.poppins(fontSize: 14.sp),
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Error processing order: ${e.toString()}",
//                 style: GoogleFonts.poppins(fontSize: 14.sp),
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         razorpay.clear();
//         isProcessing = false;
//       }
//     }
//
//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
//
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Payment failed: ${response.message}",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       razorpay.clear();
//     });
//
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "External wallet selected: ${response.walletName}",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }
//       razorpay.clear();
//     });
//
//     final options = {
//       'key': 'rzp_test_LeshFtPDPl49hb',
//       'amount': (payableAmount * 100).toInt(),
//       'name': 'Aqure',
//       'description': 'Payment for Aqure',
//       'prefill': {
//         'contact': userModel.currentUser?['contactNumber'] ?? '',
//         'email': userModel.currentUser?['email'] ?? '',
//       },
//     };
//
//     try {
//       razorpay.open(options);
//     } catch (e) {
//       final context = _scaffoldKey.currentContext;
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Error initiating payment: $e",
//               style: GoogleFonts.poppins(fontSize: 14.sp),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       razorpay.clear();
//     }
//   }
//
//   Widget _buildAmountRow(
//       String label,
//       String value,
//       Color color, {
//         bool isBold = false,
//       }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// double _calculateTotalOriginalPrice(CartModel cart) {
//   return cart.items.fold(0.0, (sum, item) {
//     final originalPrice = item['originalPrice'] as double;
//     final quantity = item['quantity'] as int;
//     return sum + (originalPrice * quantity);
//   });
// }
//
// double _calculateTotalDiscount(CartModel cart) {
//   return cart.items.fold(0.0, (sum, item) {
//     final originalPrice = item['originalPrice'] as double;
//     final discountPrice = item['discountPrice'] as double;
//     final quantity = item['quantity'] as int;
//     return sum + ((originalPrice - discountPrice) * quantity);
//   });
// }
//
// Widget _buildPriceDetailRow(
//     String label,
//     String value, {
//       Color valueColor = Colors.black87,
//       bool isBold = false,
//     }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         label,
//         style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
//       ),
//       Text(
//         value,
//         style: GoogleFonts.poppins(
//           fontSize: 14.sp,
//           color: valueColor,
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildInfoTooltip(
//     String message, {
//       Color color = const Color(0xFF3661E2),
//     }) {
//   return Tooltip(
//     message: message,
//     padding: EdgeInsets.all(12.w),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8.r),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 8,
//           spreadRadius: 2,
//         ),
//       ],
//     ),
//     textStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87),
//     child: Icon(Icons.info_outline, size: 16.w, color: color),
//   );
// }
// Widget _buildSelectionButton({
//   required String text,
//   required VoidCallback onPressed,
//   required bool isActive,
// }) {
//   return Container(
//     decoration: BoxDecoration(
//       color: isActive ? Color(0xFF3661E2).withOpacity(0.1) : Colors.transparent,
//       borderRadius: BorderRadius.circular(8.r),
//     ),
//     child: TextButton(
//       onPressed: onPressed,
//       style: TextButton.styleFrom(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: Text(
//         text,
//         style: GoogleFonts.poppins(
//           fontSize: 14.sp,
//           color: isActive ? Color(0xFF3661E2) : Colors.grey[600],
//           fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//         ),
//       ),
//     ),
//   );
// }
// // Helper method to get organization name safely
// String _getOrganizationName(CartModel cart) {
//   if (cart.items.isEmpty) return 'the provider';
//   final organizationName =
//       cart.items.first['organizationName'] ?? cart.items.first['provider'];
//   return organizationName ?? 'the provider';
// }
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/UserModel/user_model.dart';
import '../../models/CartModel/cart_model.dart';
import '../../services/MemberService/AddMemberForm/add_member_form.dart';
import '../../services/MemberService/member_service.dart';
import '../../utils/routes/custom_page_route.dart';
import '../OrderSuccessPopup/order_success_popup.dart';
import '../TestListScreen/TestListDetails/test_list_details.dart';
import 'package:intl/intl.dart';
import '../UserDashboard/BookingsScreen/bookings_screen.dart';

class CartScreen extends StatelessWidget {
  final UserModel userModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MemberService _memberService = MemberService(Dio());

  CartScreen({super.key, required this.userModel});

  void _showPatientSelectionDialog(
      BuildContext context,
      Map<String, dynamic> item,
      CartModel cart,
      ) {
    final selectedPatients = <String, bool>{};
    final primaryMember = userModel.currentUser;
    final children = userModel.children ?? [];
    final itemId = item['itemId'];
    final List<String> previouslySelectedPatientIds = List<String>.from(
      item['selectedPatientIds'] ?? [],
    );

    if (primaryMember == null && children.isEmpty) {
      _showAddMemberForm(context);
      return;
    }

    if (primaryMember != null) {
      selectedPatients[primaryMember['appUserId']
          .toString()] = previouslySelectedPatientIds.contains(
        primaryMember['appUserId'].toString(),
      );
    }
    for (var child in children) {
      selectedPatients[child['appUserId'].toString()] =
          previouslySelectedPatientIds.contains(child['appUserId'].toString());
    }

    final totalMembers = (primaryMember != null ? 1 : 0) + children.length;
    final showAddPatientButton = totalMembers < 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 4,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Patients",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3661E2),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 24.w),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[200], height: 1.h),
                    SizedBox(height: 16.h),
                    Container(
                      constraints: BoxConstraints(maxHeight: 300.h),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (primaryMember != null)
                              _buildPatientTile(
                                context,
                                "${primaryMember['firstName']} ${primaryMember['lastName'] ?? ''}",
                                "(Primary)",
                                selectedPatients[primaryMember['appUserId']
                                    .toString()] ??
                                    false,
                                    (value) {
                                  setState(() {
                                    selectedPatients[primaryMember['appUserId']
                                        .toString()] =
                                        value ?? false;
                                  });
                                },
                              ),
                            ...children
                                .map(
                                  (child) => _buildPatientTile(
                                context,
                                "${child['firstName']} ${child['lastName'] ?? ''}",
                                "",
                                selectedPatients[child['appUserId']
                                    .toString()] ??
                                    false,
                                    (value) {
                                  setState(() {
                                    selectedPatients[child['appUserId']
                                        .toString()] =
                                        value ?? false;
                                  });
                                },
                              ),
                            )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (showAddPatientButton) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMemberForm(context);
                        },
                        icon: Icon(
                          Icons.person_add_outlined,
                          size: 20.w,
                          color: Color(0xFF3661E2),
                        ),
                        label: Text(
                          "Add Patient",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3661E2),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: Color(0xFF3661E2), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              cart.removeFromCart(itemId);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${item['name']} removed from cart",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(color: Colors.red, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              "Remove",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                            selectedPatients.values.any(
                                  (selected) => selected,
                            )
                                ? () {
                              final selectedPatientIds =
                              selectedPatients.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key)
                                  .toList();
                              cart.removeFromCart(itemId);
                              cart.addToCart({
                                ...item,
                                'selectedPatientIds':
                                selectedPatientIds,
                                'quantity': selectedPatientIds.length,
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Patient selection updated for ${item['name']}",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10.r,
                                    ),
                                  ),
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3661E2),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Confirm",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientTile(
      BuildContext context,
      String name,
      String subtitle,
      bool value,
      Function(bool?) onChanged,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: value ? Color(0xFF3661E2).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value ? Color(0xFF3661E2) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: value ? Color(0xFF3661E2) : Colors.black,
          ),
        ),
        subtitle:
        subtitle.isNotEmpty
            ? Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color:
            value
                ? Color(0xFF3661E2).withOpacity(0.8)
                : Colors.grey,
          ),
        )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF3661E2),
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _showAddMemberForm(BuildContext context) {
    final primaryUser = userModel.currentUser;
    if (primaryUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddMemberForm(
          linkingId: primaryUser['appUserId'].toString(),
          memberService: _memberService,
          onMemberAdded: (newMember) {
            // Refresh user data to get the new member
            userModel.getUserByPhone(primaryUser['contactNumber']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Member added successfully'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void _showAddressSelectionBottomSheet(BuildContext context, CartModel cart) {
  //   final primaryUser = userModel.currentUser;
  //   final currentAddress = primaryUser?['address'] ?? '';
  //   final selectedAddress = cart.selectedAddress ?? currentAddress;
  //
  //   final addressController = TextEditingController(text: selectedAddress);
  //   final _formKey = GlobalKey<FormState>();
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(24.r),
  //             topRight: Radius.circular(24.r),
  //           ),
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom,
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               // Header
  //               Container(
  //                 padding: EdgeInsets.all(20.w),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFF3661E2),
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(24.r),
  //                     topRight: Radius.circular(24.r),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       "Select Address",
  //                       style: GoogleFonts.poppins(
  //                         fontSize: 18.sp,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: Icon(
  //                         Icons.close,
  //                         size: 24.w,
  //                         color: Colors.white,
  //                       ),
  //                       onPressed: () => Navigator.pop(context),
  //                       padding: EdgeInsets.zero,
  //                       constraints: BoxConstraints(),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               // Content
  //               Padding(
  //                 padding: EdgeInsets.all(20.w),
  //                 child: Form(
  //                   key: _formKey,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         "Delivery Address",
  //                         style: GoogleFonts.poppins(
  //                           fontSize: 16.sp,
  //                           fontWeight: FontWeight.w600,
  //                           color: Colors.black87,
  //                         ),
  //                       ),
  //                       SizedBox(height: 12.h),
  //                       Text(
  //                         "Enter the address where you'd like your samples to be collected",
  //                         style: GoogleFonts.poppins(
  //                           fontSize: 12.sp,
  //                           color: Colors.grey[600],
  //                         ),
  //                       ),
  //                       SizedBox(height: 20.h),
  //
  //                       // Address Input Field
  //                       Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(12.r),
  //                           border: Border.all(
  //                             color: Colors.grey[300]!,
  //                             width: 1,
  //                           ),
  //                         ),
  //                         child: TextFormField(
  //                           controller: addressController,
  //                           maxLines: 4,
  //                           minLines: 3,
  //                           decoration: InputDecoration(
  //                             hintText: "Enter your complete address...",
  //                             hintStyle: GoogleFonts.poppins(
  //                               fontSize: 14.sp,
  //                               color: Colors.grey[500],
  //                             ),
  //                             border: InputBorder.none,
  //                             contentPadding: EdgeInsets.all(16.w),
  //                             prefixIcon: Icon(
  //                               Icons.location_on,
  //                               color: Color(0xFF3661E2),
  //                               size: 25.w,
  //                             ),
  //                           ),
  //                           style: GoogleFonts.poppins(
  //                             fontSize: 14.sp,
  //                             color: Colors.black87,
  //                           ),
  //                           validator: (value) {
  //                             if (value == null || value.trim().isEmpty) {
  //                               return 'Please enter your address';
  //                             }
  //                             if (value.trim().length < 4) {
  //                               return 'Please enter a complete address';
  //                             }
  //                             return null;
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 24.h),
  //
  //                       // Action Buttons
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: OutlinedButton(
  //                               onPressed: () => Navigator.pop(context),
  //                               style: OutlinedButton.styleFrom(
  //                                 padding: EdgeInsets.symmetric(vertical: 14.h),
  //                                 side: BorderSide(
  //                                   color: Colors.grey[400]!,
  //                                   width: 1.5,
  //                                 ),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(12.r),
  //                                 ),
  //                                 backgroundColor: Colors.grey[50],
  //                               ),
  //                               child: Text(
  //                                 "Cancel",
  //                                 style: GoogleFonts.poppins(
  //                                   fontSize: 14.sp,
  //                                   fontWeight: FontWeight.w500,
  //                                   color: Colors.grey[700],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(width: 16.w),
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               onPressed: () {
  //                                 if (_formKey.currentState?.validate() ??
  //                                     false) {
  //                                   cart.setSelectedAddress(
  //                                     addressController.text.trim(),
  //                                   );
  //                                   Navigator.pop(context);
  //                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                     SnackBar(
  //                                       content: Text(
  //                                         "Address saved successfully",
  //                                         style: GoogleFonts.poppins(),
  //                                       ),
  //                                       backgroundColor: Color(0xFF3661E2),
  //                                       behavior: SnackBarBehavior.floating,
  //                                       shape: RoundedRectangleBorder(
  //                                         borderRadius: BorderRadius.circular(
  //                                           10.r,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   );
  //                                 }
  //                               },
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: Color(0xFF3661E2),
  //                                 padding: EdgeInsets.symmetric(vertical: 14.h),
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(12.r),
  //                                 ),
  //                                 elevation: 2,
  //                               ),
  //                               child: Text(
  //                                 "Save Address",
  //                                 style: GoogleFonts.poppins(
  //                                   fontSize: 14.sp,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showAddressSelectionBottomSheet(BuildContext context, CartModel cart) {
    final primaryUser = userModel.currentUser;
    final currentAddress = primaryUser?['address'] ?? '';
    final selectedAddress = cart.selectedAddress ?? currentAddress;

    final addressController = TextEditingController(text: selectedAddress);
    final _formKey = GlobalKey<FormState>();
    final String googleApiKey = 'AIzaSyC1GFWUpVW3J66nMDFhOHm09yRGFESAlVM';
    final Dio _dio = Dio();

    // Function to fetch autocomplete predictions using Dio
    Future<List<Map<String, dynamic>>> _fetchPlacePredictions(String input, CancelToken cancelToken) async {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': input,
            'key': googleApiKey,
            'components': 'country:in',
            'language': 'en',
          },
          options: Options(
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
          cancelToken: cancelToken,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK') {
            final predictions = data['predictions'] as List;
            return predictions.map<Map<String, dynamic>>((prediction) {
              return {
                'description': prediction['description'],
                'place_id': prediction['place_id'],
              };
            }).toList();
          }
        }
        return [];
      } on DioException catch (e) {
        if (e.type != DioExceptionType.cancel) {
          print('DioError fetching predictions: ${e.message}');
        }
        return [];
      } catch (e) {
        print('Error fetching predictions: $e');
        return [];
      }
    }

    // Function to get place details using Dio
    Future<String> _getPlaceDetails(String placeId, CancelToken cancelToken) async {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/details/json',
          queryParameters: {
            'place_id': placeId,
            'key': googleApiKey,
            'language': 'en',
          },
          options: Options(
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
          cancelToken: cancelToken,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK') {
            return data['result']['formatted_address'] ?? '';
          }
        }
        return '';
      } on DioException catch (e) {
        if (e.type != DioExceptionType.cancel) {
          print('DioError fetching place details: ${e.message}');
        }
        return '';
      } catch (e) {
        print('Error fetching place details: $e');
        return '';
      }
    }

    // Function to show autocomplete dialog
    Future<void> _showAutocompleteDialog(BuildContext context) async {
      final searchController = TextEditingController();
      List<Map<String, dynamic>> predictions = [];
      bool isLoading = false;
      bool isDialogOpen = true;
      final CancelToken cancelToken = CancelToken();
      bool isTokenCancelled = false; // Track if token is already cancelled

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (stateContext, setState) {
              // Helper function to safely close dialog
              void safePopDialog() {
                if (isDialogOpen && Navigator.of(stateContext).canPop()) {
                  isDialogOpen = false;
                  if (!isTokenCancelled) {
                    isTokenCancelled = true;
                    cancelToken.cancel('Dialog closed by user');
                  }
                  Navigator.of(stateContext).pop();
                }
              }

              // Function to safely cancel token
              void safeCancelToken([String reason = 'Dialog closed']) {
                if (!isTokenCancelled) {
                  isTokenCancelled = true;
                  cancelToken.cancel(reason);
                }
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                backgroundColor: Colors.grey[200],
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  width: MediaQuery.of(stateContext).size.width * 0.9,
                  height: MediaQuery.of(stateContext).size.height * 0.7,
                  child: Column(
                    children: [
                      // Search Header
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, size: 24.w, color: Color(0xFF3661E2)),
                            onPressed: safePopDialog,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              "Search Address",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3661E2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Search Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search for address...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.w),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, size: 18.w),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  predictions.clear();
                                  isLoading = false;
                                });
                              },
                            )
                                : null,
                          ),
                          onChanged: (value) async {
                            if (value.length > 2) {
                              setState(() => isLoading = true);
                              final results = await _fetchPlacePredictions(value, cancelToken);
                              // Only update state if dialog is still open
                              if (isDialogOpen) {
                                setState(() {
                                  predictions = results;
                                  isLoading = false;
                                });
                              }
                            } else {
                              setState(() {
                                predictions.clear();
                                isLoading = false;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Loading Indicator
                      if (isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF3661E2),
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Searching...",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Predictions List
                      Expanded(
                        child: isLoading
                            ? SizedBox()
                            : predictions.isEmpty
                            ? Center(
                          child: Text(
                            searchController.text.isEmpty
                                ? "Start typing to search for addresses"
                                : "No results found",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: predictions.length,
                          itemBuilder: (context, index) {
                            final prediction = predictions[index];
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: Color(0xFF3661E2),
                                size: 24.w,
                              ),
                              title: Text(
                                prediction['description'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () async {
                                setState(() => isLoading = true);
                                final address = await _getPlaceDetails(prediction['place_id'], cancelToken);

                                // Check if the dialog is still open before updating
                                if (isDialogOpen && Navigator.of(stateContext).canPop()) {
                                  setState(() => isLoading = false);

                                  if (address.isNotEmpty) {
                                    addressController.text = address;
                                  } else {
                                    addressController.text = prediction['description'];
                                  }
                                  safePopDialog();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).then((_) {
        // This runs when the dialog is closed (by any means)
        isDialogOpen = false;
        if (!isTokenCancelled) {
          isTokenCancelled = true;
          cancelToken.cancel('Dialog closed externally');
        }
      }).catchError((error) {
        // Handle any errors that might occur during dialog closing
        isDialogOpen = false;
        if (!isTokenCancelled) {
          isTokenCancelled = true;
          cancelToken.cancel('Dialog closed with error: $error');
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF3661E2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Address",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24.w,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivery Address",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Enter the address where you'd like your samples to be collected",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Address Input Field with Google Places Search
                        InkWell(
                          onTap: () => _showAutocompleteDialog(context),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: addressController,
                                    maxLines: 3,
                                    minLines: 3,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      hintText: "Tap to search for address...",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.grey[500],
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16.w),
                                      prefixIcon: Icon(
                                        Icons.location_on,
                                        color: Color(0xFF3661E2),
                                        size: 25.w,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please select an address';
                                      }
                                      if (value.trim().length < 4) {
                                        return 'Please select a complete address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xFF3661E2),
                                    size: 24.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Or enter manually:",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            maxLines: 4,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: "Enter address manually...",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                            onChanged: (value) {
                              addressController.text = value;
                            },
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  backgroundColor: Colors.grey[50],
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    cart.setSelectedAddress(
                                      addressController.text.trim(),
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Address saved successfully",
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Color(0xFF3661E2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3661E2),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  "Save Address",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimeSlotSelectionBottomSheet(BuildContext context, CartModel cart) {
    if (cart.timeSlots.isEmpty) {
      cart.fetchTimeSlots();
    }

    // Set today's date as default if not already set
    if (cart.selectedBookingDate == null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      cart.setSelectedBookingDate(today);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Consumer<CartModel>(  // Add this Consumer here
                builder: (context, cart, child) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF3661E2),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Select Time Slot",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 24.w,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Picker Section
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18.w,
                                          color: Color(0xFF3661E2),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Select Date",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    InkWell(
                                      onTap: () async {
                                        final selectedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(Duration(days: 30)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Color(0xFF3661E2),
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                dialogBackgroundColor: Colors.white,
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (selectedDate != null) {
                                          final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                                          cart.setSelectedBookingDate(formattedDate);

                                          // Refresh time slots with new date
                                          cart.fetchTimeSlots();
                                          setState(() {});
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(
                                              0xFF3661E2,
                                            ).withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Selected Date",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    _formatDisplayDate(
                                                      cart.selectedBookingDate,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF3661E2),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  0xFF3661E2,
                                                ).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 18.w,
                                                color: Color(0xFF3661E2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Time Slots Section
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18.w,
                                          color: Color(0xFF3661E2),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Available Time Slots",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        if (cart.isLoadingTimeSlots)
                                          SizedBox(
                                            width: 16.w,
                                            height: 16.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF3661E2),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),

                                    if (cart.isLoadingTimeSlots)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 40.h,
                                        ),
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(
                                              color: Color(0xFF3661E2),
                                              strokeWidth: 3,
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              "Loading available slots...",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (cart.timeSlots.isEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 40.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 48.w,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              "No time slots available",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Please try another date",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                color: Colors.grey[500],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        constraints: BoxConstraints(maxHeight: 200.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          itemCount: cart.timeSlots.length,
                                          itemBuilder: (context, index) {
                                            final slot = cart.timeSlots[index];
                                            final isSelected = cart.selectedTimeSlot == slot['slotName'];
                                            final isAvailable = slot['available'] != false;

                                            return InkWell(
                                              onTap: isAvailable ? () {
                                                cart.setSelectedTimeSlot(slot['slotName']!);
                                                setState(() {});
                                              } : null,
                                              child: Container(
                                                padding: EdgeInsets.all(16.w),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Color(0xFF3661E2).withOpacity(0.1)
                                                      : Colors.white,
                                                  border: Border(
                                                    bottom: index < cart.timeSlots.length - 1
                                                        ? BorderSide(color: Colors.grey[100]!, width: 1)
                                                        : BorderSide.none,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Selection Indicator
                                                    Container(
                                                      width: 22.w,
                                                      height: 22.w,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? Color(0xFF3661E2)
                                                              : isAvailable
                                                              ? Colors.grey[400]!
                                                              : Colors.grey[300]!,
                                                          width: 2,
                                                        ),
                                                        color: isSelected ? Color(0xFF3661E2) : Colors.transparent,
                                                      ),
                                                      child: isSelected
                                                          ? Icon(Icons.check, size: 14.w, color: Colors.white)
                                                          : null,
                                                    ),
                                                    SizedBox(width: 16.w),

                                                    // Slot Info
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            slot['slotName'] ?? 'Unknown Slot',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 15.sp,
                                                              fontWeight: FontWeight.w500,
                                                              color: isSelected
                                                                  ? Color(0xFF3661E2)
                                                                  : isAvailable
                                                                  ? Colors.black87
                                                                  : Colors.grey[400]!,
                                                            ),
                                                          ),
                                                          if (slot['timing'] != null)
                                                            Text(
                                                              slot['timing'],
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12.sp,
                                                                color: isAvailable
                                                                    ? Colors.grey[600]
                                                                    : Colors.grey[400],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Availability Status
                                                    if (!isAvailable)
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6.r),
                                                          border: Border.all(
                                                            color: Colors.red.withOpacity(0.3),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "Passed",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 11.sp,
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Selected Info Banner
                              if (cart.selectedTimeSlot != null &&
                                  cart.selectedBookingDate != null)
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3661E2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Color(0xFF3661E2).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 20.w,
                                        color: Color(0xFF3661E2),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Selected Time Slot",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF3661E2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 24.h),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        backgroundColor: Colors.grey[50],
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                      cart.selectedTimeSlot != null &&
                                          cart.selectedBookingDate != null
                                          ? () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Time slot selected successfully",
                                              style: GoogleFonts.poppins(),
                                            ),
                                            behavior:
                                            SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                10.r,
                                              ),
                                            ),
                                            backgroundColor: Color(
                                              0xFF3661E2,
                                            ),
                                          ),
                                        );
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF3661E2),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: Text(
                                        "Confirm Slot",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
  String _formatDisplayDate(String? dateString) {
    if (dateString == null) return "Select a date";

    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      final today = DateTime.now();
      final tomorrow = today.add(Duration(days: 1));

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return "Today, ${DateFormat('MMM dd, yyyy').format(date)}";
      } else if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        return "Tomorrow, ${DateFormat('MMM dd, yyyy').format(date)}";
      } else {
        return DateFormat('EEE, MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final ScrollController _scrollController = ScrollController();
  //   final GlobalKey _walletSummaryKey = GlobalKey();
  //   final GlobalKey _orderSummaryKey = GlobalKey();
  //
  //   return Scaffold(
  //     key: _scaffoldKey,
  //     backgroundColor: Colors.grey[200],
  //     appBar: AppBar(
  //       elevation: 0,
  //       backgroundColor: Colors.grey[200],
  //       title: Consumer<CartModel>(
  //         builder: (context, cart, child) => Text(
  //           "Cart (${cart.selectedItemCount}/${cart.itemCount})",
  //           style: GoogleFonts.poppins(
  //             fontSize: 20.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF3661E2),
  //           ),
  //         ),
  //       ),
  //       iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
  //     ),
  //     body: Consumer<CartModel>(
  //       builder: (context, cart, child) {
  //         if (cart.items.isEmpty) {
  //           return Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(
  //                   Icons.shopping_cart_outlined,
  //                   size: 80.w,
  //                   color: Colors.grey[400],
  //                 ),
  //                 SizedBox(height: 16.h),
  //                 Text(
  //                   "Your Cart is Empty",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 18.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.grey[600],
  //                   ),
  //                 ),
  //                 SizedBox(height: 8.h),
  //                 Text(
  //                   "Add some tests to get started",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 14.sp,
  //                     color: Colors.grey[500],
  //                   ),
  //                 ),
  //                 SizedBox(height: 24.h),
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Color(0xFF3661E2),
  //                     padding: EdgeInsets.symmetric(
  //                       horizontal: 24.w,
  //                       vertical: 12.h,
  //                     ),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.r),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     "Browse Tests",
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 14.sp,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }
  //
  //         final isWalletEnabled =
  //             cart.items.isNotEmpty &&
  //                 cart.items.first['isWalletEnabled'] == true;
  //         final walletAmount = isWalletEnabled ? cart.walletAmount : 0.0;
  //
  //         final walletDiscount = isWalletEnabled && walletAmount > 0
  //             ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
  //             : 0.0;
  //
  //         final payableAmount = (cart.selectedSubtotal - walletDiscount) +
  //             (cart.requiresHomeCollection ? cart.homeCollectionCharge : 0);
  //         final walletAmountAfterDeduction =
  //         isWalletEnabled ? walletAmount - walletDiscount : 0.0;
  //         final hasSufficientBalance =
  //             !isWalletEnabled || walletAmountAfterDeduction >= 0;
  //
  //         return Column(
  //             children: [
  //             Expanded(
  //               child: ListView(
  //                 controller: _scrollController,
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 16.w,
  //                   vertical: 16.h,
  //                 ),
  //                 children: [
  //                   ...List.generate(cart.items.length, (index) {
  //                     final item = cart.items[index];
  //                     final itemId = item['itemId'];
  //                     final isSelected = cart.isItemSelected(itemId);
  //                     final quantity = item['quantity'] as int;
  //                     final discountPrice = item["discountPrice"] as double;
  //                     final originalPrice = item["originalPrice"] as double;
  //                     final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();
  //                     final totalItemPrice = discountPrice * quantity;
  //                     final selectedPatientCount = (item['selectedPatientIds'] as List?)?.length ?? 0;
  //
  //                     return GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(
  //                           context,
  //                           CustomPageRoute(
  //                             child: TestListDetails(
  //                               test: item,
  //                               provider: item["provider"],
  //                               service: item["service"],
  //                               userModel: userModel,
  //                             ),
  //                             direction: AxisDirection.right,
  //                           ),
  //                         );
  //                       },
  //                       child: Card(
  //                         elevation: isSelected ? 4 : 2,
  //                         margin: EdgeInsets.only(bottom: 12.h),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(16.r),
  //                           side: BorderSide(
  //                             color: isSelected ? Color(0xFF3661E2) : Colors.grey[200]!,
  //                             width: isSelected ? 2 : 1,
  //                           ),
  //                         ),
  //                         child: Container(
  //                           padding: EdgeInsets.all(16.w),
  //                           decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(16.r),
  //                               color: Colors.white
  //                           ),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                             // Header row with test icon and select patients button
  //                             Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               // Test icon
  //                               Container(
  //                                 padding: EdgeInsets.all(8.w),
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey.shade300,
  //                                   shape: BoxShape.circle,
  //                                 ),
  //                                 child: Icon(
  //                                   Icons.science,
  //                                   color: Color(0xFF3661E2),
  //                                   size: 25.w,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 12.w),
  //
  //                               // Test name and provider
  //                               Expanded(
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       item["name"],
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 18.sp,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Color(0xFF3661E2),
  //                                       ),
  //                                       maxLines: 2,
  //                                       overflow: TextOverflow.ellipsis,
  //                                     ),
  //                                     SizedBox(height: 4.h),
  //                                     Text(
  //                                       "Provider: ${item['provider']}",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 14.sp,
  //                                         color: Colors.black,
  //                                       ),
  //                                       maxLines: 1,
  //                                       overflow: TextOverflow.ellipsis,
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //
  //                               // Select Patients button
  //                               ElevatedButton(
  //                                 onPressed: () => _showPatientSelectionDialog(
  //                                   context,
  //                                   item,
  //                                   cart,
  //                                 ),
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: selectedPatientCount > 0
  //                                       ? Colors.white
  //                                       : Color(0xFF3661E2),
  //                                   padding: EdgeInsets.symmetric(
  //                                     horizontal: 16.w,
  //                                     vertical: 10.h,
  //                                   ),
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(8.r),
  //                                     side: selectedPatientCount > 0
  //                                         ? BorderSide(
  //                                       color: Color(0xFF3661E2),
  //                                       width: 1,
  //                                     )
  //                                         : BorderSide.none,
  //                                   ),
  //                                   elevation: 0,
  //                                 ),
  //                                 child: Text(
  //                                   selectedPatientCount > 0
  //                                       ? "$selectedPatientCount"
  //                                       : "Select",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 14.sp,
  //                                     fontWeight: FontWeight.w600,
  //                                     color: selectedPatientCount > 0
  //                                         ? Color(0xFF3661E2)
  //                                         : Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //
  //                           SizedBox(height: 12.h),
  //
  //                           // Price information
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             crossAxisAlignment: CrossAxisAlignment.end,
  //                             children: [
  //                               Expanded(
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: [
  //                                     Row(
  //                                       children: [
  //                                         Text(
  //                                           "Price per patient: ",
  //                                           style: GoogleFonts.poppins(
  //                                             fontSize: 14.sp,
  //                                             color: Colors.grey[700],
  //                                           ),
  //                                         ),
  //                                         Text(
  //                                           "₹${discountPrice.toStringAsFixed(0)}",
  //                                           style: GoogleFonts.poppins(
  //                                             fontSize: 14.sp,
  //                                             fontWeight: FontWeight.w600,
  //                                             color: Colors.black87,
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                     SizedBox(height: 4.h),
  //                                     Row(
  //                                       children: [
  //                                         Text(
  //                                           "₹${originalPrice.toStringAsFixed(0)}",
  //                                           style: GoogleFonts.poppins(
  //                                             fontSize: 12.sp,
  //                                             color: Colors.grey,
  //                                             decoration: TextDecoration.lineThrough,
  //                                           ),
  //                                         ),
  //                                         SizedBox(width: 8.w),
  //                                         Container(
  //                                           padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //                                           decoration: BoxDecoration(
  //                                             color: Color(0xFF3661E2).withOpacity(0.1),
  //                                             borderRadius: BorderRadius.circular(4.r),
  //                                           ),
  //                                           child: Text(
  //                                             "${discountPercentage.toStringAsFixed(0)}% OFF",
  //                                             style: GoogleFonts.poppins(
  //                                               fontSize: 12.sp,
  //                                               color: Color(0xFF3661E2),
  //                                               fontWeight: FontWeight.w600,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //
  //                               Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.end,
  //                                 children: [
  //                                   Text(
  //                                     "Total for $selectedPatientCount patient${selectedPatientCount == 1 ? '' : 's'}",
  //                                     style: GoogleFonts.poppins(
  //                                       fontSize: 12.sp,
  //                                       color: Colors.grey[600],
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 4.h),
  //                                   Text(
  //                                     "₹${totalItemPrice.toStringAsFixed(0)}",
  //                                     style: GoogleFonts.poppins(
  //                                       fontSize: 16.sp,
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Color(0xFF3661E2),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //
  //                           SizedBox(height: 4.h),
  //                           Container(
  //                             padding: EdgeInsets.only(top: 2.h),
  //                             decoration: BoxDecoration(
  //                               border: Border(
  //                                 top: BorderSide(
  //                                   color: Colors.grey[200]!,
  //                                   width: 1,
  //                                 ),
  //                               ),
  //                             ),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               // Checkbox for selection
  //                               Row(
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 24.w,
  //                                     height: 24.w,
  //                                     child: Checkbox(
  //                                       value: isSelected,
  //                                       onChanged: (value) {
  //                                         cart.toggleItemSelection(itemId, value ?? false);
  //                                       },
  //                                       activeColor: Color(0xFF3661E2),
  //                                       shape: RoundedRectangleBorder(
  //                                         borderRadius: BorderRadius.circular(6.r),
  //                                       ),
  //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                     ),
  //                                   ),
  //                                   SizedBox(width: 8.w),
  //                                   Text(
  //                                     "Select this item",
  //                                     style: GoogleFonts.poppins(
  //                                       fontSize: 14.sp,
  //                                       color: Colors.grey[700],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //
  //                               // Remove button
  //                               TextButton(
  //                                 onPressed: () {
  //                                   cart.removeFromCart(itemId);
  //                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                     SnackBar(
  //                                       content: Text(
  //                                         "${item['name']} removed from cart",
  //                                       ),
  //                                       behavior: SnackBarBehavior.floating,
  //                                       shape: RoundedRectangleBorder(
  //                                         borderRadius: BorderRadius.circular(10.r),
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                                 style: TextButton.styleFrom(
  //                                   foregroundColor: Colors.red,
  //                                   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //                                 ),
  //                                 child: Row(
  //                                   children: [
  //                                     Icon(Icons.delete_outline, size: 18.w),
  //                                     SizedBox(width: 4.w),
  //                                     Text(
  //                                       "Remove",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 14.sp,
  //                                         fontWeight: FontWeight.w500,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         ],
  //                       ),
  //                     ),
  //                     ),
  //                     );
  //                   }),
  //                   if (cart.items.isNotEmpty) ...[
  //                     Container(
  //                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.black.withOpacity(0.05),
  //                             blurRadius: 8.r,
  //                             offset: Offset(0, 2.h),
  //                           ),
  //                         ],
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           // Selection controls with improved visual feedback
  //                           Row(
  //                             children: [
  //                               Text(
  //                                 "Select: ",
  //                                 style: GoogleFonts.poppins(
  //                                   fontSize: 14.sp,
  //                                   color: Colors.grey[700],
  //                                   fontWeight: FontWeight.w500,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 4.w),
  //                               // All button with selection state indicator
  //                               _buildSelectionButton(
  //                                 text: "All",
  //                                 onPressed: () => cart.selectAllItems(),
  //                                 isActive: cart.selectedItemCount == cart.itemCount,
  //                               ),
  //                               SizedBox(width: 8.w),
  //                               // None button with selection state indicator
  //                               _buildSelectionButton(
  //                                 text: "None",
  //                                 onPressed: () => cart.deselectAllItems(),
  //                                 isActive: cart.selectedItemCount == 0,
  //                               ),
  //                             ],
  //                           ),
  //
  //                           // Selection counter with progress indicator
  //                           Row(
  //                             children: [
  //                               AnimatedSwitcher(
  //                                 duration: Duration(milliseconds: 300),
  //                                 child: Text(
  //                                   "${cart.selectedItemCount} of ${cart.itemCount} selected",
  //                                   key: ValueKey(cart.selectedItemCount),
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 13.sp,
  //                                     color: Colors.grey[700],
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 16.h),
  //                   ],
  //                   SizedBox(height: 16.h),
  //         if (cart.selectedItemCount > 0) ...[
  //                   Card(
  //                     key: _walletSummaryKey,
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.r),
  //                     ),
  //                     child: Container(
  //                       padding: EdgeInsets.all(12.w),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         gradient: LinearGradient(
  //                           colors: [Colors.grey[50]!, Colors.white],
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                         ),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "Wallet Summary",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: Color(0xFF3661E2),
  //                             ),
  //                           ),
  //                           SizedBox(height: 8.h),
  //                           _buildAmountRow(
  //                             "Wallet Balance",
  //                             "₹${walletAmount.toStringAsFixed(0)}",
  //                             Colors.black87,
  //                           ),
  //
  //                           // Only show these if wallet has balance
  //                           if (walletAmount > 0) ...[
  //                             SizedBox(height: 8.h),
  //
  //                             // Wallet Points Utilised WITH TOOLTIP
  //                             Row(
  //                               mainAxisAlignment:
  //                               MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Text(
  //                                       "Wallet Points Utilised",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 14.sp,
  //                                         color: Colors.grey[700],
  //                                       ),
  //                                     ),
  //                                     SizedBox(width: 4.w),
  //                                     _buildInfoTooltip(
  //                                       "Amount of wallet points being used from your ${_getOrganizationName(cart)} balance for this order",
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Text(
  //                                   "₹${walletDiscount.toStringAsFixed(0)}",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 14.sp,
  //                                     color: Color(0xFF3661E2),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //
  //                             SizedBox(height: 8.h),
  //                             _buildAmountRow(
  //                               "Remaining Wallet Balance",
  //                               "₹${walletAmountAfterDeduction.toStringAsFixed(0)}",
  //                               hasSufficientBalance
  //                                   ? Colors.black87
  //                                   : Colors.red,
  //                               isBold: true,
  //                             ),
  //                             if (!hasSufficientBalance)
  //                               Padding(
  //                                 padding: EdgeInsets.only(top: 8.h),
  //                                 child: Text(
  //                                   "Please add funds to your wallet to proceed.",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 12.sp,
  //                                     color: Colors.red,
  //                                   ),
  //                                 ),
  //                               ),
  //                           ] else if (isWalletEnabled &&
  //                               walletAmount == 0) ...[
  //                             SizedBox(height: 8.h),
  //                             Text(
  //                               "No wallet balance available",
  //                               style: GoogleFonts.poppins(
  //                                 fontSize: 12.sp,
  //                                 color: Colors.grey[600],
  //                               ),
  //                             ),
  //                           ],
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 16.h),
  //                   Card(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.r),
  //                     ),
  //                     child: Container(
  //                       padding: EdgeInsets.all(12.w),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         gradient: LinearGradient(
  //                           colors: [Colors.grey[50]!, Colors.white],
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                         ),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "Price Details",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: Color(0xFF3661E2),
  //                             ),
  //                           ),
  //                           SizedBox(height: 8.h),
  //
  //                           // Calculate total original price and total discount
  //                           _buildPriceDetailRow(
  //                             "Total Original Price",
  //                             "₹${_calculateTotalOriginalPrice(cart).toStringAsFixed(0)}",
  //                           ),
  //                           SizedBox(height: 4.h),
  //                           _buildPriceDetailRow(
  //                             "Total Discount",
  //                             "-₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
  //                             valueColor: Colors.green,
  //                           ),
  //                           SizedBox(height: 4.h),
  //                           if (cart.requiresHomeCollection)
  //                             _buildPriceDetailRow(
  //                               "Home Collection Charge",
  //                               "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
  //                             ),
  //                           Divider(height: 16.h, thickness: 1),
  //                           _buildPriceDetailRow(
  //                             "Subtotal",
  //                             "₹${cart.selectedTotalPrice .toStringAsFixed(0)}",
  //                             isBold: true,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 16.h),
  //                   Card(
  //                     key: _orderSummaryKey,
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.r),
  //                     ),
  //                     child: Container(
  //                       padding: EdgeInsets.all(12.w),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         gradient: LinearGradient(
  //                           colors: [Colors.grey[50]!, Colors.white],
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                         ),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             "Order Summary",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: Color(0xFF3661E2),
  //                             ),
  //                           ),
  //                           SizedBox(height: 8.h),
  //                           _buildAmountRow(
  //                             "Subtotal",
  //                             "₹${cart.selectedTotalPrice.toStringAsFixed(0)}",
  //                             Colors.black87,
  //                           ),
  //                           // Only show wallet discount if there's wallet balance
  //                           if (walletAmount > 0) ...[
  //                             SizedBox(height: 8.h),
  //                             // Wallet Points Discount WITH TOOLTIP
  //                             Row(
  //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Text(
  //                                       "Wallet Points Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 14.sp,
  //                                         color: Colors.grey[700],
  //                                       ),
  //                                     ),
  //                                     SizedBox(width: 4.w),
  //                                     _buildInfoTooltip(
  //                                       "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Text(
  //                                   "-₹${walletDiscount.toStringAsFixed(0)}",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 14.sp,
  //                                     color: Color(0xFF3661E2),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                           // Only show home collection charge if it's enabled
  //                           if (cart.requiresHomeCollection) ...[
  //                             SizedBox(height: 8.h),
  //                             _buildAmountRow(
  //                               "Home Collection Charge",
  //                               "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
  //                               Colors.black87,
  //                             ),
  //                           ],
  //                           Divider(height: 16.h, thickness: 1),
  //                           _buildAmountRow(
  //                             "Amount to Pay",
  //                             "₹${payableAmount.toStringAsFixed(0)}",
  //                             Color(0xFF3661E2),
  //                             isBold: true,
  //                           ),
  //
  //                           // Add savings information
  //                           SizedBox(height: 8.h),
  //                           Container(
  //                             padding: EdgeInsets.all(8.w),
  //                             decoration: BoxDecoration(
  //                               color: Colors.green.withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(8.r),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(
  //                                   Icons.discount,
  //                                   size: 16.w,
  //                                   color: Colors.green,
  //                                 ),
  //                                 SizedBox(width: 4.w),
  //                                 Text(
  //                                   "You saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 12.sp,
  //                                     color: Colors.green,
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //         ],
  //               ),
  //             ),
  //             SafeArea(
  //               child: cart.selectedItemCount > 0 ? Container(
  //                 padding: EdgeInsets.all(16.w),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(16.r),
  //                     topRight: Radius.circular(16.r),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.grey.withOpacity(0.2),
  //                       blurRadius: 8,
  //                       spreadRadius: 1,
  //                       offset: const Offset(0, -2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Home Sample Collection with proper padding
  //                     Container(
  //                       padding: EdgeInsets.symmetric(vertical: 8.h),
  //                       child: Row(
  //                         children: [
  //                           // Checkbox
  //                           SizedBox(
  //                             width: 24.w,
  //                             height: 24.w,
  //                             child: Checkbox(
  //                               value: cart.requiresHomeCollection,
  //                               onChanged: (bool? value) {
  //                                 final newValue = value ?? false;
  //                                 cart.setRequiresHomeCollection(newValue);
  //                                 if (!newValue) {
  //                                   cart.clearHomeCollectionDetails();
  //                                 }
  //                               },
  //                               activeColor: Color(0xFF3661E2),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(4.r),
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(width: 12.w),
  //                           // Text with proper alignment
  //                           Expanded(
  //                             child: RichText(
  //                               text: TextSpan(
  //                                 text: "Home Sample Collection",
  //                                 style: GoogleFonts.poppins(
  //                                   fontSize: 16.sp,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Color(0xFF3661E2),
  //                                 ),
  //                                 children: [
  //                                   TextSpan(
  //                                     text:
  //                                     " (+₹${cart.homeCollectionCharge.toStringAsFixed(0)})",
  //                                     style: GoogleFonts.poppins(
  //                                       fontSize: 14.sp,
  //                                       color: Colors.grey[600],
  //                                       fontWeight: FontWeight.normal,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //
  //                     // Show address and time slot selection only if home collection is required
  //                     if (cart.requiresHomeCollection) ...[
  //                       SizedBox(height: 16.h),
  //                       // Address Selection
  //                       Container(
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[50],
  //                           borderRadius: BorderRadius.circular(12.r),
  //                         ),
  //                         child: ListTile(
  //                           contentPadding: EdgeInsets.symmetric(
  //                             horizontal: 16.w,
  //                             vertical: 8.h,
  //                           ),
  //                           leading: Icon(
  //                             Icons.location_on,
  //                             color: Color(0xFF3661E2),
  //                             size: 24.w,
  //                           ),
  //                           title: Text(
  //                             "Delivery Address",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 14.sp,
  //                               fontWeight: FontWeight.w600,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                           subtitle: Text(
  //                             cart.selectedAddress ?? "Tap to select address",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 13.sp,
  //                               color:
  //                               cart.selectedAddress != null
  //                                   ? Colors.grey[700]
  //                                   : Colors.grey[500],
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           trailing: Icon(
  //                             Icons.arrow_forward_ios,
  //                             size: 18.w,
  //                             color: Colors.grey[600],
  //                           ),
  //                           onTap:
  //                               () => _showAddressSelectionBottomSheet(
  //                             context,
  //                             cart,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12.r),
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(height: 12.h),
  //                       // Time Slot Selection
  //                       Container(
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[50],
  //                           borderRadius: BorderRadius.circular(12.r),
  //                         ),
  //                         child: ListTile(
  //                           contentPadding: EdgeInsets.symmetric(
  //                             horizontal: 16.w,
  //                             vertical: 8.h,
  //                           ),
  //                           leading: Icon(
  //                             Icons.access_time,
  //                             color: Color(0xFF3661E2),
  //                             size: 24.w,
  //                           ),
  //                           title: Text(
  //                             "Time Slot",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 14.sp,
  //                               fontWeight: FontWeight.w600,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                           subtitle: Text(
  //                             cart.selectedTimeSlot != null &&
  //                                 cart.selectedBookingDate != null
  //                                 ? "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}"
  //                                 : "Tap to select time slot",
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 13.sp,
  //                               color:
  //                               cart.selectedTimeSlot != null
  //                                   ? Colors.grey[700]
  //                                   : Colors.grey[500],
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           trailing: Icon(
  //                             Icons.arrow_forward_ios,
  //                             size: 18.w,
  //                             color: Colors.grey[600],
  //                           ),
  //                           onTap:
  //                               () => _showTimeSlotSelectionBottomSheet(
  //                             context,
  //                             cart,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12.r),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                     SizedBox(height: 16.h),
  //                     Container(
  //                       padding: EdgeInsets.symmetric(
  //                         vertical: 12.h,
  //                         horizontal: 4.w,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         border: Border(
  //                           top: BorderSide(color: Colors.grey[200]!, width: 1),
  //                         ),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           // Only show home collection charge if it's enabled
  //                           if (cart.requiresHomeCollection) ...[
  //                             _buildAmountRow(
  //                               "Home Collection Charge",
  //                               "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
  //                               Colors.black87,
  //                             ),
  //                             SizedBox(height: 8.h),
  //                           ],
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               // Total Amount Section
  //                               Expanded(
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     Text(
  //                                       "Total Amount",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 14.sp,
  //                                         fontWeight: FontWeight.w500,
  //                                         color: Colors.grey[700],
  //                                       ),
  //                                     ),
  //                                     SizedBox(height: 4.h),
  //                                     Text(
  //                                       "₹${payableAmount.toStringAsFixed(0)}",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 20.sp,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Color(0xFF3661E2),
  //                                       ),
  //                                     ),
  //                                     SizedBox(height: 4.h),
  //                                     Text(
  //                                       "Saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
  //                                       style: GoogleFonts.poppins(
  //                                         fontSize: 12.sp,
  //                                         color: Colors.green,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               SizedBox(width: 12.w),
  //                               // Checkout Button
  //                               ElevatedButton(
  //                                 onPressed: cart.selectedItemCount > 0 &&
  //                                     hasSufficientBalance &&
  //                                     (!cart.requiresHomeCollection ||
  //                                         (cart.selectedAddress != null &&
  //                                             cart.selectedTimeSlot != null &&
  //                                             cart.selectedBookingDate != null))
  //                                     ? () {
  //                                   _showPaymentOptionsDialog(
  //                                     context,
  //                                     cart,
  //                                     payableAmount,
  //                                   );
  //                                 }
  //                                     : null,
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: cart.selectedItemCount > 0 && hasSufficientBalance
  //                                       ? Color(0xFF3661E2)
  //                                       : Colors.grey[400],
  //                                   padding: EdgeInsets.symmetric(
  //                                     horizontal: 20.w,
  //                                     vertical: 14.h,
  //                                   ),
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(12.r),
  //                                   ),
  //                                   elevation: cart.selectedItemCount > 0 && hasSufficientBalance ? 2 : 0,
  //                                   minimumSize: Size(0, 50.h),
  //                                 ),
  //                                 child: Text(
  //                                   cart.selectedItemCount > 0
  //                                       ? (hasSufficientBalance
  //                                       ? "Proceed to Checkout"
  //                                       : "Insufficient Balance")
  //                                       : "Select Items",
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: 14.sp,
  //                                     fontWeight: FontWeight.w600,
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ): SizedBox.shrink(),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final GlobalKey _walletSummaryKey = GlobalKey();
    final GlobalKey _orderSummaryKey = GlobalKey();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        title: Consumer<CartModel>(
          builder: (context, cart, child) => Text(
            "Cart (${cart.selectedItemCount}/${cart.itemCount})",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3661E2),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80.w,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Add some tests to get started",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3661E2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Browse Tests",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final isWalletEnabled =
              cart.items.isNotEmpty &&
                  cart.items.first['isWalletEnabled'] == true;
          final walletAmount = isWalletEnabled ? cart.walletAmount : 0.0;

          final walletDiscount = isWalletEnabled && walletAmount > 0
              ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
              : 0.0;

          final payableAmount = (cart.selectedSubtotal - walletDiscount) +
              (cart.requiresHomeCollection ? cart.homeCollectionCharge : 0);
          final walletAmountAfterDeduction =
          isWalletEnabled ? walletAmount - walletDiscount : 0.0;
          final hasSufficientBalance =
              !isWalletEnabled || walletAmountAfterDeduction >= 0;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  children: [
                    ...List.generate(cart.items.length, (index) {
                      final item = cart.items[index];
                      final itemId = item['itemId'];
                      final isSelected = cart.isItemSelected(itemId);
                      final quantity = item['quantity'] as int;
                      final discountPrice = item["discountPrice"] as double;
                      final originalPrice = item["originalPrice"] as double;
                      final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();
                      final totalItemPrice = discountPrice * quantity;
                      final selectedPatientCount = (item['selectedPatientIds'] as List?)?.length ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              child: TestListDetails(
                                test: item,
                                provider: item["provider"],
                                service: item["service"],
                                userModel: userModel,
                              ),
                              direction: AxisDirection.right,
                            ),
                          );
                        },
                        child: Card(
                          elevation: isSelected ? 4 : 2,
                          margin: EdgeInsets.only(bottom: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                                color: isSelected ? Color(0xFF3661E2).withOpacity(0.3) : Colors.grey[200]!,
                                width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                color: Colors.white
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with test icon and select patients button
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Test icon
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.science,
                                        color: Color(0xFF3661E2),
                                        size: 25.w,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),

                                    // Test name and provider
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["name"],
                                            style: GoogleFonts.poppins(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3661E2),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "Provider: ${item['provider']}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Select Patients button
                                    ElevatedButton(
                                      onPressed: () => _showPatientSelectionDialog(
                                        context,
                                        item,
                                        cart,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedPatientCount > 0
                                            ? Colors.white
                                            : Color(0xFF3661E2),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 10.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          side: selectedPatientCount > 0
                                              ? BorderSide(
                                            color: Color(0xFF3661E2),
                                            width: 1,
                                          )
                                              : BorderSide.none,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        selectedPatientCount > 0
                                            ? "$selectedPatientCount"
                                            : "Select",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: selectedPatientCount > 0
                                              ? Color(0xFF3661E2)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12.h),

                                // Price information
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Price per patient: ",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Text(
                                                "₹${discountPrice.toStringAsFixed(0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Text(
                                                "₹${originalPrice.toStringAsFixed(0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF3661E2).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4.r),
                                                ),
                                                child: Text(
                                                  "${discountPercentage.toStringAsFixed(0)}% OFF",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.sp,
                                                    color: Color(0xFF3661E2),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Total for $selectedPatientCount patient${selectedPatientCount == 1 ? '' : 's'}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "₹${totalItemPrice.toStringAsFixed(0)}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            // color: Color(0xFF3661E2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.only(top: 2.h),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            cart.toggleItemSelection(itemId, !isSelected);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 24.w,
                                                  height: 24.w,
                                                  child: Checkbox(
                                                    value: isSelected,
                                                    onChanged: (value) {
                                                      cart.toggleItemSelection(itemId, value ?? false);
                                                    },
                                                    activeColor: Color(0xFF3661E2),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6.r),
                                                    ),
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  "Select this item",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        width: 1.w,
                                        height: 24.h,
                                        color: Colors.grey[300],
                                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                                      ),

                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            cart.removeFromCart(itemId);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "${item['name']} removed from cart",
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete_outline, size: 18.w, color: Colors.red),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "Remove",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (cart.items.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Select: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                _buildSelectionButton(
                                  text: "All",
                                  onPressed: () => cart.selectAllItems(),
                                  isActive: cart.selectedItemCount == cart.itemCount,
                                ),
                                SizedBox(width: 8.w),
                                _buildSelectionButton(
                                  text: "None",
                                  onPressed: () => cart.deselectAllItems(),
                                  isActive: cart.selectedItemCount == 0,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: Text(
                                    "${cart.selectedItemCount} of ${cart.itemCount} selected",
                                    key: ValueKey(cart.selectedItemCount),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    SizedBox(height: 16.h),
                    if (cart.selectedItemCount > 0) ...[
                      Card(
                        key: _walletSummaryKey,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Wallet Summary",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3661E2),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildAmountRow(
                                "Wallet Balance",
                                "₹${walletAmount.toStringAsFixed(0)}",
                                Colors.black87,
                              ),

                              // Only show these if wallet has balance
                              if (walletAmount > 0) ...[
                                SizedBox(height: 8.h),

                                // Wallet Points Utilised WITH TOOLTIP
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Wallet Points Utilised",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        _buildInfoTooltip(
                                          "Amount of wallet points being used from your ${_getOrganizationName(cart)} balance for this order",
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₹${walletDiscount.toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Color(0xFF3661E2),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8.h),
                                _buildAmountRow(
                                  "Remaining Wallet Balance",
                                  "₹${walletAmountAfterDeduction.toStringAsFixed(0)}",
                                  hasSufficientBalance
                                      ? Colors.black87
                                      : Colors.red,
                                  isBold: true,
                                ),
                                if (!hasSufficientBalance)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      "Please add funds to your wallet to proceed.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ] else if (isWalletEnabled &&
                                  walletAmount == 0) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  "No wallet balance available",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price Details",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3661E2),
                                ),
                              ),
                              SizedBox(height: 8.h),

                              // Calculate total original price and total discount
                              _buildPriceDetailRow(
                                "Total Original Price",
                                "₹${_calculateTotalOriginalPrice(cart).toStringAsFixed(0)}",
                              ),
                              SizedBox(height: 4.h),
                              _buildPriceDetailRow(
                                "Total Discount",
                                "-₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
                                valueColor: Colors.green,
                              ),
                              SizedBox(height: 4.h),
                              if (cart.requiresHomeCollection)
                                _buildPriceDetailRow(
                                  "Home Collection Charge",
                                  "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
                                ),
                              Divider(height: 16.h, thickness: 1),
                              _buildPriceDetailRow(
                                "Subtotal",
                                "₹${cart.selectedTotalPrice .toStringAsFixed(0)}",
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Card(
                        key: _orderSummaryKey,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Summary",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3661E2),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildAmountRow(
                                "Subtotal",
                                "₹${cart.selectedTotalPrice.toStringAsFixed(0)}",
                                Colors.black87,
                              ),
                              // Only show wallet discount if there's wallet balance
                              if (walletAmount > 0) ...[
                                SizedBox(height: 8.h),
                                // Wallet Points Discount WITH TOOLTIP
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Wallet Points Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        _buildInfoTooltip(
                                          "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "-₹${walletDiscount.toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Color(0xFF3661E2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              // Only show home collection charge if it's enabled
                              if (cart.requiresHomeCollection) ...[
                                SizedBox(height: 8.h),
                                _buildAmountRow(
                                  "Home Collection Charge",
                                  "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
                                  Colors.black87,
                                ),
                              ],
                              Divider(height: 16.h, thickness: 1),
                              _buildAmountRow(
                                "Amount to Pay",
                                "₹${payableAmount.toStringAsFixed(0)}",
                                Color(0xFF3661E2),
                                isBold: true,
                              ),

                              // Add savings information
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.discount,
                                      size: 16.w,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "You saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: cart.selectedItemCount > 0 ? Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Make the entire Home Sample Collection section clickable
                      InkWell(
                        onTap: () {
                          final newValue = !cart.requiresHomeCollection;
                          cart.setRequiresHomeCollection(newValue);
                          if (!newValue) {
                            cart.clearHomeCollectionDetails();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              // Checkbox
                              SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: Checkbox(
                                  value: cart.requiresHomeCollection,
                                  onChanged: (bool? value) {
                                    final newValue = value ?? false;
                                    cart.setRequiresHomeCollection(newValue);
                                    if (!newValue) {
                                      cart.clearHomeCollectionDetails();
                                    }
                                  },
                                  activeColor: Color(0xFF3661E2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Text with proper alignment
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Home Sample Collection",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3661E2),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                        " (+₹${cart.homeCollectionCharge.toStringAsFixed(0)})",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Show address and time slot selection only if home collection is required
                      if (cart.requiresHomeCollection) ...[
                        SizedBox(height: 16.h),
                        // Address Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            leading: Icon(
                              Icons.location_on,
                              color: Color(0xFF3661E2),
                              size: 24.w,
                            ),
                            title: Text(
                              "Delivery Address",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              cart.selectedAddress ?? "Tap to select address",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color:
                                cart.selectedAddress != null
                                    ? Colors.grey[700]
                                    : Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18.w,
                              color: Colors.grey[600],
                            ),
                            onTap:
                                () => _showAddressSelectionBottomSheet(
                              context,
                              cart,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Time Slot Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            leading: Icon(
                              Icons.access_time,
                              color: Color(0xFF3661E2),
                              size: 24.w,
                            ),
                            title: Text(
                              "Time Slot",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              cart.selectedTimeSlot != null &&
                                  cart.selectedBookingDate != null
                                  ? "${_formatDisplayDate(cart.selectedBookingDate)} • ${cart.selectedTimeSlot}"
                                  : "Tap to select time slot",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color:
                                cart.selectedTimeSlot != null
                                    ? Colors.grey[700]
                                    : Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18.w,
                              color: Colors.grey[600],
                            ),
                            onTap:
                                () => _showTimeSlotSelectionBottomSheet(
                              context,
                              cart,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 4.w,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Only show home collection charge if it's enabled
                            if (cart.requiresHomeCollection) ...[
                              _buildAmountRow(
                                "Home Collection Charge",
                                "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
                                Colors.black87,
                              ),
                              SizedBox(height: 8.h),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Total Amount Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Total Amount",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "₹${payableAmount.toStringAsFixed(0)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3661E2),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Saved ₹${_calculateTotalDiscount(cart).toStringAsFixed(0)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                // Checkout Button
                                ElevatedButton(
                                  onPressed: cart.selectedItemCount > 0 &&
                                      hasSufficientBalance &&
                                      (!cart.requiresHomeCollection ||
                                          (cart.selectedAddress != null &&
                                              cart.selectedTimeSlot != null &&
                                              cart.selectedBookingDate != null))
                                      ? () {
                                    _showPaymentOptionsDialog(
                                      context,
                                      cart,
                                      payableAmount,
                                    );
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cart.selectedItemCount > 0 && hasSufficientBalance
                                        ? Color(0xFF3661E2)
                                        : Colors.grey[400],
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: cart.selectedItemCount > 0 && hasSufficientBalance ? 2 : 0,
                                    minimumSize: Size(0, 50.h),
                                  ),
                                  child: Text(
                                    cart.selectedItemCount > 0
                                        ? (hasSufficientBalance
                                        ? "Proceed to Checkout"
                                        : "Insufficient Balance")
                                        : "Select Items",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ): SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
  void _showPaymentOptionsDialog(
      BuildContext context,
      CartModel cart,
      double payableAmount,
      ) {
    final isWalletEnabled =
        cart.items.isNotEmpty && cart.items.first['isWalletEnabled'] == true;
    final walletBalance = isWalletEnabled ? cart.walletAmount : 0.0;

    // Calculate wallet discount on subtotal (not including home collection)
    final walletDiscount =
    isWalletEnabled && walletBalance > 0
        ? cart.selectedSubtotal * (cart.walletDiscountPercentage / 100)
        : 0.0;

    final hasSufficientBalance =
        !isWalletEnabled || walletBalance >= walletDiscount;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          bool isLoading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                backgroundColor: Colors.grey[200],
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.grey[200],
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF3661E2)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    "Select Payment Option",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3661E2),
                    ),
                  ),
                  centerTitle: true,
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Summary Card
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Summary",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Subtotal
                            _buildPaymentRow(
                              "Subtotal",
                              "₹${cart.selectedSubtotal.toStringAsFixed(0)}",
                            ),

                            // Home Collection Charge (if applicable)
                            if (cart.requiresHomeCollection) ...[
                              SizedBox(height: 8.h),
                              _buildPaymentRow(
                                "Home Collection Charge",
                                "₹${cart.homeCollectionCharge.toStringAsFixed(0)}",
                              ),
                            ],

                            // Wallet Discount (if applicable)
                            if (walletDiscount > 0) ...[
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Wallet Discount (${cart.walletDiscountPercentage.toStringAsFixed(0)}%)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      _buildInfoTooltip(
                                        "Discount applied from your ${_getOrganizationName(cart)} wallet balance",
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "-₹${walletDiscount.toStringAsFixed(0)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Color(0xFF3661E2),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Wallet Balance
                            if (isWalletEnabled) ...[
                              SizedBox(height: 8.h),
                              _buildPaymentRow(
                                "Wallet Balance",
                                "₹${walletBalance.toStringAsFixed(0)}",
                                valueColor: hasSufficientBalance
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],

                            Divider(height: 20.h, thickness: 1),

                            // Total Amount to Pay
                            _buildPaymentRow(
                              "Amount to Pay",
                              "₹${payableAmount.toStringAsFixed(0)}",
                              isBold: true,
                              valueColor: Color(0xFF3661E2),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Payment Options
                      Text(
                        "Choose Payment Method",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3661E2),
                          ),
                        ),

                      // Pay Later Option
                      _buildPaymentOptionCard(
                        context,
                        icon: Icons.credit_card,
                        title: "Pay Later",
                        subtitle: "Pay after service completion",
                        onTap: isLoading
                            ? null
                            : () async {
                          setState(() => isLoading = true);
                          final result = await cart.placeOrder('Pay Later');
                          setState(() => isLoading = false);

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (result['success'] == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => OrderSuccessPopup(
                                  onContinue: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingsScreen(
                                          userModel: userModel,
                                        ),
                                      ),
                                          (route) => route.isFirst,
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? "Failed to place order",
                                  style: GoogleFonts.poppins(fontSize: 14.sp),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Pay Now Option
                      _buildPaymentOptionCard(
                        context,
                        icon: Icons.payment,
                        title: "Pay Now",
                        subtitle: "Secure payment via Razorpay",
                        isDisabled: !hasSufficientBalance,
                        onTap: isLoading || !hasSufficientBalance
                            ? null
                            : () {
                          Navigator.pop(context);
                          _initiateRazorpayPayment(cart, payableAmount);
                        },
                      ),

                      if (!hasSufficientBalance) ...[
                        SizedBox(height: 8.h),
                        Text(
                          "Insufficient wallet balance to use this option",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Terms and Conditions
                      Text(
                        "By proceeding, you agree to our Terms of Service and Privacy Policy",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentRow(
      String label,
      String value, {
        Color valueColor = Colors.black87,
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        bool isDisabled = false,
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: isDisabled ? Colors.grey[100] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color:
                  isDisabled
                      ? Colors.grey[300]
                      : Color(0xFF3661E2).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? Colors.grey : Color(0xFF3661E2),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? Colors.grey : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: isDisabled ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDisabled ? Colors.grey : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initiateRazorpayPayment(CartModel cart, double payableAmount) {
    final razorpay = Razorpay();
    bool isProcessing = false;

    void handlePaymentSuccess(PaymentSuccessResponse response) async {
      if (isProcessing) return;
      isProcessing = true;

      final context = _scaffoldKey.currentContext;
      if (context == null || !context.mounted) {
        razorpay.clear();
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF3661E2)),
        ),
      );

      try {
        final result = await cart.placeOrder('Pay Now');

        if (!context.mounted) {
          razorpay.clear();
          return;
        }

        if (result['success'] == true) {
          // Show success popup
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder:
                  (context) => OrderSuccessPopup(
                onContinue: () {
                  // Navigate to orders screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookingsScreen(userModel: userModel),
                    ),
                        (route) => route.isFirst,
                  );
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? "Failed to place order after payment",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error processing order: ${e.toString()}",
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        razorpay.clear();
        isProcessing = false;
      }
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      final context = _scaffoldKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Payment failed: ${response.message}",
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      razorpay.clear();
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
      final context = _scaffoldKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "External wallet selected: ${response.walletName}",
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
      razorpay.clear();
    });

    final options = {
      'key': 'rzp_test_LeshFtPDPl49hb',
      'amount': (payableAmount * 100).toInt(),
      'name': 'Aqure',
      'description': 'Payment for Aqure',
      'prefill': {
        'contact': userModel.currentUser?['contactNumber'] ?? '',
        'email': userModel.currentUser?['email'] ?? '',
      },
    };

    try {
      razorpay.open(options);
    } catch (e) {
      final context = _scaffoldKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error initiating payment: $e",
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      razorpay.clear();
    }
  }

  Widget _buildAmountRow(
      String label,
      String value,
      Color color, {
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

double _calculateTotalOriginalPrice(CartModel cart) {
  return cart.items.fold(0.0, (sum, item) {
    final originalPrice = item['originalPrice'] as double;
    final quantity = item['quantity'] as int;
    return sum + (originalPrice * quantity);
  });
}

double _calculateTotalDiscount(CartModel cart) {
  return cart.items.fold(0.0, (sum, item) {
    final originalPrice = item['originalPrice'] as double;
    final discountPrice = item['discountPrice'] as double;
    final quantity = item['quantity'] as int;
    return sum + ((originalPrice - discountPrice) * quantity);
  });
}

Widget _buildPriceDetailRow(
    String label,
    String value, {
      Color valueColor = Colors.black87,
      bool isBold = false,
    }) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[700]),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: valueColor,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

Widget _buildInfoTooltip(
    String message, {
      Color color = const Color(0xFF3661E2),
    }) {
  return Tooltip(
    message: message,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    ),
    textStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87),
    child: Icon(Icons.info_outline, size: 16.w, color: color),
  );
}
Widget _buildSelectionButton({
  required String text,
  required VoidCallback onPressed,
  required bool isActive,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isActive ? Color(0xFF3661E2).withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: isActive ? Color(0xFF3661E2) : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}
// Helper method to get organization name safely
String _getOrganizationName(CartModel cart) {
  if (cart.items.isEmpty) return 'the provider';
  final organizationName =
      cart.items.first['organizationName'] ?? cart.items.first['provider'];
  return organizationName ?? 'the provider';
}