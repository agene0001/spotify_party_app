import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/party.dart';
import 'package:spotify_party_app/services/auth_service.dart';  // Assuming AuthService is already defined

class PartyService {
  final String baseUrl = 'https://your-api.com/parties';
  final AuthService authService = AuthService(); // Create an instance of AuthService

  Future<List<Party>> getActiveParties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/active'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Party.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load parties');
      }
    } catch (e) {
      throw Exception('Failed to load parties: $e');
    }
  }

  Future<void> createParty(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create party');
      }
    } catch (e) {
      throw Exception('Failed to create party: $e');
    }
  }
  // Fetch active parties from the backend
  Future<List<Party>> fetchActiveParties() async {
    try {
      final token = await authService.getAccessToken();  // Get the access token from AuthService
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Make a GET request to fetch active parties
      final response = await http.get(
        Uri.parse('$baseUrl/parties'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // If the server returns a successful response, parse the response body
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((partyJson) => Party.fromJson(partyJson)).toList();
      } else {
        // Handle error from server (non-200 status code)
        throw Exception('Failed to load active parties');
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print('Error fetching active parties: $e');
      throw Exception('Error fetching active parties');
    }
  }
  // Skip the current song of the party
  Future<void> skipSong(String partyId) async {
    try {
      final token = await authService.getAccessToken(); // Get the access token from AuthService
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$partyId/skip'), // API endpoint to skip the song (modify if needed)
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Successfully skipped the song
        print('Song skipped successfully!');
      } else {
        throw Exception('Failed to skip the song');
      }
    } catch (e) {
      print('Error skipping song: $e');
      throw Exception('Error skipping song');
    }
  }
  Future<void> playPause(String partyId) async {
    try {
      final token = await authService.getAccessToken(); // Get the access token
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$partyId/play-pause'), // Adjust if your backend uses a different path
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Playback toggled successfully.');
      } else {
        throw Exception('Failed to toggle playback');
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
      throw Exception('Error toggling play/pause');
    }
  }
  // Fetch details of a specific party by its ID
  Future<Party> fetchPartyDetails(String partyId) async {
    try {
      final token = await authService.getAccessToken(); // Get the access token from AuthService
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Make a GET request to fetch the party details
      final response = await http.get(
        Uri.parse('$baseUrl/$partyId'), // URL including the partyId
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Parse the response body and convert it into a Party object
        var data = json.decode(response.body);
        return Party.fromJson(data);  // Assuming Party has a fromJson method
      } else {
        // Handle server errors
        throw Exception('Failed to load party details');
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Error fetching party details: $e');
      throw Exception('Error fetching party details');
    }
  }
}
