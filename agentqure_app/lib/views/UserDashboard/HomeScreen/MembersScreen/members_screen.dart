import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../models/UserModel/user_model.dart';
import '../../../../services/MemberService/AddMemberForm/add_member_form.dart';
import '../../../../services/MemberService/member_service.dart'
    show MemberService;

class MembersScreen extends StatefulWidget {
  final UserModel userModel;

  const MembersScreen({super.key, required this.userModel});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late UserModel userModel;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isProcessingFullScreen = false;
  List<Map<String, dynamic>> relations = [];
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/relation/list-relations',
      );
      print('Relations API response: ${response.data}');

      if (response.data != null &&
          response.data['body'] != null &&
          response.data['body']['data'] != null) {
        relations = List<Map<String, dynamic>>.from(
          response.data['body']['data'].map(
                (item) => {
              'id': item['id'].toString(),
              'relationName': item['relationName'],
            },
          ),
        );
        print('Relations loaded: $relations');
      } else {
        print('No relations data found in response');
      }

      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phoneNumber');
      if (phone != null) {
        print('Loading user data for phone: $phone');
        await userModel.getUserByPhone(phone);
        print(
          'Children after getUserByPhone in _loadData: ${userModel.children}',
        );
      } else {
        print('No phone number found in SharedPreferences');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          print('Loading complete, isLoading: $_isLoading');
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Widget _buildShimmerMemberCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16.w),
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
                        width: 100.w,
                        height: 12.h,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                Container(width: 24.w, height: 24.h, color: Colors.grey[300]),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 60.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: kToolbarHeight, color: Colors.white),
            SizedBox(height: 16.h),
            _buildShimmerMemberCard(),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Container(width: 150.w, height: 16.h, color: Colors.white),
            ),
            for (int i = 0; i < 3; i++) _buildShimmerMemberCard(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: Text(
          'Family Members',
          style: GoogleFonts.poppins(
            color: Color(0xFF3661E2),
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3661E2)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (!_isProcessingFullScreen)
            _isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildShimmerMemberCard(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Container(
                        width: 150.w,
                        height: 16.h,
                        color: Colors.grey[300],
                      ),
                    ),
                    _buildShimmerMemberCard(),
                    _buildShimmerMemberCard(),
                    _buildShimmerMemberCard(),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildMembersList(),
            ),
          if (_isProcessingFullScreen) _buildFullScreenShimmer(),
        ],
      ),
      floatingActionButton:
      _isProcessingFullScreen
          ? null
          : (userModel.children?.length ?? 0) < 4
          ? FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _showAddMemberForm(),
        icon:
        _isProcessing
            ? SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Icon(
          Icons.person_add,
          color: Colors.white,
          size: 20.w,
        ),
        label: Text(
          'Add Member',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color(0xFF3661E2),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
      )
          : null,
    );
  }

  Widget _buildMembersList() {
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        final primaryMember = userModel.currentUser;
        final children = userModel.children ?? [];
        print('Children in _buildMembersList: $children');

        if (primaryMember == null && children.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 60.w, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'No family members yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the + button to add your first member',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 80.h),
          children: [
            if (primaryMember != null) _buildMemberCard(primaryMember, true),
            if (children.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Text(
                  'Family Members (${children.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            if (children.isEmpty) _buildEmptyState(),
            ...children.map(
                  (child) => _buildMemberCard(_convertChildToMap(child), false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(Icons.child_care, size: 60.w, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No family members added yet',
            style: GoogleFonts.poppins(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _convertChildToMap(dynamic child) {
    if (child is Map<String, dynamic>) return child;
    print('Failed to convert child: $child (type: ${child.runtimeType})');
    return {};
  }

  Widget _buildMemberCard(Map<String, dynamic> member, bool isPrimary) {
    if (member.isEmpty) {
      return const SizedBox.shrink();
    }

    final isParent =
    member['is_parent'] is bool
        ? member['is_parent'] as bool?
        : member['is_parent'] == 1;

    final relation =
    isPrimary
        ? 'Primary Member'
        : relations.firstWhere(
          (r) =>
      r['id'].toString() ==
          member['parent_child_relation'].toString(),
      orElse: () => {'relationName': 'Unknown'},
    )['relationName'];

    final avatarColor = _getAvatarColor(member['firstName']);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[300]!, width: 1.w),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showMemberDetails(member, isPrimary),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 24.r,
                    child: Text(
                      member['firstName'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member['firstName']} ${member['lastName'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          relation,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPrimary)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 24.w),
                      color: Colors.grey.shade50,
                      itemBuilder:
                          (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20.w),
                              SizedBox(width: 8.w),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 20.w,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditMemberForm(member);
                        } else if (value == 'delete') {
                          _deleteMember(member);
                        }
                      },
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  if (member['age'] != null)
                    _buildInfoChip(
                      icon: Icons.cake,
                      label: '${member['age']} Years',
                    ),
                  if (member['gender'] != null)
                    _buildInfoChip(
                      icon:
                      member['gender'] == 'Male'
                          ? Icons.male
                          : Icons.female,
                      label: member['gender'],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 14.sp)),
        ],
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[name.hashCode % colors.length];
  }

  void _showMemberDetails(Map<String, dynamic> member, bool isPrimary) {
    final relation =
    isPrimary
        ? 'Primary Member'
        : relations.firstWhere(
          (r) =>
      r['id'].toString() ==
          member['parent_child_relation'].toString(),
      orElse: () => {'relationName': 'Unknown'},
    )['relationName'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  children: [
                    CircleAvatar(
                      backgroundColor: _getAvatarColor(member['firstName']),
                      radius: 30.r,
                      child: Text(
                        member['firstName'][0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${member['firstName']} ${member['lastName'] ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            relation,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isPrimary)
                      IconButton(
                        icon: Icon(Icons.edit, size: 24.w),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditMemberForm(member);
                        },
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildDetailRow(
                  Icons.person,
                  'Name',
                  '${member['firstName']} ${member['lastName'] ?? ''}',
                ),
                if (member['age'] != null)
                  _buildDetailRow(Icons.cake, 'Age', '${member['age']} years'),
                if (member['gender'] != null)
                  _buildDetailRow(
                    member['gender'] == 'Male' ? Icons.male : Icons.female,
                    'Gender',
                    member['gender'],
                  ),
                if (member['contactNumber'] != null)
                  _buildDetailRow(
                    Icons.phone,
                    'Contact',
                    member['contactNumber'],
                  ),
                if (member['emailId'] != null && member['emailId'].isNotEmpty)
                  _buildDetailRow(Icons.email, 'Email', member['emailId']),
                if (member['address'] != null && member['address'].isNotEmpty)
                  _buildDetailRow(Icons.home, 'Address', member['address']),
                SizedBox(height: 20.h),
                if (!isPrimary)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteMember(member);
                      },
                      child: Text(
                        'Remove Member',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24.w, color: Colors.grey),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(value, style: GoogleFonts.poppins(fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberForm() {
    final memberService = MemberService(Dio());
    final primaryUser = userModel.currentUser;

    if (primaryUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddMemberForm(
          linkingId: primaryUser['appUserId'].toString(),
          memberService: memberService,
          onMemberAdded: (newMember) {
            _loadData();
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

  // void _showEditMemberForm(Map<String, dynamic> member) {
  //   final formKey = GlobalKey<FormState>();
  //   final firstNameController = TextEditingController(
  //     text: member['firstName'],
  //   );
  //   final lastNameController = TextEditingController(
  //     text: member['lastName'] ?? '',
  //   );
  //   final ageController = TextEditingController(
  //     text: member['age']?.toString() ?? '',
  //   );
  //   final contactController = TextEditingController(
  //     text: member['contactNumber'] ?? '',
  //   );
  //   final emailController = TextEditingController(
  //     text: member['emailId'] ?? '',
  //   );
  //   final addressController = TextEditingController(
  //     text: member['address'] ?? '',
  //   );
  //   String? gender = member['gender'];
  //   String? selectedRelationId = member['parent_child_relation']?.toString();
  //
  //   // Method to show date picker and calculate age
  //   Future<void> _selectDate() async {
  //     final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: DateTime.now().subtract(Duration(days: 365 * 30)),
  //       firstDate: DateTime(1900),
  //       lastDate: DateTime.now(),
  //       builder: (context, child) {
  //         return Theme(
  //           data: Theme.of(context).copyWith(
  //             colorScheme: ColorScheme.light(
  //               primary: Color(0xFF3661E2),
  //               onPrimary: Colors.white,
  //               surface: Colors.white,
  //             ),
  //             textButtonTheme: TextButtonThemeData(
  //               style: TextButton.styleFrom(foregroundColor: Color(0xFF3661E2)),
  //             ),
  //           ),
  //           child: child!,
  //         );
  //       },
  //     );
  //     if (picked != null && mounted) {
  //       final now = DateTime.now();
  //       int age = now.year - picked.year;
  //       // Adjust age if birthday hasn't occurred this year
  //       if (now.month < picked.month ||
  //           (now.month == picked.month && now.day < picked.day)) {
  //         age--;
  //       }
  //       ageController.text = age.toString();
  //     }
  //   }
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return SingleChildScrollView(
  //             padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom,
  //             ),
  //             child: Padding(
  //               padding: EdgeInsets.all(20.w),
  //               child: Form(
  //                 key: formKey,
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Center(
  //                       child: Container(
  //                         width: 60.w,
  //                         height: 4.h,
  //                         margin: EdgeInsets.only(bottom: 16.h),
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[300],
  //                           borderRadius: BorderRadius.circular(2.r),
  //                         ),
  //                       ),
  //                     ),
  //                     Text(
  //                       'Edit Family Member',
  //                       style: GoogleFonts.poppins(
  //                         fontSize: 20.sp,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     SizedBox(height: 20.h),
  //                     // First Name
  //                     TextFormField(
  //                       controller: firstNameController,
  //                       decoration: InputDecoration(
  //                         labelText: 'First Name*',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.person, size: 20.w),
  //                       ),
  //                       validator:
  //                           (value) =>
  //                       value?.isEmpty ?? true ? 'Required' : null,
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Last Name
  //                     TextFormField(
  //                       controller: lastNameController,
  //                       decoration: InputDecoration(
  //                         labelText: 'Last Name',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.person_outline, size: 20.w),
  //                       ),
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Age with Date Picker
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: TextFormField(
  //                             controller: ageController,
  //                             inputFormatters: [
  //                               FilteringTextInputFormatter.deny(RegExp(r'\s')),
  //                               FilteringTextInputFormatter.digitsOnly,
  //                             ],
  //                             decoration: InputDecoration(
  //                               labelText: 'Age*',
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(10.r),
  //                               ),
  //                               prefixIcon: Icon(Icons.cake, size: 20.w),
  //                             ),
  //                             keyboardType: TextInputType.number,
  //                             validator: (value) {
  //                               if (value == null || value.isEmpty) {
  //                                 return 'Required';
  //                               }
  //                               final age = int.tryParse(value);
  //                               if (age == null || age <= 0 || age > 120) {
  //                                 return 'Please enter a valid age (1-120)';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                         ),
  //                         SizedBox(width: 8.w),
  //                         IconButton(
  //                           onPressed: _selectDate,
  //                           icon: Icon(
  //                             Icons.calendar_today,
  //                             color: Color(0xFF3661E2),
  //                             size: 24.w,
  //                           ),
  //                           tooltip: "Select Date of Birth",
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Gender
  //                     DropdownButtonFormField<String>(
  //                       decoration: InputDecoration(
  //                         labelText: 'Gender*',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.transgender, size: 20.w),
  //                       ),
  //                       value: gender,
  //                       items:
  //                       ['Male', 'Female', 'Other']
  //                           .map(
  //                             (String value) => DropdownMenuItem<String>(
  //                           value: value,
  //                           child: Text(
  //                             value,
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 14.sp,
  //                             ),
  //                           ),
  //                         ),
  //                       )
  //                           .toList(),
  //                       onChanged: (value) => setState(() => gender = value),
  //                       validator: (value) => value == null ? 'Required' : null,
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Relation
  //                     DropdownButtonFormField<String>(
  //                       decoration: InputDecoration(
  //                         labelText: 'Relation to Primary Member*',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.group, size: 20.w),
  //                       ),
  //                       value: selectedRelationId,
  //                       items:
  //                       relations
  //                           .map(
  //                             (relation) => DropdownMenuItem<String>(
  //                           value: relation['id'].toString(),
  //                           child: Text(
  //                             relation['relationName'],
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 14.sp,
  //                             ),
  //                           ),
  //                         ),
  //                       )
  //                           .toList(),
  //                       onChanged:
  //                           (value) =>
  //                           setState(() => selectedRelationId = value),
  //                       validator: (value) => value == null ? 'Required' : null,
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Contact Number
  //                     TextFormField(
  //                       maxLength: 10,
  //                       controller: contactController,
  //                       inputFormatters: [
  //                         FilteringTextInputFormatter.deny(RegExp(r'\s')),
  //                         FilteringTextInputFormatter.digitsOnly,
  //                       ],
  //                       decoration: InputDecoration(
  //                         labelText: 'Contact Number*',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.phone, size: 20.w),
  //                       ),
  //                       keyboardType: TextInputType.phone,
  //                       validator: (value) {
  //                         if (value == null || value.isEmpty) {
  //                           return 'Contact number is required';
  //                         }
  //                         return null;
  //                       },
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Email
  //                     TextFormField(
  //                       controller: emailController,
  //                       decoration: InputDecoration(
  //                         labelText: 'Email',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.email, size: 20.w),
  //                       ),
  //                       keyboardType: TextInputType.emailAddress,
  //                     ),
  //                     SizedBox(height: 16.h),
  //                     // Address
  //                     TextFormField(
  //                       controller: addressController,
  //                       decoration: InputDecoration(
  //                         labelText: 'Address',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10.r),
  //                         ),
  //                         prefixIcon: Icon(Icons.home, size: 20.w),
  //                       ),
  //                       maxLines: 2,
  //                     ),
  //                     SizedBox(height: 24.h),
  //                     // Update Button
  //                     SizedBox(
  //                       width: double.infinity,
  //                       height: 50.h,
  //                       child: ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Color(0xFF3661E2),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10.r),
  //                           ),
  //                         ),
  //                         onPressed: () async {
  //                           if (formKey.currentState!.validate()) {
  //                             Navigator.pop(context);
  //                             await _updateMember(
  //                               member: member,
  //                               firstName: firstNameController.text,
  //                               lastName: lastNameController.text,
  //                               age: int.tryParse(ageController.text),
  //                               gender: gender!,
  //                               relationId: selectedRelationId!,
  //                               contactNumber: contactController.text,
  //                               email: emailController.text,
  //                               address: addressController.text,
  //                             );
  //                           }
  //                         },
  //                         child: Text(
  //                           'Update Member',
  //                           style: GoogleFonts.poppins(
  //                             fontSize: 16.sp,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void _showEditMemberForm(Map<String, dynamic> member) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: member['firstName'],
    );
    final lastNameController = TextEditingController(
      text: member['lastName'] ?? '',
    );
    final ageController = TextEditingController(
      text: member['age']?.toString() ?? '',
    );
    final contactController = TextEditingController(
      text: member['contactNumber'] ?? '',
    );
    final emailController = TextEditingController(
      text: member['emailId'] ?? '',
    );
    final addressController = TextEditingController(
      text: member['address'] ?? '',
    );
    String? gender = member['gender'];
    String? selectedRelationId = member['parent_child_relation']?.toString();

    // Track error states for each field
    bool firstNameHasError = false;
    bool ageHasError = false;
    bool genderHasError = false;
    bool relationHasError = false;
    bool contactHasError = false;

    // Method to show date picker and calculate age
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
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        // Just update the controller text without setState since we're in a StatefulBuilder
        ageController.text = age.toString();
      }
    }
    // Future<void> _selectDate() async {
    //   final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: DateTime.now().subtract(Duration(days: 365 * 30)),
    //     firstDate: DateTime(1900),
    //     lastDate: DateTime.now(),
    //     builder: (context, child) {
    //       return Theme(
    //         data: Theme.of(context).copyWith(
    //           colorScheme: ColorScheme.light(
    //             primary: Color(0xFF3661E2),
    //             onPrimary: Colors.white,
    //             surface: Colors.white,
    //           ),
    //           textButtonTheme: TextButtonThemeData(
    //             style: TextButton.styleFrom(foregroundColor: Color(0xFF3661E2)),
    //           ),
    //         ),
    //         child: child!,
    //       );
    //     },
    //   );
    //   if (picked != null && mounted) {
    //     final now = DateTime.now();
    //     int age = now.year - picked.year;
    //     // Adjust age if birthday hasn't occurred this year
    //     if (now.month < picked.month ||
    //         (now.month == picked.month && now.day < picked.day)) {
    //       age--;
    //     }
    //     ageController.text = age.toString();
    //   }
    // }

    InputDecoration _buildInputDecoration(String labelText, IconData icon, {bool hasError = false}) {
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
        errorStyle: TextStyle(color: Colors.red),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Form(
                      key: formKey,
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
                                'Edit Family Member',
                                style: GoogleFonts.poppins(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3661E2)
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
                            controller: firstNameController,
                            cursorColor: Colors.black,
                            decoration: _buildInputDecoration('First Name*', Icons.person, hasError: firstNameHasError),
                            validator: (value) {
                              final trimmedValue = value?.trim();
                              final hasError = trimmedValue?.isEmpty ?? true;
                              setState(() => firstNameHasError = hasError);
                              return hasError ? 'Required' : null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          // Last Name
                          TextFormField(
                            controller: lastNameController,
                            cursorColor: Colors.black,
                            decoration: _buildInputDecoration('Last Name', Icons.person_outline),
                          ),
                          SizedBox(height: 16.h),
                          // Age with Date Picker
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: ageController,
                                  cursorColor: Colors.black,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: _buildInputDecoration('Age*', Icons.cake, hasError: ageHasError),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    bool hasError = false;
                                    if (value == null || value.isEmpty) {
                                      hasError = true;
                                    } else {
                                      final age = int.tryParse(value);
                                      hasError = age == null || age <= 0 || age > 120;
                                    }
                                    setState(() => ageHasError = hasError);
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
                          // Gender
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration('Gender*', Icons.transgender, hasError: genderHasError),
                            value: gender,
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
                                gender = value;
                                genderHasError = false;
                              });
                            },
                            validator: (value) {
                              final hasError = value == null;
                              setState(() => genderHasError = hasError);
                              return hasError ? 'Required' : null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          // Relation
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration('Relation to Primary Member*', Icons.group, hasError: relationHasError),
                            value: selectedRelationId,
                            items: relations.map((relation) {
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
                                selectedRelationId = value;
                                relationHasError = false;
                              });
                            },
                            validator: (value) {
                              final hasError = value == null;
                              setState(() => relationHasError = hasError);
                              return hasError ? 'Required' : null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          // Contact Number
                          TextFormField(
                            maxLength: 10,
                            controller: contactController,
                            cursorColor: Colors.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _buildInputDecoration('Contact Number*', Icons.phone, hasError: contactHasError),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final trimmedValue = value?.trim();
                              final hasError = trimmedValue?.isEmpty ?? true;
                              setState(() => contactHasError = hasError);
                              return hasError ? 'Contact number is required' : null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          // Email
                          TextFormField(
                            controller: emailController,
                            cursorColor: Colors.black,
                            decoration: _buildInputDecoration('Email', Icons.email),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16.h),
                          // Address
                          TextFormField(
                            controller: addressController,
                            cursorColor: Colors.black,
                            decoration: _buildInputDecoration('Address', Icons.home),
                            maxLines: 2,
                          ),
                          SizedBox(height: 24.h),
                          // Update Button
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
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(context);
                                  await _updateMember(
                                    member: member,
                                    firstName: firstNameController.text.trim(),
                                    lastName: lastNameController.text.trim(),
                                    age: int.tryParse(ageController.text),
                                    gender: gender!,
                                    relationId: selectedRelationId!,
                                    contactNumber: contactController.text.trim(),
                                    email: emailController.text.trim(),
                                    address: addressController.text.trim(),
                                  );
                                }
                              },
                              child: Text(
                                'Update Member',
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
          },
        );
      },
    );
  }
  Future<void> _updateMember({
    required Map<String, dynamic> member,
    required String firstName,
    required String lastName,
    required int? age,
    required String gender,
    required String relationId,
    required String contactNumber,
    required String email,
    required String address,
  }) async {
    setState(() => _isProcessingFullScreen = true);
    try {
      final response = await _dio.put(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user',
        data: {
          "appUserId": member['appUserId'],
          "firstName": firstName,
          "lastName": lastName,
          "contactNumber": contactNumber,
          "emailId": email,
          "address": address,
          "gender": gender,
          "age": age,
          "parent_child_relation": relationId,
        },
      );
      print('Update member response: ${response.data}');

      final primaryUser = userModel.currentUser;
      if (primaryUser != null) {
        if (mounted) {
          await userModel.getUserByPhone(primaryUser['contactNumber']);
          print('Children after updating member: ${userModel.children}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      print('Error updating member: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update member: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } finally {
      setState(() => _isProcessingFullScreen = false);
    }
  }

  Future<void> _deleteMember(Map<String, dynamic> member) async {
    final primaryUser = userModel.currentUser;
    if (primaryUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Primary user not found'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Remove Member',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.2)),
            ),
            child: Text('Cancel',style: GoogleFonts.poppins(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
            ),
            child: Text('Remove',  style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _isProcessingFullScreen = true);

    try {
      final response = await _dio.delete(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user?id=${member['appUserId']}',
      );
      print('Delete member response: ${response.data}');

      if (!mounted) return;
      await userModel.getUserByPhone(primaryUser['contactNumber']);
      print('Children after deleting member: ${userModel.children}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Member removed successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting member: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove member: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingFullScreen = false);
      }
    }
  }
}