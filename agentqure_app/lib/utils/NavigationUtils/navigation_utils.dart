import 'package:flutter/material.dart';
import '../../models/UserModel/user_model.dart';
import '../../views/UserDashboard/BookingsScreen/bookings_screen.dart';
import '../../views/UserDashboard/HomeScreen/home_screen.dart';
import '../../views/UserDashboard/ProfilePage/profile_page.dart';

class NavigationUtils {
  static void handleNavigation(
      BuildContext context,
      int index,
      int currentIndex,
      Function(int) setIndex,
      UserModel userModel,
      ) {
    if (index == currentIndex) return; // Prevent navigation to the same screen

    setIndex(index); // Update the selected index in the calling widget

    // Always clear the stack and set HomeScreen as the root
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Remove all previous routes
    );

    // If index is not 0, push the new screen on top of HomeScreen
    if (index != 0) {
      switch (index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingsScreen(userModel: userModel),
            ),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProfileScreen(
                phoneNumber: userModel.currentUser?['contactNumber'] ?? '',
              ),
            ),
          );
          break;
      }
    }
  }
}