import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/UserModel/user_model.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserModel userModel;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == currentIndex)
              return;
            onTap(index);
          },
          selectedItemColor: const Color(0xFF3661E2),
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: currentIndex == 0 ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.home, size: 26.w),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: currentIndex == 1 ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.receipt, size: 26.w),
              ),
              label: 'My Bookings',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: currentIndex == 2 ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.person, size: 26.w),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}