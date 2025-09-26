// import 'package:dio/dio.dart';
//
// class MemberService {
//   final Dio _dio;
//
//   MemberService(this._dio);
//
//   Future<List<Map<String, dynamic>>> getRelations() async {
//     try {
//       final response = await _dio.get(
//         'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/relation/list-relations',
//       );
//
//       if (response.data != null &&
//           response.data['body'] != null &&
//           response.data['body']['data'] != null) {
//         return List<Map<String, dynamic>>.from(
//           response.data['body']['data'].map(
//                 (item) => {
//               'id': item['id'].toString(),
//               'relationName': item['relationName'],
//             },
//           ),
//         );
//       }
//       return [];
//     } catch (e) {
//       print('Error fetching relations: $e');
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> addMember({
//     required String firstName,
//     required String lastName,
//     required int? age,
//     required String gender,
//     required String relationId,
//     required String contactNumber,
//     required String email,
//     required String address,
//     required String linkingId,
//   }) async {
//     try {
//       final memberData = {
//         "firstName": firstName,
//         "lastName": lastName,
//         "contactNumber": contactNumber,
//         "emailId": email,
//         "address": address,
//         "gender": gender,
//         "age": age?.toString(),
//         "parent_child_relation": relationId,
//         "is_parent": 0,
//         "linking_id": linkingId,
//       };
//
//       final response = await _dio.post(
//         'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user',
//         data: memberData,
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return response.data;
//       } else {
//         throw Exception('Failed to add member: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error adding member: $e');
//       rethrow;
//     }
//   }
// }
import 'package:dio/dio.dart';

class MemberService {
  final Dio _dio;

  MemberService(this._dio);

  Future<List<Map<String, dynamic>>> getRelations() async {
    try {
      final response = await _dio.get(
        'https://77kxt00j0l.execute-api.us-east-1.amazonaws.com/dev/relation/list-relations',
      );

      if (response.data != null &&
          response.data['body'] != null &&
          response.data['body']['data'] != null) {
        return List<Map<String, dynamic>>.from(
          response.data['body']['data'].map(
                (item) => {
              'id': item['id'].toString(),
              'relationName': item['relationName'],
            },
          ),
        );
      }
      return [];
    } catch (e) {
      print('Error fetching relations: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addMember({
    required String firstName,
    required String lastName,
    required int? age,
    required String gender,
    required String relationId,
    required String contactNumber,
    required String email,
    required String address,
    required String linkingId,
  }) async {
    try {
      final memberData = {
        "firstName": firstName,
        "lastName": lastName,
        "contactNumber": contactNumber,
        "emailId": email,
        "address": address,
        "gender": gender,
        "age": age?.toString(),
        "parent_child_relation": relationId,
        "is_parent": 0,
        "linking_id": linkingId,
      };

      final response = await _dio.post(
        'https://2sflw15kpf.execute-api.us-east-1.amazonaws.com/dev/app-user/register-app-user',
        data: memberData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Check the response body statusCode instead of HTTP status code
      final responseData = response.data;
      final bodyStatusCode = responseData['statusCode'];

      if (bodyStatusCode == 200) {
        // Success case
        return responseData;
      } else if (bodyStatusCode == 400) {
        // Error case - check for duplicate phone number
        final bodyMessage = responseData['body']?['message']?.toString().toLowerCase() ?? '';
        final bodyStatus = responseData['body']?['status']?.toString().toLowerCase() ?? '';

        if (bodyMessage.contains('contact number already exists') ||
            bodyMessage.contains('already exists') ||
            bodyStatus.contains('failed')) {

          // Extract the exact message from the API for user-friendly display
          final exactMessage = responseData['body']?['message'] ?? 'This phone number is already registered.';
          throw DuplicatePhoneNumberException(exactMessage);
        }

        // Other 400 errors
        throw Exception(responseData['body']?['message'] ?? 'Failed to add member');
      } else {
        // Other status codes
        throw Exception('Failed to add member: ${responseData['body']?['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      // Handle network/Dio errors
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error adding member: $e');
      rethrow;
    }
  }
}

// Custom exception for duplicate phone numbers
class DuplicatePhoneNumberException implements Exception {
  final String message;
  DuplicatePhoneNumberException(this.message);

  @override
  String toString() => message;
}