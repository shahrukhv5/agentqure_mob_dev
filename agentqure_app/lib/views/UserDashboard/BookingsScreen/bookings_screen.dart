import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../models/UserModel/user_model.dart';
import '../../../utils/CustomBottomNavigationBar/custom_bottom_navigation_bar.dart';
import '../../../utils/NavigationUtils/navigation_utils.dart';
import '../../../services/ApiService/api_service.dart';

class BookingsScreen extends StatefulWidget {
  final UserModel userModel;

  BookingsScreen({super.key, required this.userModel});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _isLoading = true;
  int _selectedIndex = 1;
  List<dynamic> _bookings = [];
  List<dynamic> _childrenBookings = [];
  List<dynamic> _filteredBookings = [];
  String _searchQuery = '';
  String _searchType = 'Test Name';
  DateTime? _selectedDate;
  String? _selectedStatus;
  bool _dateParsingError = false;
  late CancelToken _cancelToken;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final userId = widget.userModel.currentUser?['appUserId'];
      if (userId == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final response = await _apiService.fetchUserBookings(userId.toString());

      if (response.statusCode == 200) {
        final responseData = response.data['body'];
        if (mounted) {
          setState(() {
            _bookings = responseData['bookings'] ?? [];
            _childrenBookings = [];

            // Process children's bookings with their names
            final children = responseData['children'] ?? [];
            for (var child in children) {
              if (child['bookings'] != null && child['bookings'].isNotEmpty) {
                // Add child info to each booking
                final childBookings =
                (child['bookings'] as List).map((booking) {
                  return {
                    ...booking,
                    'isChildBooking': true,
                    'childFirstName': child['firstName'],
                    'childLastName': child['lastName'],
                  };
                }).toList();
                _childrenBookings.addAll(childBookings);
              }
            }

            _filteredBookings = [..._bookings, ..._childrenBookings]..sort(
                  (a, b) => (b['bookingId'] ?? '').compareTo(a['bookingId'] ?? ''),
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Failed to load bookings', Colors.red[600]!);
        }
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        print('Error loading orders: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar(
            'Error loading bookings: ${e.message}',
            Colors.red[600]!,
          );
        }
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error loading bookings: $e', Colors.red[600]!);
      }
    }
  }

  Future<void> _cancelBooking(dynamic booking) async {
    try {
      final bookingId = booking['bookingId']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        _showSnackBar(
          'Cannot cancel booking: Invalid booking ID',
          Colors.red[600]!,
        );
        return;
      }

      final bool confirmCancel = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Cancellation', style: GoogleFonts.poppins()),
          content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No', style: GoogleFonts.poppins(color: Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes, Cancel',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmCancel != true) return;

      _showSnackBar('Cancelling booking...', Colors.blue[600]!);

      final data = {
        'bookingId': bookingId,
        'bookingStatus': 'Cancelled',
        'notes': 'Cancelled by user',
      };
      final response = await _apiService.updateBookingStatus(data);

      if (response.statusCode == 200) {
        _showSnackBar('Booking cancelled successfully', Colors.green[600]!);

        _loadOrders();
      } else {
        _showSnackBar('Failed to cancel booking', Colors.red[600]!);
      }
    } on DioException catch (e) {
      print('Dio error cancelling booking: ${e.message}');
      _showSnackBar(
        'Error cancelling booking: ${e.message ?? 'Network error'}',
        Colors.red[600]!,
      );
    } catch (e) {
      print('Error cancelling booking: $e');
      _showSnackBar(
        'Error cancelling booking: ${e.toString()}',
        Colors.red[600]!,
      );
    }
  }
  void _onItemTapped(int index) {
    NavigationUtils.handleNavigation(
      context,
      index,
      _selectedIndex,
          (newIndex) => setState(() => _selectedIndex = newIndex),
      widget.userModel,
    );
  }

  String _formatBookingStatus(dynamic booking) {
    final collectStatus =
        booking['collectionStatus']?.toString().toLowerCase() ?? 'pending';
    final receiveStatus =
        booking['receiverStatus']?.toString().toLowerCase() ?? 'pending';
    final processStatus =
        booking['processingStatus']?.toString().toLowerCase() ?? 'pending';

    if (collectStatus == 'draft' &&
        receiveStatus == 'draft' &&
        processStatus == 'draft') {
      return 'Initiated';
    }
    if (collectStatus == 'cancelled' ||
        receiveStatus == 'cancelled' ||
        processStatus == 'cancelled') {
      return 'Cancelled';
    }
    if (collectStatus == 'pending' &&
        receiveStatus == 'pending' &&
        processStatus == 'pending') {
      return 'In Collection';
    }
    if (collectStatus == 'collected' &&
        receiveStatus == 'pending' &&
        processStatus == 'pending') {
      return 'In Processing';
    }
    if (collectStatus == 'collected' &&
        receiveStatus == 'received' &&
        [
          'pending',
          'incomplete',
          'completed',
          'signed',
        ].contains(processStatus)) {
      return 'In Processing';
    }
    if (collectStatus == 'collected' &&
        receiveStatus == 'received' &&
        processStatus == 'dispatched') {
      return 'Completed';
    }
    return '';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Initiated':
        return const Color(0xFF9E9E9E);
      case 'In Collection':
        return const Color(0xFF0288D1);
      case 'In Processing':
        return const Color(0xFF388E3C);
      case 'Completed':
        return const Color(0xFF6A1B9A);
      case 'Cancelled':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Initiated':
        return const Color(0xFF9E9E9E).withOpacity(0.15);
      case 'In Collection':
        return const Color(0xFF0288D1).withOpacity(0.15);
      case 'In Processing':
        return const Color(0xFF388E3C).withOpacity(0.15);
      case 'Completed':
        return const Color(0xFF6A1B9A).withOpacity(0.15);
      case 'Cancelled':
        return const Color(0xFFD32F2F).withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Initiated':
        return Icons.access_time;
      case 'In Collection':
        return Icons.move_to_inbox;
      case 'In Processing':
        return Icons.check_circle;
      case 'Completed':
        return Icons.local_shipping;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  DateTime? _parseBookingDate(String? date) {
    if (date == null || date.isEmpty) return null;

    try {
      // First try DateTime.parse as fallback
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return parsed;

      List<String> parts;
      bool isSlash = date.contains('/');
      bool isDash = date.contains('-');

      if (!isSlash && !isDash) return null;

      parts = date.split(isSlash ? '/' : '-');

      if (parts.length != 3) return null;

      int? year, month, day;

      // If first part is 4 digits, assume YYYY separator MM separator DD
      if (parts[0].length == 4) {
        year = int.tryParse(parts[0]);
        month = int.tryParse(parts[1]);
        day = int.tryParse(parts[2]);
      }
      // If last part is 4 digits, assume DD separator MM separator YYYY
      else if (parts[2].length == 4) {
        day = int.tryParse(parts[0]);
        month = int.tryParse(parts[1]);
        year = int.tryParse(parts[2]);
      }
      // If middle is month, check ranges
      else {
        day = int.tryParse(parts[0]);
        month = int.tryParse(parts[1]);
        year = int.tryParse(parts[2]);
        if (month == null || month < 1 || month > 12) {
          // Swap day and month if invalid
          final temp = day;
          day = month;
          month = temp;
          if (month == null || month < 1 || month > 12) return null;
        }
      }

      if (year == null || month == null || day == null) return null;

      // Handle 2-digit years
      if (year < 100) year += 2000;

      // Validate date
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;

      return DateTime(year, month, day);
    } catch (e) {
      print('Date parsing error for "$date": $e');
      return null;
    }
  }
  void _filterBookings() {
    setState(() {
      _filteredBookings = [..._bookings, ..._childrenBookings];
      _dateParsingError = false;

      if (_searchQuery.isNotEmpty ||
          _selectedDate != null ||
          _selectedStatus != null) {
        _filteredBookings =
            _filteredBookings.where((booking) {
              final testName =
                  booking['testName']?.toString().toLowerCase() ?? '';
              final bookingDate = booking['bookingDate']?.toString() ?? '';
              final bookingStatus = _formatBookingStatus(booking);

              bool matchesSearch = true;
              bool matchesDate = true;
              bool matchesStatus = true;

              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase().trim();
                if (_searchType == 'Test Name') {
                  matchesSearch = testName.contains(query);
                } else if (_searchType == 'Status') {
                  matchesSearch = bookingStatus.toLowerCase().contains(query);
                }
              }

              if (_selectedDate != null) {
                final date = _parseBookingDate(bookingDate);
                if (date == null) {
                  _dateParsingError = true;
                  matchesDate = false;
                } else {
                  matchesDate =
                      date.year == _selectedDate!.year &&
                          date.month == _selectedDate!.month &&
                          date.day == _selectedDate!.day;
                }
              }

              if (_selectedStatus != null &&
                  _selectedStatus != 'All Statuses') {
                matchesStatus = bookingStatus == _selectedStatus;
              }

              return matchesSearch && matchesDate && matchesStatus;
            }).toList();
      }

      _filteredBookings.sort(
            (a, b) => (b['bookingId'] ?? '').compareTo(a['bookingId'] ?? ''),
      );

      if (_dateParsingError &&
          _selectedDate != null &&
          _filteredBookings.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBar(
            'Some bookings have invalid date formats. Please check the data or clear the date filter.',
            Colors.red[400]!,
          );
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3661E2),
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3661E2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterBookings();
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14.sp)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _downloadReport(dynamic booking) async {
    try {
      final dio = Dio();
      final bookingId = booking['bookingId'] ?? '';
      final testName = booking['testName']?.replaceAll(' ', '_') ?? 'report';
      final reportUrl = booking['reportUrl'];

      if (reportUrl == null || reportUrl.isEmpty) {
        _showSnackBar(
          'No report available for this booking',
          Colors.orange[600]!,
        );
        return;
      }

      // Use downloads directory for better accessibility
      final directory =
          await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$testName-$bookingId.pdf';

      _showSnackBar('Downloading report...', Colors.blue[600]!);

      await dio.download(
        reportUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      final file = File(filePath);
      if (await file.exists()) {
        _showSnackBar(
          'Report downloaded to Downloads folder!',
          Colors.green[600]!,
        );

        // Show a dialog with the file path and option to open
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
              title: Text(
                'Download Successful',
                style: GoogleFonts.poppins(),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report saved to:', style: GoogleFonts.poppins()),
                  SizedBox(height: 8),
                  Text(filePath, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK', style: GoogleFonts.poppins()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    OpenFile.open(filePath);
                  },
                  child: Text(
                    'OPEN FILE',
                    style: GoogleFonts.poppins(color: Colors.blue),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        _showSnackBar('Download failed - file not saved', Colors.red[600]!);
      }
    } on DioException catch (e) {
      print('Dio error downloading report: ${e.message}');
      _showSnackBar(
        'Download failed: ${e.message ?? 'Network error'}',
        Colors.red[600]!,
      );
    } catch (e) {
      print('Error downloading report: $e');
      _showSnackBar(
        'Error downloading report: ${e.toString()}',
        Colors.red[600]!,
      );
    }
  }

  Future<void> _viewReport(dynamic booking) async {
    try {
      final dio = Dio();
      final bookingId = booking['bookingId'] ?? '';
      final testName = booking['testName']?.replaceAll(' ', '_') ?? 'report';
      final reportUrl = booking['reportUrl'];

      if (reportUrl == null || reportUrl.isEmpty) {
        _showSnackBar(
          'No report available for this booking',
          Colors.orange[600]!,
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$testName-$bookingId.pdf';

      await dio.download(reportUrl, filePath);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showSnackBar(
          'Unable to open report: ${result.message}',
          Colors.red[600]!,
        );
      } else {
        _showSnackBar(
          'Opening report for ${booking['testName']}',
          Colors.blue[600]!,
        );
      }
    } catch (e) {
      print('Error viewing report: $e');
      _showSnackBar('Error viewing report: $e', Colors.red[600]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3661E2),
        elevation: 0,
        title: Text(
          "My Bookings",
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _filterBookings();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by $_searchType...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey[500],
                              size: 22.w,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            isDense: true,
                            alignLabelWithHint: true,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Container(
                        height: 48.h,
                        padding: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _searchType,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22.w,
                              color: Colors.grey[600],
                            ),
                            elevation: 2,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF3661E2),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            onChanged: (String? newValue) {
                              setState(() {
                                _searchType = newValue!;
                                _searchQuery = '';
                                _searchController.clear();
                                _filterBookings();
                              });
                            },
                            items:
                            <String>[
                              'Test Name',
                              'Status',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Text(value),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        icon: Icons.calendar_today,
                        label:
                        _selectedDate == null
                            ? 'Any Date'
                            : DateFormat(
                          'MMM d, yyyy',
                        ).format(_selectedDate!),
                        isSelected: _selectedDate != null,
                        onTap: () => _selectDate(context),
                        onClear:
                        _selectedDate != null
                            ? () {
                          setState(() {
                            _selectedDate = null;
                            _filterBookings();
                          });
                        }
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        icon: Icons.filter_alt_outlined,
                        label: _selectedStatus ?? 'All Statuses',
                        isSelected: _selectedStatus != null,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                            ),
                            builder: (context) {
                              return StatusFilterBottomSheet(
                                currentStatus: _selectedStatus,
                                onStatusSelected: (status) {
                                  setState(() {
                                    _selectedStatus = status;
                                    _filterBookings();
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        onClear:
                        _selectedStatus != null
                            ? () {
                          setState(() {
                            _selectedStatus = null;
                            _filterBookings();
                          });
                        }
                            : null,
                        color:
                        _selectedStatus != null
                            ? _getStatusColor(_selectedStatus!)
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      if (_searchQuery.isNotEmpty ||
                          _selectedDate != null ||
                          _selectedStatus != null)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedDate = null;
                              _selectedStatus = null;
                              _filterBookings();
                            });
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.clear_all,
                                  size: 18.w,
                                  color: const Color(0xFF3661E2),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Clear All',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3661E2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
            _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF3661E2),
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading your bookings...',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : _filteredBookings.isEmpty
                ? Center(
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty ||
                          _selectedDate != null ||
                          _selectedStatus != null
                          ? "No Matching Bookings Found"
                          : "No Bookings Yet",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        _searchQuery.isNotEmpty ||
                            _selectedDate != null ||
                            _selectedStatus != null
                            ? "Try adjusting your search or filters"
                            : "You haven't made any bookings yet. Book your first test now!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_searchQuery.isNotEmpty ||
                            _selectedDate != null ||
                            _selectedStatus != null) {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _selectedDate = null;
                            _selectedStatus = null;
                            _filterBookings();
                          });
                        } else {
                          _loadOrders();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3661E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 14.h,
                        ),
                        elevation: 2,
                        shadowColor: const Color(
                          0xFF3661E2,
                        ).withOpacity(0.3),
                      ),
                      child: Text(
                        _searchQuery.isNotEmpty ||
                            _selectedDate != null ||
                            _selectedStatus != null
                            ? "Reset Filters"
                            : "Refresh",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color(0xFF3661E2),
              backgroundColor: Colors.white,
              strokeWidth: 3,
              displacement: 40,
              edgeOffset: 20,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 20.h,
                ),
                itemCount: _filteredBookings.length,
                separatorBuilder:
                    (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final booking = _filteredBookings[index];
                  final testName =
                      booking['testName'] ?? 'Unknown Test';
                  final bookingStatus = _formatBookingStatus(booking);
                  final bookingDate =
                      booking['bookingDate'] ?? 'Date not available';
                  final orgName =
                      booking['orgName'] ??
                          'Organization not specified';
                  final isChildBooking =
                      booking['isChildBooking'] == true;
                  final userName =
                  isChildBooking
                      ? '${booking['childFirstName'] ?? ''} ${booking['childLastName'] ?? ''}'
                      .trim()
                      : '${widget.userModel.currentUser?['firstName'] ?? ''} ${widget.userModel.currentUser?['lastName'] ?? ''}'
                      .trim();
                  final parsedDate = _parseBookingDate(bookingDate);
                  final formattedDate =
                  parsedDate != null
                      ? DateFormat(
                    'MMM dd, yyyy',
                  ).format(parsedDate)
                      : bookingDate;

                  return FadeInUp(
                    duration: Duration(
                      milliseconds: 300 + (index * 100),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            // Add navigation to details screen
                          },
                          highlightColor: const Color(0xFF3661E2).withOpacity(0.05),
                          splashColor: const Color(0xFF3661E2).withOpacity(0.1),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        orgName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (bookingStatus.isNotEmpty) SizedBox(width: 8.w),
                                    if (bookingStatus.isNotEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(bookingStatus),
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(bookingStatus),
                                              size: 16.w,
                                              color: _getStatusColor(bookingStatus),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              bookingStatus,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(bookingStatus),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  testName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[900],
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 25.w,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 10.w),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isChildBooking ? 'Patient' : 'Patient',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              userName.isNotEmpty ? userName : 'Unknown',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20.w,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 10.w),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Add address field if available
                                SizedBox(height: 12.h),
                                if (booking['address'] != null && booking['address'].isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 25.w,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Address',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              booking['address'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                // Add booking slot if available
                                if (booking['bookingSlot'] != null && booking['bookingSlot'].isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 25.w,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time Slot',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            booking['bookingSlot'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                if (bookingStatus == 'Initiated') ...[
                                  SizedBox(height: 16.h),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () => _cancelBooking(booking),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cancel,
                                            size: 18.w,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Cancel Booking',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                if (bookingStatus == 'Completed' && booking['isReportSent'] == true) ...[
                                  SizedBox(height: 16.h),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16.h),
                                  if (booking['reportUrl'] != null && booking['reportUrl'].isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _viewReport(booking),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF3661E2),
                                              side: BorderSide(
                                                color: const Color(0xFF3661E2),
                                                width: 1.5,
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 12.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.remove_red_eye,
                                              size: 18.w,
                                            ),
                                            label: Text(
                                              'View Report',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _downloadReport(booking),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF3661E2),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(vertical: 12.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              elevation: 2,
                                              shadowColor: const Color(0xFF3661E2).withOpacity(0.3),
                                            ),
                                            icon: Icon(
                                              Icons.download,
                                              size: 18.w,
                                            ),
                                            label: Text(
                                              'Download',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (booking['reportUrl'] == null || booking['reportUrl'].isEmpty)
                                    Text(
                                      'Report not yet available',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
          isSelected
              ? color?.withOpacity(0.15) ??
              const Color(0xFF3661E2).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
            isSelected
                ? color?.withOpacity(0.3) ??
                const Color(0xFF3661E2).withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.w,
              color:
              isSelected
                  ? color ?? const Color(0xFF3661E2)
                  : Colors.grey[600],
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color:
                isSelected
                    ? color ?? const Color(0xFF3661E2)
                    : Colors.grey[700],
              ),
            ),
            if (onClear != null) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16.w,
                  color:
                  isSelected
                      ? color ?? const Color(0xFF3661E2)
                      : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

class StatusFilterBottomSheet extends StatelessWidget {
  final String? currentStatus;
  final Function(String?) onStatusSelected;

  const StatusFilterBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Text(
            'Filter by Status',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20.h),
          ...[
            'All Statuses',
            'Initiated',
            'In Collection',
            'In Processing',
            'Completed',
            'Cancelled',
          ].map((status) {
            final isSelected =
                (status == 'All Statuses' && currentStatus == null) ||
                    (status == currentStatus);
            return InkWell(
              onTap: () {
                onStatusSelected(status == 'All Statuses' ? null : status);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          isSelected
                              ? const Color(0xFF3661E2)
                              : Colors.grey[400]!,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}