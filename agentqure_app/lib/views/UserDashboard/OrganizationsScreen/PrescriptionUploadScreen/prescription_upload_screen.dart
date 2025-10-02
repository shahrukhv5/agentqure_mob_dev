// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../../../models/UserModel/user_model.dart';
//
// class PrescriptionUploadScreen extends StatefulWidget {
//   final UserModel userModel;
//
//   const PrescriptionUploadScreen({super.key, required this.userModel});
//
//   @override
//   _PrescriptionUploadScreenState createState() =>
//       _PrescriptionUploadScreenState();
// }
//
// class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
//   final Dio _dio = Dio();
//   final ImagePicker _picker = ImagePicker();
//
//   File? _prescriptionFile;
//   bool _isUploading = false;
//   String? _errorMessage;
//   final int _hardcodedOrganizationId = 37;
//
//   @override
//   void initState() {
//     super.initState();
//     print('PrescriptionUploadScreen initialized');
//     print('Using hardcoded organization ID: $_hardcodedOrganizationId');
//   }
//
//   Future<void> _selectFile() async {
//     print('Opening file picker...');
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         allowMultiple: false,
//         type: FileType.custom,
//         allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
//       );
//
//       if (result != null && result.files.isNotEmpty) {
//         print('Selected file: ${result.files.first.name}');
//         setState(() {
//           _prescriptionFile = File(result.files.first.path!);
//         });
//         print('File selected: ${_prescriptionFile?.path}');
//       } else {
//         print('User cancelled file selection');
//       }
//     } catch (e) {
//       print('Failed to select file: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to select file: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _captureImage() async {
//     print('Opening camera...');
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 2000,
//         maxHeight: 2000,
//         imageQuality: 90,
//       );
//
//       if (image != null) {
//         print('Captured image: ${image.path}');
//         setState(() {
//           _prescriptionFile = File(image.path);
//         });
//         print('File selected: ${_prescriptionFile?.path}');
//       } else {
//         print('User cancelled camera');
//       }
//     } catch (e) {
//       print('Failed to capture image: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to capture image: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _uploadPrescription() async {
//     print('Starting prescription upload process...');
//     print('Using organization ID: $_hardcodedOrganizationId');
//
//     if (_prescriptionFile == null) {
//       print('No prescription file selected');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please add a prescription file'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     print(
//       'Uploading file to organization ID: $_hardcodedOrganizationId',
//     );
//
//     setState(() {
//       _isUploading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       // Convert file to base64 with proper data URI for images only
//       final file = _prescriptionFile!;
//       print('Processing file: ${file.path}');
//       final bytes = await file.readAsBytes();
//       final String base64String = base64Encode(bytes);
//
//       // Check if file is an image (jpg, jpeg, png)
//       final isImage =
//           file.path.toLowerCase().endsWith('.jpg') ||
//               file.path.toLowerCase().endsWith('.jpeg') ||
//               file.path.toLowerCase().endsWith('.png');
//
//       // Add data URI prefix only for images, not for PDFs or other documents
//       final String formattedBase64 =
//       isImage ? 'data:image/jpg;base64,$base64String' : base64String;
//
//       print(
//         'File converted to base64, type: ${isImage ? 'image' : 'document'}, size: ${bytes.length} bytes',
//       );
//
//       // Prepare request body
//       final requestBody = {
//         "username":
//         "${widget.userModel.currentUser?['firstName']} ${widget.userModel.currentUser?['lastName'] ?? ''}",
//         "contact": widget.userModel.currentUser?['contactNumber'] ?? '',
//         "request_status": "Pending",
//         "org_id": _hardcodedOrganizationId,
//         "user_id": int.parse(
//           widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
//         ),
//         "raw_booking": {
//           "bookingDate": _formatDate(DateTime.now()),
//           "doctorReference": "Prescription",
//           "amount": 0,
//           "paymentDate": _formatDate(DateTime.now()),
//           "paymentStatus": "Pay Later",
//           "notes": "Prescription upload",
//           "collectionWay": "In-Center",
//           "paymentMode": "Pay Later",
//           "organizationId": _hardcodedOrganizationId,
//           "createdBy": int.parse(
//             widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
//           ),
//           "updatedBy": int.parse(
//             widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
//           ),
//           "services": [],
//           "remainingAmount": 0,
//           "advancePayment": "0",
//           "labPartner": null,
//           "discountBy": "Lab",
//           "discountGiven": 0,
//           "discountReason": "",
//           "paymentInformation": {
//             "invoiceDate":
//             "${_formatDate(DateTime.now())} ${_formatTime(DateTime.now())}",
//             "totalPrice": 0,
//             "totalDiscount": 0,
//             "createdBy": int.parse(
//               widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
//             ),
//             "updatedBy": int.parse(
//               widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
//             ),
//             "organizationId": _hardcodedOrganizationId,
//             "remainingAmount": 0,
//             "advancePayment": 0,
//             "invoicepayments": [],
//           },
//         },
//         "fileName": "prescription_${DateTime.now().millisecondsSinceEpoch}",
//         "prescriptionBase64": formattedBase64,
//       };
//
//       print('Sending upload request to API...');
//       print('File type being uploaded:');
//       final fileType = file.path.toLowerCase().endsWith('.jpg') ||
//           file.path.toLowerCase().endsWith('.jpeg') ||
//           file.path.toLowerCase().endsWith('.png')
//           ? 'image'
//           : 'document';
//       print('- ${file.path.split('/').last}: $fileType');
//
//       final response = await _dio.post(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/bookings/booking-requests/register-booking-requests',
//         data: requestBody,
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );
//
//       print('Upload API response status: ${response.statusCode}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print('Prescription uploaded successfully!');
//         print('Server response: ${response.data}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Prescription uploaded successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       } else {
//         throw Exception('Server returned status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to upload prescription: ${e.toString()}');
//       setState(() {
//         _errorMessage = "Failed to upload prescription: ${e.toString()}";
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to upload prescription: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       print('Upload process completed');
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
//
//   String _formatTime(DateTime date) {
//     return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
//   }
//
//   void _removeFile() {
//     print('Removing selected file');
//     setState(() {
//       _prescriptionFile = null;
//     });
//     print('File removed');
//   }
//
//   String _getFileTypeIcon(String path) {
//     if (path.toLowerCase().endsWith('.pdf')) return 'PDF';
//     if (path.toLowerCase().endsWith('.doc') ||
//         path.toLowerCase().endsWith('.docx'))
//       return 'DOC';
//     return 'IMG';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('Building PrescriptionUploadScreen');
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: Text(
//           "Upload Prescription",
//           style: GoogleFonts.poppins(
//             fontSize: 22.sp,
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF3661E2),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Directly show the "Add Prescription" section
//             Text(
//               'Add Prescription',
//               style: GoogleFonts.poppins(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _selectFile,
//                     icon: const Icon(Icons.folder_open, color: Color(0xFF3661E2)),
//                     label: Text(
//                       'Select File',
//                       style: GoogleFonts.poppins(fontSize: 14.sp, color: Color(0xFF3661E2)),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 12.h),
//                         backgroundColor: Colors.white
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _captureImage,
//                     icon: const Icon(Icons.camera_alt, color: Color(0xFF3661E2)),
//                     label: Text(
//                       'Camera',
//                       style: GoogleFonts.poppins(fontSize: 14.sp, color: Color(0xFF3661E2)),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 12.h),
//                         backgroundColor: Colors.white
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.h),
//             if (_prescriptionFile != null) ...[
//               Text(
//                 'Selected File',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               Expanded(
//                 child: Center(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 300.h,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8.r),
//                         ),
//                         child: _prescriptionFile!.path.toLowerCase().endsWith('.jpg') ||
//                             _prescriptionFile!.path.toLowerCase().endsWith('.jpeg') ||
//                             _prescriptionFile!.path.toLowerCase().endsWith('.png')
//                             ? Image.file(
//                           _prescriptionFile!,
//                           fit: BoxFit.contain,
//                           width: double.infinity,
//                           height: double.infinity,
//                         )
//                             : Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.insert_drive_file,
//                                 size: 60.w,
//                                 color: Colors.grey,
//                               ),
//                               SizedBox(height: 16.h),
//                               Text(
//                                 _getFileTypeIcon(_prescriptionFile!.path),
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18.sp,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               Text(
//                                 _prescriptionFile!.path.split('/').last,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14.sp,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 8.w,
//                         right: 8.w,
//                         child: CircleAvatar(
//                           radius: 18.r,
//                           backgroundColor: Colors.red,
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             icon: Icon(Icons.close, size: 18.w),
//                             color: Colors.white,
//                             onPressed: _removeFile,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ] else ...[
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.upload_file,
//                         size: 60.w,
//                         color: Colors.grey,
//                       ),
//                       SizedBox(height: 16.h),
//                       Text(
//                         'No file selected',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         'Select a file or capture using camera',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14.sp,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//             SizedBox(height: 16.h),
//             if (_errorMessage != null)
//               Padding(
//                 padding: EdgeInsets.only(bottom: 8.h),
//                 child: Text(
//                   _errorMessage!,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14.sp,
//                     color: Colors.red,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             if (_isUploading)
//               const Center(child: CircularProgressIndicator(color: Color(0xFF3661E2),))
//             else
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _uploadPrescription,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3661E2),
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                   ),
//                   child: Text(
//                     'Upload Prescription',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/UserModel/user_model.dart';
import '../../../../services/ApiService/api_service.dart';
class PrescriptionUploadScreen extends StatefulWidget {
  final UserModel userModel;

  const PrescriptionUploadScreen({super.key, required this.userModel});

  @override
  _PrescriptionUploadScreenState createState() =>
      _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService().configureDio();

  File? _prescriptionFile;
  bool _isUploading = false;
  String? _errorMessage;
  final int _hardcodedOrganizationId = 37;

  @override
  void initState() {
    super.initState();
    print('PrescriptionUploadScreen initialized');
    print('Using hardcoded organization ID: $_hardcodedOrganizationId');
  }

  Future<void> _selectFile() async {
    print('Opening file picker...');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        print('Selected file: ${result.files.first.name}');
        setState(() {
          _prescriptionFile = File(result.files.first.path!);
          _errorMessage = null;
        });
      } else {
        print('User cancelled file selection');
      }
    } catch (e) {
      print('Failed to select file: $e');
      _showErrorSnackBar('Failed to select file: ${e.toString()}');
    }
  }

  Future<void> _captureImage() async {
    print('Opening camera...');
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        print('Captured image: ${image.path}');
        setState(() {
          _prescriptionFile = File(image.path);
          _errorMessage = null;
        });
      } else {
        print('User cancelled camera');
      }
    } catch (e) {
      print('Failed to capture image: $e');
      _showErrorSnackBar('Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> _uploadPrescription() async {
    if (_prescriptionFile == null) {
      _showErrorSnackBar('Please add a prescription file');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final requestBody = await _buildRequestBody();

      print('Sending upload request to API...');
      final response = await _apiService.uploadPrescription(data: requestBody);

      print('Upload API response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Prescription uploaded successfully!');
        _showSuccessSnackBar('Prescription uploaded successfully!');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to upload prescription: $e');
      setState(() {
        _errorMessage = "Failed to upload prescription: ${e.toString()}";
      });
      _showErrorSnackBar('Failed to upload prescription: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _buildRequestBody() async {
    final file = _prescriptionFile!;
    final bytes = await file.readAsBytes();
    final String base64String = base64Encode(bytes);

    final isImage = file.path.toLowerCase().endsWith('.jpg') ||
        file.path.toLowerCase().endsWith('.jpeg') ||
        file.path.toLowerCase().endsWith('.png');

    final String formattedBase64 =
    isImage ? 'data:image/jpg;base64,$base64String' : base64String;

    final userId = int.parse(
      widget.userModel.currentUser?['appUserId']?.toString() ?? '0',
    );

    return {
      "username":
      "${widget.userModel.currentUser?['firstName']} ${widget.userModel.currentUser?['lastName'] ?? ''}",
      "contact": widget.userModel.currentUser?['contactNumber'] ?? '',
      "request_status": "Pending",
      "org_id": _hardcodedOrganizationId,
      "user_id": userId,
      "raw_booking": {
        "bookingDate": _formatDate(DateTime.now()),
        "doctorReference": "Prescription",
        "amount": 0,
        "paymentDate": _formatDate(DateTime.now()),
        "paymentStatus": "Pay Later",
        "notes": "Prescription upload",
        "collectionWay": "In-Center",
        "paymentMode": "Pay Later",
        "organizationId": _hardcodedOrganizationId,
        "createdBy": userId,
        "updatedBy": userId,
        "services": [],
        "remainingAmount": 0,
        "advancePayment": "0",
        "labPartner": null,
        "discountBy": "Lab",
        "discountGiven": 0,
        "discountReason": "",
        "paymentInformation": {
          "invoiceDate":
          "${_formatDate(DateTime.now())} ${_formatTime(DateTime.now())}",
          "totalPrice": 0,
          "totalDiscount": 0,
          "createdBy": userId,
          "updatedBy": userId,
          "organizationId": _hardcodedOrganizationId,
          "remainingAmount": 0,
          "advancePayment": 0,
          "invoicepayments": [],
        },
      },
      "fileName": "prescription_${DateTime.now().millisecondsSinceEpoch}",
      "prescriptionBase64": formattedBase64,
    };
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  void _removeFile() {
    print('Removing selected file');
    setState(() {
      _prescriptionFile = null;
    });
  }

  String _getFileTypeIcon(String path) {
    if (path.toLowerCase().endsWith('.pdf')) return 'PDF';
    if (path.toLowerCase().endsWith('.doc') ||
        path.toLowerCase().endsWith('.docx')) return 'DOC';
    return 'IMG';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFilePreview() {
    if (_prescriptionFile == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: 60.w,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'No file selected',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Select a file or capture using camera',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isImage = _prescriptionFile!.path.toLowerCase().endsWith('.jpg') ||
        _prescriptionFile!.path.toLowerCase().endsWith('.jpeg') ||
        _prescriptionFile!.path.toLowerCase().endsWith('.png');

    return Expanded(
      child: Center(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isImage
                  ? Image.file(
                _prescriptionFile!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 60.w,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _getFileTypeIcon(_prescriptionFile!.path),
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _prescriptionFile!.path.split('/').last,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8.w,
              right: 8.w,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.red,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, size: 18.w),
                  color: Colors.white,
                  onPressed: _removeFile,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Upload Prescription",
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3661E2),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Prescription',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectFile,
                    icon: const Icon(Icons.folder_open, color: Color(0xFF3661E2)),
                    label: Text(
                      'Select File',
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Color(0xFF3661E2)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF3661E2)),
                    label: Text(
                      'Camera',
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Color(0xFF3661E2)),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Selected File',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            _buildFilePreview(),
            SizedBox(height: 16.h),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isUploading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF3661E2)))
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _uploadPrescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3661E2),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Upload Prescription',
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
    );
  }
}