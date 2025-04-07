import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SpotifyService {
  final String baseUrl = 'https://api.spotify.com/v1';

  Future<List<Song>> searchSongs(String query, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query&type=track'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> tracks = data['tracks']['items'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      } else {
        throw Exception('Failed to search songs');
      }
    } catch (e) {
      throw Exception('Failed to search songs: $e');
    }
  }
}
