import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRelations();
  }

  Future<void> _loadRelations() async {
    try {
      _relations = await widget.memberService.getRelations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load relations: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } finally {
      setState(() => _isLoadingRelations = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final member = await widget.memberService.addMember(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        age: int.tryParse(_ageController.text),
        gender: _gender!,
        relationId: _selectedRelationId!,
        contactNumber: _contactController.text,
        email: _emailController.text,
        address: _addressController.text,
        linkingId: widget.linkingId,
      );

      widget.onMemberAdded(member);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add member: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
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
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.person, size: 20.w),
                    ),
                    validator:
                        (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.person_outline, size: 20.w),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Age with Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Age*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            prefixIcon: Icon(Icons.cake, size: 20.w),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age <= 0 || age > 120) {
                              return 'Please enter a valid age (1-120)';
                            }
                            return null;
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
                  // Gender
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Gender*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.transgender, size: 20.w),
                    ),
                    items:
                    ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  // Relation
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Relation to Primary Member*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.group, size: 20.w),
                    ),
                    items:
                    _relations.map((relation) {
                      return DropdownMenuItem<String>(
                        value: relation['id'].toString(),
                        child: Text(
                          relation['relationName'],
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedRelationId = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  // Contact Number
                  TextFormField(
                    maxLength: 10,
                    controller: _contactController,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Contact Number*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.phone, size: 20.w),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact number is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.email, size: 20.w),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      prefixIcon: Icon(Icons.home, size: 20.w),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 24.h),
                  // Submit Button
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
                      child:
                      _isSubmitting
                          ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
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
}