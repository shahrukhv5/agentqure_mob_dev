import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/UserController/user_controller.dart';
import '../../../models/CartModel/cart_model.dart';
import '../../../models/UserModel/user_model.dart';
import '../../../utils/CustomBottomNavigationBar/custom_bottom_navigation_bar.dart';
import '../../../utils/NavigationUtils/navigation_utils.dart';
import '../../CartScreen/cart_screen.dart';
import '../OrganizationsScreen/organizations_screen.dart';
import 'MembersScreen/members_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = "Fetching location...";
  Position? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentAddress = "Location services are disabled";
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentAddress = "Location permissions are denied";
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentAddress = "Location permissions are permanently denied";
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      await _getAddressFromLatLng(position);
    } catch (e) {
      print("Error getting location: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Unable to fetch location";
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          _currentAddress = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Couldn't get address";
        });
      }
    }
  }

  void _onItemTapped(int index) {
    NavigationUtils.handleNavigation(
      context,
      index,
      _selectedIndex,
          (newIndex) => setState(() => _selectedIndex = newIndex),
      Provider.of<UserModel>(context, listen: false),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    final controller = UserController(
      Provider.of<UserModel>(context, listen: false),
      context,
    );
    try {
      await controller.logout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build: _selectedIndex = $_selectedIndex');
    final userModel = Provider.of<UserModel>(context);
    final cartModel = Provider.of<CartModel>(context);
    final user = userModel.currentUser;
    final userName =
    user != null
        ? "${user['firstName']} ${user['lastName']}".trim()
        : "User";

    return Scaffold(
      backgroundColor: const Color(0xFF3661E2),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3661E2), const Color(0xFF5981F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 40.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Hello, $userName 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.group,
                  size: 24.w,
                  color: const Color(0xFF3661E2),
                ),
                title: Text(
                  'Members',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: Colors.grey.shade600,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MembersScreen(userModel: userModel),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  size: 24.w,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
                trailing:
                _isLoggingOut
                    ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.redAccent,
                  ),
                )
                    : null,
                onTap:
                _isLoggingOut
                    ? null
                    : () async {
                  Navigator.pop(context);
                  await _logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Builder(
                                builder:
                                    (context) => IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 30.w,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                ),
                              ),
                              Text(
                                'Hello 👋',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5.w + 8.w),
                            child: Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 15.h),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 28.w,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                        CartScreen(userModel: userModel),
                                  ),
                                );
                              },
                            ),
                            if (cartModel.itemCount > 0)
                              Positioned(
                                right: -2.w,
                                top: -1.h,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5.w,
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 18.w,
                                    minHeight: 18.w,
                                  ),
                                  child: Center(
                                    child: Text(
                                      cartModel.itemCount.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for services...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.r),
                    topRight: Radius.circular(25.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.r),
                    topRight: Radius.circular(25.r),
                  ),
                  child: OrganizationsScreen(
                    searchQuery: _searchQuery,
                    userModel: userModel,
                    currentAddress: _currentAddress,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userModel: userModel,
      ),
    );
  }
}