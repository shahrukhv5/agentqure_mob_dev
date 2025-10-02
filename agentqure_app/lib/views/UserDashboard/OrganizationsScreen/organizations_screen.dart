import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/UserModel/user_model.dart';
import '../../../services/ApiService/api_service.dart';
import '../../../utils/routes/custom_page_route.dart';
import '../../TestListScreen/test_list_screen.dart';
import 'PrescriptionUploadScreen/prescription_upload_screen.dart';

class OrganizationsScreen extends StatefulWidget {
  final String searchQuery;
  final UserModel userModel;
  final String currentAddress;

  const OrganizationsScreen({
    super.key,
    this.searchQuery = '',
    required this.userModel,
    required this.currentAddress,
  });

  @override
  _OrganizationsScreenState createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen>
    with TickerProviderStateMixin {
  static const _primaryColor = Color(0xFF3661E2);
  static const _hardcodedPhoneNumber = '+919834221488';

  static TextStyle get _sectionTitleStyle => GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: _primaryColor,
  );

  final List<Map<String, dynamic>> diagnosticsServices = [];
  List<File> _prescriptionFiles = [];
  bool _isUploadingPrescription = false;

  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _dialogAnimationController;
  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredOrganizations = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrganizations);
    _filteredOrganizations = List.from(diagnosticsServices);
    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _cancelToken = CancelToken();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOutSine),
    );

    _fetchDiagnosticsProviderName();
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    _cancelToken?.cancel();
    _dio.close();
    _scaleController.dispose();
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrganizations() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredOrganizations = List.from(diagnosticsServices);
      });
    } else {
      setState(() {
        _filteredOrganizations =
            diagnosticsServices.where((org) {
              return org['provider'].toLowerCase().contains(query) ||
                  org['location'].toLowerCase().contains(query) ||
                  (org['contactNumber'] != null &&
                      org['contactNumber'].toLowerCase().contains(query));
            }).toList();
      });
    }
  }

  Future<void> _makePhoneCall() async {
    final uri = Uri.parse('tel:$_hardcodedPhoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final cleanedNumber = _hardcodedPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = 'https://wa.me/$cleanedNumber';

    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPremiumIconButton({
    required IconData icon,
    required String label,
    required String tooltip,
    bool isFontAwesome = false,
    Color? iconColor,
    Color? backgroundColor,
    double size = 60,
    VoidCallback? onPressed,
  }) {
    final buttonColor = backgroundColor ?? const Color(0xFF3661E2);
    final iconColorFinal = iconColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _waveAnimation.value * 10.h),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => _scaleController.forward(),
        onExit: (_) => _scaleController.reverse(),
        child: GestureDetector(
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            textStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: EdgeInsets.all(8.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey[50]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20.r,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: size.w > 65 ? 65.w : size.w,
                              height: size.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    buttonColor,
                                    Color.lerp(buttonColor, Colors.black, 0.2)!,
                                  ],
                                  radius: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: buttonColor.withOpacity(0.4),
                                    blurRadius: 15.r,
                                    spreadRadius: 2.r,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: Tween(begin: 1.0, end: 1.2).animate(
                                      CurvedAnimation(
                                        parent: _waveController,
                                        curve: Curves.easeInOut,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: buttonColor.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  isFontAwesome
                                      ? FaIcon(
                                    icon,
                                    color: iconColorFinal,
                                    size: 25.w,
                                  )
                                      : Icon(
                                    icon,
                                    color: iconColorFinal,
                                    size: 25.w,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchDiagnosticsProviderName() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apiService = ApiService();
      final userId = widget.userModel.currentUser?['appUserId']?.toString() ?? '0';
      final List<Map<String, dynamic>> orgs = await apiService.getOrganizations(userId);

      if (!mounted) return;

      if (orgs.isNotEmpty) {
        setState(() {
          diagnosticsServices.clear();
          diagnosticsServices.addAll(
            orgs.map((item) {
              return {
                "provider": item["name"] ?? "Unknown Provider",
                "organizationId": item["organizationId"]?.toString() ?? "N/A",
                "contactNumber": item["contactNumber"] ?? "",
                "pointBalance": item["pointBalance"]?.toDouble() ?? 0.0,
                "isWalletEnabled": item["isWalletEnabled"] == 1,
                "location": item["address"] ?? "Unknown Location",
                "service": "Polyclinic and Diagnostic Center",
                "wallet": "Wallet",
                "price": "₹1200",
                "rating": 4.9,
                "description":
                item["orgDescription"] ?? "No description available",
                "availability": "Mon-Sat, 8AM-8PM",
                "imageUrl":
                "https://media.istockphoto.com/id/1090425074/vector/vector-illustration-of-hospital-room-interior-with-medical-tools-bed-and-table-room-in.jpg?s=2048x2048&w=is&k=20&c=fv4i0X-3Y2Ublez4EpapYInbuGqHQG8nmgn0lE25Noc=",
                "walletAmtPercentage":
                item["walletAmtPercentage"]?.toDouble() ?? 0.0,
              };
            }).toList(),
          );
          _filteredOrganizations = List.from(diagnosticsServices);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No providers found in API response";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState() {
        _errorMessage = "Error fetching providers: $e";
        _isLoading = false;
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  child: PhysicalModel(
                    color: Colors.transparent,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(24.r),
                    shadowColor: Colors.black.withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.grey[50]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30.r,
                            spreadRadius: 5.r,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildPremiumIconButton(
                              icon: Icons.phone_in_talk_rounded,
                              label: "Instant\nCall",
                              tooltip: 'Connect with our support team',
                              backgroundColor: Colors.green[700],
                              size: 60.sp,
                              onPressed: _makePhoneCall,
                            ),
                          ),
                          Expanded(
                            child:
                            _buildPremiumIconButton(
                              icon: Icons.upload_file,
                              label: "Upload\nPrescription",
                              tooltip: 'Upload your prescriptions',
                              backgroundColor: Colors.orange[700],
                              size: 60.sp,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PrescriptionUploadScreen(
                                      userModel: widget.userModel,
                                    ),
                                  ),
                                ).then((success) {
                                  if (success == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Prescription uploaded successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildPremiumIconButton(
                              icon: FontAwesomeIcons.whatsapp,
                              label: "WhatsApp\nChat",
                              tooltip: 'Message us on WhatsApp',
                              isFontAwesome: true,
                              backgroundColor: const Color(0xFF25D366),
                              size: 60.sp,
                              onPressed: _openWhatsApp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildServicesSection(context),
              ],
            ),
          ),
          if (_isUploadingPrescription) ...[
            ModalBarrier(color: Colors.black54, dismissible: false),
            Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey[300]!,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(width: 200.w, height: 20.h, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 80.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: Colors.white,
                ),
              ),
            ),
            ...List.generate(3, (index) => _buildShimmerCard()),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: _fetchDiagnosticsProviderName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredServices =
    widget.searchQuery.isEmpty
        ? diagnosticsServices
        : diagnosticsServices.where((service) {
      final query = widget.searchQuery.toLowerCase();
      return service["provider"].toLowerCase().contains(query) ||
          service["service"].toLowerCase().contains(query) ||
          service["description"].toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lab Partners", style: _sectionTitleStyle),
          SizedBox(height: 12.h),
          if (filteredServices.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  "No services found for '${widget.searchQuery}'",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ServiceCard(
                    service: service,
                    subCategory: "Diagnostics",
                    userModel: widget.userModel,
                    currentAddress: widget.currentAddress,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

Widget _buildShimmerCard() {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 120.w,
                        height: 14.h,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              height: 12.h,
              color: Colors.grey[300],
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 12.h,
              color: Colors.grey[300],
            ),
            SizedBox(height: 4.h),
            Container(width: 200.w, height: 12.h, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Container(width: 120.w, height: 28.h, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final String subCategory;
  final UserModel userModel;
  final String currentAddress;

  const _ServiceCard({
    required this.service,
    required this.subCategory,
    required this.userModel,
    required this.currentAddress,
  });

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getServiceIcon(String subCategory) {
    switch (subCategory) {
      case "Diagnostics":
        return Icons.medical_services;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber[700], size: 16.w),
          SizedBox(width: 4.w),
          Text(
            widget.service["rating"].toString(),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBadge() {
    if (!widget.service["isWalletEnabled"] ||
        widget.service["pointBalance"] <= 0) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.green[700],
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            "${widget.service["pointBalance"]}",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CustomPageRoute(
              child: TestListScreen(
                service: widget.service,
                userModel: widget.userModel,
                currentAddress: widget.currentAddress,
              ),
              direction: AxisDirection.left,
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                borderRadius: BorderRadius.circular(16.r),
                elevation: _elevationAnimation.value,
                shadowColor: _OrganizationsScreenState._primaryColor.withOpacity(
                  0.1,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Colors.white,
                    border: Border.all(
                      color:
                      _isHovered
                          ? _OrganizationsScreenState._primaryColor.withOpacity(
                        0.2,
                      )
                          : Colors.grey.withOpacity(0.1),
                      width: _isHovered ? 1.5.w : 1.w,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: _OrganizationsScreenState._primaryColor
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getServiceIcon(widget.subCategory),
                                color: _OrganizationsScreenState._primaryColor,
                                size: 24.w,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.service["provider"],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _buildRatingBadge(),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    widget.service["service"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: _OrganizationsScreenState._primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Only show description if it exists and is not empty
                        if (widget.service["description"] != null &&
                            widget.service["description"]
                                .toString()
                                .isNotEmpty &&
                            widget.service["description"]
                                .toString()
                                .toLowerCase() !=
                                "no description available")
                          Column(
                            children: [
                              SizedBox(height: 12.h),
                              Text(
                                widget.service["description"],
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        SizedBox(height: 12.h),
                        // Only show wallet badge if wallet is enabled
                        _buildWalletBadge(),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  child: TestListScreen(
                                    service: widget.service,
                                    userModel: widget.userModel,
                                    currentAddress: widget.currentAddress,
                                  ),
                                  direction: AxisDirection.left,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              backgroundColor:
                              _OrganizationsScreenState._primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "View Available Tests",
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}