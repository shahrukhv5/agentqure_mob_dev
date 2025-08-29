import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/UserModel/user_model.dart';
import '../../models/CartModel/cart_model.dart';
import '../../services/MemberService/AddMemberForm/add_member_form.dart';
import '../../services/MemberService/member_service.dart';
import '../../utils/CustomBottomNavigationBar/custom_bottom_navigation_bar.dart';
import '../../utils/routes/custom_page_route.dart';
import '../CartScreen/cart_screen.dart';
import '../UserDashboard/BookingsScreen/bookings_screen.dart';
import '../UserDashboard/HomeScreen/home_screen.dart';
import '../UserDashboard/ProfilePage/profile_page.dart';
import 'TestListDetails/test_list_details.dart';

class TestListScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final UserModel userModel;
  final String currentAddress;

  const TestListScreen({
    super.key,
    required this.service,
    required this.userModel,
    required this.currentAddress,
  });

  @override
  _TestListScreenState createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _selectedTests = {};
  late CartModel _cartModel;
  bool _isDisposed = false;
  bool _isLoadingTests = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _tests = [];
  int _selectedIndex = 0;
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  late ScaffoldMessengerState _scaffoldMessenger;
  final MemberService _memberService = MemberService(Dio());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeCartModel();
    _cancelToken = CancelToken();
    _fetchTests();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _cartModel.removeListener(_syncWithCart);
    _cancelToken?.cancel();
    _dio.close();
    super.dispose();
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Coming Soon!"),
          content: Text(
            "Tests for this organization will be available soon. Please check back later.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchTests() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTests = true;
      _errorMessage = null;
    });

    try {
      // final orgId = widget.service["organizationId"]?.toString() ?? "37";
      final orgId = widget.service["organizationId"]?.toString() ?? "N/A";
      print('Fetching tests with org_id: $orgId');

      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/test-prices/list-org-labprtners/',
        queryParameters: {'labpartner_id': '', 'org_id': orgId, 'mode': 'Self'},
        cancelToken: _cancelToken,
      );

      print('API Status Code: ${response.statusCode}');
      print('API Response Body: ${response.data}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedResponse = response.data as Map<String, dynamic>;
        List<dynamic> data;

        if (decodedResponse.containsKey('body')) {
          data = decodedResponse['body'] is List ? decodedResponse['body'] : [];
        } else {
          throw Exception('Missing "body" key in response: $decodedResponse');
        }

        if (data.isNotEmpty) {
          final homeCollectionItem = data.firstWhere(
                (item) => item["testName"] == "Home Sample Collection",
            orElse: () => null,
          );

          double homeCollectionCharge = 200.0;
          if (homeCollectionItem != null) {
            homeCollectionCharge =
            (homeCollectionItem["mobileTestPrice"] is num
                ? homeCollectionItem["mobileTestPrice"].toDouble()
                : 200.0);
          }

          final cartModel = Provider.of<CartModel>(context, listen: false);
          cartModel.setHomeCollectionCharge(homeCollectionCharge);

          setState(() {
            _tests =
                data
                    .where((item) => item["testCategory"]?.toString() == "Test")
                    .map((item) {
                  final stdPrice =
                  (item["mobileTestPrice"] is num
                      ? item["mobileTestPrice"].toDouble()
                      : 0.0);
                  final discountPercentage =
                      double.tryParse(
                        item["mobileTestDiscount"]?.toString() ?? "0",
                      ) ??
                          0;

                  final discountPrice =
                      stdPrice * (1 - discountPercentage / 100);
                  final parameters = item["parameters"] as List? ?? [];

                  return {
                    "name": item["testName"]?.toString() ?? "Unknown Test",
                    "description":
                    item["mobileTestDescription"]?.toString() ??
                        "Diagnostic test for health assessment.",
                    "reportTime":
                    "${item["testDuration"]?.toString() ?? "24"} hours",
                    "price": "₹${discountPrice.toStringAsFixed(0)}",
                    "discount": discountPercentage,
                    "testCount": parameters.length,
                    "originalPrice": stdPrice,
                    "discountPrice": discountPrice,
                    "testId": item["testId"] ?? 0,
                    "requiresFasting": item["isFasting"] == 1,
                    "parameters": parameters,
                    "testCategory": item["testCategory"]?.toString(),
                  };
                })
                    .toList();
            _initializeSelections();
            _isLoadingTests = false;
          });
        } else {
          setState(() {
            _isLoadingTests = false;
          });
          if (mounted) {
            _showComingSoonDialog(context);
          }
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load tests: HTTP ${response.statusCode}";
          _isLoadingTests = false;
        });
      }
    } catch (e, stackTrace) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return;
      }
      if (!mounted) return;
      print('Error fetching tests: $e\nStackTrace: $stackTrace');
      setState(() {
        _errorMessage = "Error fetching tests: $e";
        _isLoadingTests = false;
      });
    }
  }

  void _showTestParameters(BuildContext context, Map<String, dynamic> test) {
    final parameters = test["parameters"] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Includes ${test['parameters']?.length ?? 0} Tests",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: parameters.length,
                      itemBuilder: (context, index) {
                        final param = parameters[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  param["paramName"] ?? "Unknown Parameter",
                                  style: GoogleFonts.poppins(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPatientSelectionDialog(
      BuildContext context,
      Map<String, dynamic> test,
      ) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final selectedPatients = <String, bool>{};
    final primaryMember = userModel.currentUser;
    final children = userModel.children ?? [];
    final itemId = '${widget.service["provider"]}_${test["name"]}';
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
                          "Add New Patient",
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
                                _toggleTestSelection(context, test, []);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${test['name']} removed from cart",
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
                              _toggleTestSelection(
                                context,
                                test,
                                selectedPatientIds,
                              );
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
                              "Confirm Selection",
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingsScreen(userModel: widget.userModel),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
              phoneNumber:
              widget.userModel.currentUser?['contactNumber'] ?? '',
            ),
          ),
        );
        break;
    }
  }

  void _initializeCartModel() {
    _cartModel = Provider.of<CartModel>(context, listen: false);

    final orgId = int.tryParse(widget.service["organizationId"]?.toString() ?? '');
    if (orgId != null) {
      _cartModel.setCurrentOrganizationId(orgId);
    }

    _cartModel.addListener(_syncWithCart);
    _initializeSelections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!_isDisposed) {
      final newCartModel = Provider.of<CartModel>(context, listen: true);
      if (_cartModel != newCartModel) {
        _cartModel.removeListener(_syncWithCart);
        _cartModel = newCartModel;
        _cartModel.addListener(_syncWithCart);
        _initializeSelections();
      }
    }
  }

  void _initializeSelections() {
    if (_isDisposed || _cartModel == null) return;

    for (var test in _tests) {
      final testName = test["name"];
      final itemId = '${widget.service["provider"]}_$testName';
      final isInCart = _cartModel.items.any((item) => item['itemId'] == itemId);

      _selectedTests[testName] = isInCart;
    }
  }

  void _syncWithCart() {
    if (!mounted || _isDisposed || _cartModel == null) return;

    setState(() {
      for (var test in _tests) {
        final testName = test["name"];
        _selectedTests[testName] = false;
      }

      for (var item in _cartModel.items) {
        if (item['provider'] == widget.service["provider"]) {
          _selectedTests[item['name']] = true;
        }
      }
    });
  }

  void _toggleTestSelection(
      BuildContext context,
      Map<String, dynamic> test,
      List<String> selectedPatientIds,
      ) {
    if (_isDisposed || _cartModel == null) return;

    final testName = test["name"];
    final itemId = '${widget.service["provider"]}_$testName';

    setState(() {
      if (selectedPatientIds.isEmpty) {
        _selectedTests[testName] = false;
        _cartModel.removeFromCart(itemId);
      } else {
        _selectedTests[testName] = true;
        _cartModel.addToCart({
          ...test,
          "provider": widget.service["provider"],
          "service": widget.service["service"],
          "itemId": itemId,
          "pointBalance": widget.service["pointBalance"] ?? 0,
          "walletAmtPercentage":
          widget.service["walletAmtPercentage"]?.toDouble() ?? 0.0,
          'isWalletEnabled': widget.service['isWalletEnabled'] ?? false,
          'selectedPatientIds': selectedPatientIds,
          'description': test['description'],
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTests =
    _searchQuery.isEmpty
        ? _tests
        : _tests.where((test) {
      final query = _searchQuery.toLowerCase();
      return test["name"].toLowerCase().contains(query) ||
          test["description"].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: Text(
          "${widget.service["provider"]}",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3661E2),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Stack(
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
                      CustomPageRoute(
                        child: CartScreen(userModel: widget.userModel),
                        direction: AxisDirection.left,
                      ),
                    );
                  },
                  tooltip: 'View Cart',
                ),
                Positioned(
                  right: 2.w,
                  top: 4.h,
                  child: Consumer<CartModel>(
                    builder:
                        (context, cart, child) =>
                    cart.itemCount > 0
                        ? Container(
                      width: 18.w,
                      height: 18.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5.w,
                        ),
                      ),
                      child: Text(
                        cart.itemCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search tests...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                          size: 20.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.currentAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingTests)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        itemBuilder:
                            (context, index) => _buildShimmerTestCard(),
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.redAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: _fetchTests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3661E2),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "Retry",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTests.length,
                      itemBuilder: (context, index) {
                        final test = filteredTests[index];
                        final testName = test["name"] ?? "Unknown Test";
                        final isSelected = _selectedTests[testName] ?? false;
                        final originalPrice = test["originalPrice"] ?? 0.0;
                        final discountPrice = test["discountPrice"] ?? 0.0;
                        final description = test['description'];
                        final discount = test["discount"] ?? 0;
                        final reportTime = test["reportTime"] ?? "24 hours";
                        final itemId =
                            '${widget.service["provider"]}_$testName';
                        final cartItem = _cartModel.items.firstWhere(
                              (item) => item['itemId'] == itemId,
                          orElse: () => {},
                        );
                        final selectedPatientCount =
                        isSelected && cartItem['selectedPatientIds'] != null
                            ? (cartItem['selectedPatientIds'] as List)
                            .length
                            : 0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: TestListDetails(
                                  test: {
                                    ...test, // Include all test data
                                    "provider": widget.service["provider"],
                                    "service": widget.service["service"],
                                    "pointBalance":
                                    widget.service["pointBalance"] ?? 0,
                                    "walletAmtPercentage":
                                    widget.service["walletAmtPercentage"]
                                        ?.toDouble() ??
                                        0.0,
                                    'isWalletEnabled':
                                    widget.service['isWalletEnabled'] ??
                                        false,
                                  },
                                  provider: widget.service["provider"],
                                  service: widget.service["service"],
                                  userModel: widget.userModel,
                                ),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        testName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (description != null)
                                        Text(
                                          description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1.h, color: Colors.grey[300]),
                                Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap:
                                                () => _showTestParameters(
                                              context,
                                              test,
                                            ),
                                            child: Text(
                                              "Includes ${test['testCount']} test${test['testCount'] == 1 ? '' : 's'}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                color: Color(0xFF3661E2),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Text(
                                                "₹${discountPrice.toStringAsFixed(0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "₹${originalPrice.toStringAsFixed(0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey,
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    0xFF3661E2,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    4.r,
                                                  ),
                                                ),
                                                child: Text(
                                                  "${discount.toStringAsFixed(0)}% OFF",
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
                                      ElevatedButton(
                                        onPressed:
                                            () => _showPatientSelectionDialog(
                                          context,
                                          test,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          selectedPatientCount > 0
                                              ? Colors.white
                                              : Color(0xFF3661E2),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24.w,
                                            vertical: 12.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            side:
                                            selectedPatientCount > 0
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
                                              ? "$selectedPatientCount Patient${selectedPatientCount == 1 ? '' : 's'}"
                                              : "Book Now",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                            selectedPatientCount > 0
                                                ? Color(0xFF3661E2)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        test["requiresFasting"]
                                            ? Icons.fastfood
                                            : Icons.no_food,
                                        size: 16.w,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        test["requiresFasting"]
                                            ? "Fasting required"
                                            : "Fasting not required",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Icon(
                                        Icons.access_time,
                                        size: 16.w,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "Reports in ${test["reportTime"]}",
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
                        );
                      },
                    ),
                  ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer<CartModel>(
              builder: (context, cart, child) {
                if (cart.itemCount == 0) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} added",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "₹${cart.totalPrice.toStringAsFixed(2)}",
                            // "₹${cart.selectedTotalPrice.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3661E2),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              child: CartScreen(userModel: widget.userModel),
                              direction: AxisDirection.left,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3661E2),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Go to Cart",
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
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userModel: widget.userModel,
      ),
    );
  }

  Widget _buildShimmerTestCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              width: double.infinity,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Divider(height: 1.h, color: Colors.grey[300]),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 50.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 60.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 100.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}