import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../ApiService/api_service.dart';

class MemberService {
  Future<List<Map<String, dynamic>>> getRelations() async {
    try {
      final apiService = ApiService();
      return await apiService.getRelations();
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

      final apiService = ApiService();
      final response = await apiService.post(
        baseUrl: ApiConstants.appUserBaseUrl,
        endpoint: ApiConstants.registerAppUser,
        data: memberData,
      );

      final responseData = response.data;
      final bodyStatusCode = responseData['statusCode'];

      if (bodyStatusCode == 200) {
        return responseData;
      } else if (bodyStatusCode == 400) {
        final bodyMessage = responseData['body']?['message']?.toString().toLowerCase() ?? '';
        final bodyStatus = responseData['body']?['status']?.toString().toLowerCase() ?? '';

        if (bodyMessage.contains('contact number already exists') ||
            bodyMessage.contains('already exists') ||
            bodyStatus.contains('failed')) {
          final exactMessage = responseData['body']?['message'] ?? 'This phone number is already registered.';
          throw DuplicatePhoneNumberException(exactMessage);
        }

        throw Exception(responseData['body']?['message'] ?? 'Failed to add member');
      } else {
        throw Exception('Failed to add member: ${responseData['body']?['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
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