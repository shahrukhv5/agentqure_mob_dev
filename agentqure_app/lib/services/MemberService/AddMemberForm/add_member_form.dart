import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/UserModel/user_model.dart';
import '../member_service.dart';

class AddMemberForm extends StatefulWidget {
  final String linkingId;
  final Function(Map<String, dynamic>) onMemberAdded;
  final MemberService memberService;

  const AddMemberForm({
    super.key,
    required this.linkingId,
    required this.onMemberAdded,
    required this.memberService,
  });

  @override
  _AddMemberFormState createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  String? _selectedRelationId;
  List<Map<String, dynamic>> _relations = [];
  bool _isLoadingRelations = true;
  bool _isSubmitting = false;

  // Track error states for each field
  bool _firstNameHasError = false;
  bool _ageHasError = false;
  bool _genderHasError = false;
  bool _relationHasError = false;
  bool _contactHasError = false;

  String? _formErrorMessage;
  bool _showFormError = false;

  // OTP related states
  bool _isNumberVerified = false;
  String? _verificationId;
  bool _isSendingOtp = false;
  bool _isOtpDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _loadRelations();
    _contactController.addListener(() {
      if (_isNumberVerified) {
        setState(() {
          _isNumberVerified = false;
        });
      }
    });
  }

  Future<void> _loadRelations() async {
    try {
      _relations = await widget.memberService.getRelations();
    } catch (e) {
      // Only show snackbar if still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load relations: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      // Only call setState if the widget is still mounted
      if (mounted) {
        setState(() => _isLoadingRelations = false);
      }
    }
  }

  Future<String?> _sendOtpAndGetVerificationId() async {
    final phoneNumber = _contactController.text.trim();
    if (phoneNumber.isEmpty || !RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber)) {
      setState(() {
        _contactHasError = true;
        _formErrorMessage = 'Please enter a valid 10-digit Indian mobile number';
        _showFormError = true;
      });
      return null;
    }

    setState(() {
      _isSendingOtp = true;
      _contactHasError = false;
      _showFormError = false;
      _formErrorMessage = null;
    });

    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final response = await userModel.sendOtp('91', phoneNumber);


      if (response['message'] == 'SUCCESS' ||
          (response['message'] == 'REQUEST_ALREADY_EXISTS' &&
              response['data']?['verificationId'] != null)) {


        return response['data']['verificationId'];
      } else {
        throw Exception(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    final vid = await _sendOtpAndGetVerificationId();
    if (vid != null) {
      _verificationId = vid;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return OtpDialogContent(
            phoneNumber: _contactController.text,
            verificationId: _verificationId!,
            onVerified: () {
              if (mounted) {
                setState(() => _isNumberVerified = true);
              }
            },
            onResend: _resendOtpInternal,
            onDismiss: _clearVerificationState,
          );
        },
      );
    }
  }

  void _clearVerificationState() {
    if (mounted) {
      setState(() {
        _isNumberVerified = false;
        _verificationId = null;
      });
    }
  }
  Future<void> _resendOtpInternal() async {
    final vid = await _sendOtpAndGetVerificationId();
    if (vid != null) {
      _verificationId = vid;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _formErrorMessage = null;
      _showFormError = false;
      _contactHasError = false;
    });

    if (!_formKey.currentState!.validate()) return;

    // Check if number is verified (only for new numbers)
    if (!_isNumberVerified) {
      setState(() {
        _contactHasError = true;
        _formErrorMessage = 'Please verify the contact number';
        _showFormError = true;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final member = await widget.memberService.addMember(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text),
        gender: _gender!,
        relationId: _selectedRelationId!,
        contactNumber: _contactController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        linkingId: widget.linkingId,
      );

      // Success case - member added successfully
      widget.onMemberAdded(member);
      if (mounted) {
        Navigator.pop(context);
      }
    } on DuplicatePhoneNumberException catch (e) {
      // Handle duplicate phone number - don't show "unverified" error
      setState(() {
        _formErrorMessage = _getUserFriendlyMessage(e.toString());
        _showFormError = true;
        _contactHasError = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          _formKey.currentContext!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      // For other errors, check if it's a duplicate number error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('already exists') ||
          errorString.contains('duplicate') ||
          errorString.contains('already registered')) {
        // This is a duplicate number error
        setState(() {
          _formErrorMessage = _getUserFriendlyMessage(e.toString());
          _showFormError = true;
          _contactHasError = true;
        });
      } else {
        // This is a general error - show unverified message
        setState(() {
          _formErrorMessage = 'Failed to add member: ${e.toString()}';
          _showFormError = true;
          _contactHasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getUserFriendlyMessage(String errorMessage) {
    final lowerCaseError = errorMessage.toLowerCase();

    if (lowerCaseError.contains('contact number already exists as a parent')) {
      return 'This phone number is registered as a primary account. Please use a different number for family members.';
    } else if (lowerCaseError.contains('contact number already exists') ||
        lowerCaseError.contains('duplicate') ||
        lowerCaseError.contains('already registered') ||
        lowerCaseError.contains('already exists')) {
      return 'This phone number is already registered in the system. Please use a different number.';
    }

    return errorMessage;
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
    if (picked != null) {
      final now = DateTime.now();
      int age = now.year - picked.year;
      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
        age--;
      }

      if (mounted) {
        setState(() {
          _ageController.text = age.toString();
          _ageHasError = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon, {bool hasError = false, String? errorText}) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Color(0xFF3661E2), width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
      labelStyle: TextStyle(color: hasError ? Colors.red : Colors.grey[600]),
      floatingLabelStyle: TextStyle(
        color: hasError ? Colors.red : Colors.black,
      ),
      prefixIcon: Icon(icon, size: 20.w, color: hasError ? Colors.red : Color(0xFF3661E2)),
      errorText: errorText,
      errorStyle: TextStyle(color: Colors.red, fontSize: 12.sp),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 60.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Family Member',
                        style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Color(0xFF3661E2)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  if (_showFormError && _formErrorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 16.h, bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.orange[800], size: 20.w),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _formErrorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 16.w),
                            onPressed: () {
                              setState(() {
                                _showFormError = false;
                                _formErrorMessage = null;
                                _contactHasError = false;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _firstNameController,
                    cursorColor: Colors.black,
                    decoration: _buildInputDecoration('First Name*', Icons.person, hasError: _firstNameHasError),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      final hasError = trimmedValue?.isEmpty ?? true;
                      setState(() => _firstNameHasError = hasError);
                      return hasError ? 'Required' : null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _lastNameController,
                    cursorColor: Colors.black,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                    ],
                    decoration: _buildInputDecoration('Last Name', Icons.person_outline),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          cursorColor: Colors.black,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _buildInputDecoration('Age*', Icons.cake, hasError: _ageHasError),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            bool hasError = false;
                            if (value == null || value.isEmpty) {
                              hasError = true;
                            } else {
                              final age = int.tryParse(value);
                              hasError = age == null || age <= 0 || age > 120;
                            }
                            setState(() => _ageHasError = hasError);
                            return hasError ? 'Please enter a valid age (1-120)' : null;
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
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: _buildInputDecoration('Gender*', Icons.transgender, hasError: _genderHasError),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                        _genderHasError = false;
                      });
                    },
                    validator: (value) {
                      final hasError = value == null;
                      setState(() => _genderHasError = hasError);
                      return hasError ? 'Required' : null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: _buildInputDecoration('Relation to Primary Member*', Icons.group, hasError: _relationHasError),
                    items: _relations.map((relation) {
                      return DropdownMenuItem<String>(
                        value: relation['id'].toString(),
                        child: Text(
                          relation['relationName'],
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationId = value;
                        _relationHasError = false;
                      });
                    },
                    validator: (value) {
                      final hasError = value == null;
                      setState(() => _relationHasError = hasError);
                      return hasError ? 'Required' : null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    maxLength: 10,
                    controller: _contactController,
                    cursorColor: Colors.black,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _buildInputDecoration(
                      'Contact Number*',
                      Icons.phone,
                      hasError: _contactHasError,
                      errorText: _contactHasError ? _getContactFieldErrorText() : null,
                      // errorText: _contactHasError ? 'Invalid or unverified number' : null,
                    ).copyWith(
                      // suffixIcon: Container(
                      //   width: 100.w,
                      //   margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                      //   child: ElevatedButton(
                      //     onPressed: _isSendingOtp || _isNumberVerified ? null : _sendOtp,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: _isNumberVerified ? Colors.green : Color(0xFF3661E2),
                      //       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(6.r),
                      //       ),
                      //     ),
                      //     child: _isSendingOtp
                      //         ? SizedBox(
                      //       width: 16.w,
                      //       height: 16.h,
                      //       child: CircularProgressIndicator(
                      //         strokeWidth: 2,
                      //         color: Colors.white,
                      //       ),
                      //     )
                      //         : Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(
                      //           _isNumberVerified ? Icons.check_circle : Icons.verified_user,
                      //           size: 16.w,
                      //           color: Colors.white,
                      //         ),
                      //         SizedBox(width: 2.w),
                      //         Text(
                      //           _isNumberVerified ? 'Verified' : 'Verify',
                      //           style: TextStyle(
                      //             fontSize: 14.sp,
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // suffixIcon: Container(
                      //   width: 100.w,
                      //   margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                      //   child: _isSendingOtp
                      //       ? Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey,
                      //       borderRadius: BorderRadius.circular(6.r),
                      //     ),
                      //     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      //     child: SizedBox(
                      //       width: 16.w,
                      //       height: 16.h,
                      //       child: CircularProgressIndicator(
                      //         strokeWidth: 2,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   )
                      //       : _isNumberVerified
                      //       ? Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.green,
                      //       borderRadius: BorderRadius.circular(6.r),
                      //     ),
                      //     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(
                      //           Icons.check_circle,
                      //           size: 16.w,
                      //           color: Colors.white,
                      //         ),
                      //         SizedBox(width: 2.w),
                      //         Text(
                      //           'Verified',
                      //           style: TextStyle(
                      //             fontSize: 14.sp,
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      //       : ElevatedButton(
                      //     onPressed: _sendOtp,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Color(0xFF3661E2),
                      //       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(6.r),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(
                      //           Icons.verified_user,
                      //           size: 16.w,
                      //           color: Colors.white,
                      //         ),
                      //         SizedBox(width: 2.w),
                      //         Text(
                      //           'Verify',
                      //           style: TextStyle(
                      //             fontSize: 14.sp,
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      suffixIcon: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                        child: _isSendingOtp
                            ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                          child: Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                            : _isNumberVerified
                            ? Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16.w,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3661E2),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 16.w,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      bool hasError = false;
                      if (value == null || value.isEmpty) {
                        hasError = true;
                      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        hasError = true;
                      }
                      setState(() => _contactHasError = hasError);
                      return hasError ? 'Enter a valid 10-digit Indian mobile number' : null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _emailController,
                    cursorColor: Colors.black,
                    decoration: _buildInputDecoration('Email', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _addressController,
                    cursorColor: Colors.black,
                    decoration: _buildInputDecoration('Address', Icons.home),
                    maxLines: 2,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3661E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        'Add Member',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _getContactFieldErrorText() {
    if (_formErrorMessage != null) {
      final lowerCaseError = _formErrorMessage!.toLowerCase();
      if (lowerCaseError.contains('already exists') ||
          lowerCaseError.contains('duplicate') ||
          lowerCaseError.contains('already registered')) {
        return 'This phone number is already registered';
      }
    }

    // Default error for invalid or unverified numbers
    return 'Invalid or unverified number';
  }
}

class OtpDialogContent extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final VoidCallback onVerified;
  final Future<void> Function() onResend;
  final VoidCallback onDismiss;

  const OtpDialogContent({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.onVerified,
    required this.onResend,
    required this.onDismiss,
  });

  @override
  State<OtpDialogContent> createState() => _OtpDialogContentState();
}

class _OtpDialogContentState extends State<OtpDialogContent> with SingleTickerProviderStateMixin {
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;
  bool isVerifying = false;
  String? errorMessage;

  // Resend OTP timer variables
  bool _canResend = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;
  late AnimationController _resendButtonAnimationController;
  late Animation<double> _resendButtonScaleAnimation;

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());

    // Initialize resend timer
    _startResendTimer();

    // Initialize resend button animation
    _resendButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _resendButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _resendButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    focusNodes[0].requestFocus();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) {
          setState(() => _resendCountdown--);
        }
      } else {
        if (mounted) {
          setState(() => _canResend = true);
        }
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    // Reset timer and state
    _startResendTimer();

    // Clear error and OTP fields
    setState(() {
      errorMessage = null;
      isVerifying = false;
    });

    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();

    try {
      await widget.onResend();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to resend OTP. Please try again.';
        });
      }
    }
  }

  void _handleDismiss() {
    _resendTimer?.cancel();
    widget.onDismiss();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    _resendButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3661E2),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.w),
                    onPressed: () {
                      _handleDismiss();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter the OTP sent to +91 ${widget.phoneNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => SizedBox(
                  width: 60.w,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: errorMessage != null ? Colors.red : Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: errorMessage != null ? Colors.red : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: errorMessage != null ? Colors.red : Color(0xFF3661E2),
                            width: 2.w
                        ),
                      ),
                      filled: true,
                      fillColor: errorMessage != null ? Colors.red[50] : Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 0),
                    ),
                    onChanged: (value) {
                      // Clear error when user starts typing
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                      }
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                      }
                    },
                  ),
                )),
              ),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16.w),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16.h),

              Center(
                child: GestureDetector(
                  onTapDown: _canResend ? (_) => _resendButtonAnimationController.forward() : null,
                  onTapUp: _canResend ? (_) {
                    _resendButtonAnimationController.reverse();
                    _resendOtp();
                  } : null,
                  onTapCancel: _canResend ? () => _resendButtonAnimationController.reverse() : null,
                  child: ScaleTransition(
                    scale: _resendButtonScaleAnimation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 16.w,
                          color: _canResend ? Color(0xFF3661E2) : Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _canResend ? 'Resend OTP' : 'Resend OTP in $_resendCountdown s',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: _canResend ? Color(0xFF3661E2) : Colors.grey,
                            fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : () async {
                    setState(() {
                      isVerifying = true;
                      errorMessage = null;
                    });

                    final otp = otpControllers.map((c) => c.text).join();

                    if (otp.length == 4) {
                      try {
                        final userModel = Provider.of<UserModel>(context, listen: false);
                        final response = await userModel.validateOtp(widget.verificationId, otp);
                        if (response['message'] == 'SUCCESS' && response['data']['verificationStatus'] == 'VERIFICATION_COMPLETED') {
                          widget.onVerified();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone number verified successfully!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                        } else {
                          String errorMsg = 'Invalid OTP. Please check and try again.';
                          if (response['message']?.contains('expired') == true) {
                            errorMsg = 'OTP has expired. Please request a new one.';
                          } else if (response['message']?.contains('attempt') == true) {
                            errorMsg = 'Too many failed attempts. Please try again later.';
                          }
                          setState(() => errorMessage = errorMsg);
                        }
                      } catch (e) {
                        String errorMsg = 'Verification failed. Please try again.';
                        if (e.toString().contains('timeout')) {
                          errorMsg = 'Request timed out. Please check your internet connection.';
                        } else if (e.toString().contains('network')) {
                          errorMsg = 'Network error. Please check your internet connection.';
                        } else if (e.toString().contains('Invalid OTP')) {
                          errorMsg = 'The OTP you entered is incorrect. Please try again.';
                        }
                        setState(() => errorMessage = errorMsg);
                      }
                    } else {
                      setState(() => errorMessage = 'Please enter all 4 digits of the OTP');
                    }

                    setState(() => isVerifying = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3661E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: isVerifying
                      ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Text(
                    'Verify OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
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
    );
  }
}
