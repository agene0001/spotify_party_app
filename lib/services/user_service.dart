import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  final String baseUrl = 'https://your-api.com/user';

  Future<User> getUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }
}
