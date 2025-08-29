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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding member: $e');
      rethrow;
    }
  }
}