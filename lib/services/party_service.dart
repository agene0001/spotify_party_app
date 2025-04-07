import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/party.dart';

class PartyService {
  final String baseUrl = 'https://your-api.com/parties';

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
}
