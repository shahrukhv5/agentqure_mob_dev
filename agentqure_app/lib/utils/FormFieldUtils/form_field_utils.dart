import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
class FormFieldUtils {
  // Main input decoration method
  static InputDecoration buildInputDecoration({
    required String labelText,
    required IconData icon,
    bool hasError = false,
    bool isOptional = false,
  }) {
    return InputDecoration(
      labelText: isOptional ? '$labelText (optional)' : '$labelText *',
      labelStyle: GoogleFonts.poppins(
        color: hasError ? Colors.red : Colors.grey[600],
        fontSize: 14.sp,
      ),
      prefixIcon: Container(
        width: 40.w,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: hasError ? Colors.red : const Color(0xFF3661E2),
          size: 20.w,
        ),
      ),
      suffixIcon: Container(width: 40.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFF3661E2),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      // contentPadding: EdgeInsets.symmetric(vertical: 16.h),
      errorStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        color: Colors.red,
      ),
      floatingLabelStyle: TextStyle(
        color: hasError ? Colors.red : Colors.black,
      ),
    );
  }

  // Dropdown decoration
  static InputDecoration buildDropdownDecoration({
    required String labelText,
    required IconData icon,
    bool hasError = false,
  }) {
    return buildInputDecoration(
      labelText: labelText,
      icon: icon,
      hasError: hasError,
    ).copyWith(
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Icon(
          Icons.arrow_drop_down,
          color: hasError ? Colors.red : Colors.black,
          size: 24.w,
        ),
      ),
    );
  }

  // Button style
  static ButtonStyle primaryButtonStyle({bool isDisabled = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isDisabled ? Colors.grey[400] : const Color(0xFF3661E2),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  // Text style for form fields
  static TextStyle formTextStyle() {
    return GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );
  }

  // Date picker theme
  static ThemeData datePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3661E2),
        onPrimary: Colors.white,
        surface: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF3661E2)),
      ),
    );
  }

  // Cursor color
  static Color get cursorColor => Colors.black;

  // Selection colors
  static TextSelectionThemeData get selectionTheme => TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: const Color(0xFF3661E2).withOpacity(0.3),
    selectionHandleColor: const Color(0xFF3661E2),
  );

  // Helper method to create consistent TextFormField
  // static TextFormField buildTextFormField({
  //   required TextEditingController controller,
  //   required String labelText,
  //   required IconData icon,
  //   required String? Function(String?) validator,
  //   TextInputType keyboardType = TextInputType.text,
  //   TextInputAction textInputAction = TextInputAction.next,
  //   int? maxLength,
  //   List<TextInputFormatter>? inputFormatters,
  //   int? maxLines = 1,
  //   bool hasError = false,
  //   bool isOptional = false,
  //   void Function(String)? onFieldSubmitted,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     cursorColor: cursorColor,
  //     keyboardType: keyboardType,
  //     textInputAction: textInputAction,
  //     maxLength: maxLength,
  //     inputFormatters: inputFormatters,
  //     maxLines: maxLines,
  //     onFieldSubmitted: onFieldSubmitted,
  //     decoration: buildInputDecoration(
  //       labelText: labelText,
  //       icon: icon,
  //       hasError: hasError,
  //       isOptional: isOptional,
  //     ),
  //     style: formTextStyle(),
  //     validator: validator,
  //   );
  // }
}