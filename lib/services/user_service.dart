import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> _getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user; // FirebaseAuth already gives the user data
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }
  Future<String?> getUserId() async {

 User? profile = await _getUserProfile();
 if(profile != null) {
   return profile.uid;
 }
 else {
   return null;
 }

  }

  // ✅ Add this
  // Future<void> updateUserSettings(String accessToken, bool notificationsEnabled) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$baseUrl/settings'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({'notifications_enabled': notificationsEnabled}),
  //     );
  //
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to update user settings');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to update user settings: $e');
  //   }
  // }
  //
  // // ✅ Add this
  // Future<void> logout(String accessToken) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/logout'),
  //       headers: {'Authorization': 'Bearer $accessToken'},
  //     );
  //
  //     if (response.statusCode != 200) {
  //       throw Exception('Logout failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Logout failed: $e');
  //   }
  // }

}
