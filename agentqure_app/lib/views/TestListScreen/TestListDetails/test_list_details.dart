import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../../models/CartModel/cart_model.dart';
import '../../../models/UserModel/user_model.dart';
import '../../../services/MemberService/AddMemberForm/add_member_form.dart';
import '../../../services/MemberService/member_service.dart';
import '../../CartScreen/cart_screen.dart';

class TestListDetails extends StatefulWidget {
  final Map<String, dynamic> test;
  final String provider;
  final String service;
  final UserModel userModel;

  const TestListDetails({
    super.key,
    required this.test,
    required this.provider,
    required this.service,
    required this.userModel,
  });

  @override
  _TestListDetailsState createState() => _TestListDetailsState();
}

class _TestListDetailsState extends State<TestListDetails> {
  bool _isSelected = false;
  late CartModel _cartModel;
  bool _isDisposed = false;
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  late ScaffoldMessengerState _scaffoldMessenger;
  final MemberService _memberService = MemberService(Dio());

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    _initializeCartModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _initializeCartModel() {
    _cartModel = Provider.of<CartModel>(context, listen: false);
    final itemId = '${widget.provider}_${widget.test["name"]}';
    _isSelected = _cartModel.items.any((item) => item['itemId'] == itemId);
    _cartModel.addListener(_syncWithCart);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cartModel.removeListener(_syncWithCart);
    _cancelToken?.cancel();
    _dio.close();
    super.dispose();
  }

  void _syncWithCart() {
    if (!mounted || _isDisposed) return;
    final itemId = '${widget.provider}_${widget.test["name"]}';
    setState(() {
      _isSelected = _cartModel.items.any((item) => item['itemId'] == itemId);
    });
  }

  void _toggleTestSelection(List<String> selectedPatientIds) {
    if (_isDisposed) return;
    final itemId = '${widget.provider}_${widget.test["name"]}';
    setState(() {
      if (selectedPatientIds.isEmpty) {
        _isSelected = false;
        _cartModel.removeFromCart(itemId);
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("${widget.test['name']} removed from cart"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else {
        _isSelected = true;
        _cartModel.addToCart({
          ...widget.test,
          "provider": widget.provider,
          "service": widget.service,
          "itemId": itemId,
          "pointBalance": widget.test["pointBalance"] ?? 0,
          "walletAmtPercentage":
          widget.test["walletAmtPercentage"]?.toDouble() ?? 0.0,
          'isWalletEnabled': widget.test['isWalletEnabled'] ?? false,
          'selectedPatientIds': selectedPatientIds,
          'description': widget.test['description'],
          'quantity': selectedPatientIds.length,
        });
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "Patient selection updated for ${widget.test['name']}",
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    });
  }

  void _showPatientSelectionDialog(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final selectedPatients = <String, bool>{};
    final primaryMember = userModel.currentUser;
    final children = userModel.children ?? [];
    final itemId = '${widget.provider}_${widget.test["name"]}';
    final cartItem = _cartModel.items.firstWhere(
          (item) => item['itemId'] == itemId,
      orElse: () => {},
    );
    final isInCart = cartItem.isNotEmpty;
    final List<String> previouslySelectedPatientIds =
    isInCart ? List<String>.from(cartItem['selectedPatientIds'] ?? []) : [];

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
                    // Header
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

                    // Divider
                    Divider(color: Colors.grey[200], height: 1.h),

                    SizedBox(height: 16.h),

                    // Patient List
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

                    // Action Buttons
                    Row(
                      children: [
                        if (isInCart)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _toggleTestSelection([]);
                                Navigator.pop(context);
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
                        if (isInCart) SizedBox(width: 12.w),
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
                              _toggleTestSelection(selectedPatientIds);
                              Navigator.pop(context);
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
                                fontWeight: FontWeight.w500,
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
    final primaryUser = widget.userModel.currentUser;
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
            // Refresh user data to include the new member
            widget.userModel.getUserByPhone(primaryUser['contactNumber']);
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

  @override
  Widget build(BuildContext context) {
    final test = widget.test;
    final testName = test["name"] ?? "Unknown Test";
    final description = test['description'];
    final originalPrice = (test["originalPrice"] as num?)?.toDouble() ?? 0.0;
    final discountPrice = (test["discountPrice"] as num?)?.toDouble() ?? 0.0;
    final discount = test["discount"] ?? 15;
    final reportTime = test["reportTime"] ?? "24 hours";
    final parameters = test["parameters"] as List<dynamic>? ?? [];
    final requiresFasting = test["requiresFasting"] ?? false;
    final itemId = '${widget.provider}_${test["name"]}';
    final cartItem = _cartModel.items.firstWhere(
          (item) => item['itemId'] == itemId,
      orElse: () => {},
    );
    final selectedPatientCount =
    _isSelected && cartItem['selectedPatientIds'] != null
        ? (cartItem['selectedPatientIds'] as List).length
        : 0;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
        title: Text(
          "Test Details",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3661E2),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Consumer<CartModel>(
              builder: (context, cart, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        size: 28.w,
                        color: const Color(0xFF3661E2),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                CartScreen(userModel: widget.userModel),
                          ),
                        );
                      },
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 6.w,
                        top: 8.h,
                        child: Container(
                          width: 18.w,
                          height: 18.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            // border: Border.all(
                            //   color: Colors.white,
                            //   width: 1.5.w,
                            // ),
                          ),
                          child: Text(
                            cart.itemCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testName,
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
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
                          "Price Breakdown",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildPriceRow(
                          "Original Price",
                          "₹${originalPrice.toStringAsFixed(0)}",
                        ),
                        SizedBox(height: 8.h),
                        _buildPriceRow(
                          "Discount (${discount}%)",
                          "-₹${(originalPrice - discountPrice).toStringAsFixed(0)}",
                          valueColor: Colors.green,
                        ),
                        Divider(height: 16.h, thickness: 1),
                        _buildPriceRow(
                          "Final Price",
                          "₹${discountPrice.toStringAsFixed(0)}",
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
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
                          "Test Details",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              requiresFasting ? Icons.food_bank : Icons.no_food,
                              size: 16.w,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              requiresFasting
                                  ? "Fasting required"
                                  : "Fasting not required",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16.w,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Reports in $reportTime",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
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
                          "Includes ${parameters.length} Tests",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Column(
                          children:
                          parameters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final param = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      param["paramName"] ??
                                          "Unknown Parameter",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<CartModel>(
            builder: (context, cart, child) {
              final itemId = '${widget.provider}_${test["name"]}';
              final isInCart = cart.items.any(
                    (item) => item['itemId'] == itemId,
              );

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total Price",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            selectedPatientCount > 0
                                ? "₹${(discountPrice * selectedPatientCount).toStringAsFixed(0)}"
                                : "₹${discountPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedPatientCount > 0)
                            Text(
                              "For $selectedPatientCount Patient${selectedPatientCount == 1 ? '' : 's'}",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 180.w,
                      child: ElevatedButton(
                        onPressed: () => _showPatientSelectionDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isInCart ? Colors.red : const Color(0xFF3661E2),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          selectedPatientCount > 0
                              ? "$selectedPatientCount Patient${selectedPatientCount == 1 ? '' : 's'}"
                              : "Select Patients",
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
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildPriceRow(
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