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

  // ✅ Add this
  Future<void> updateUserSettings(String accessToken, bool notificationsEnabled) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/settings'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'notifications_enabled': notificationsEnabled}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user settings');
      }
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // ✅ Add this
  Future<void> logout(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) {
        throw Exception('Logout failed');
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

}
