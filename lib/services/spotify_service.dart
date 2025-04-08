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
  Future<void> addSongToQueue(String partyId, Song song, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-api.com/parties/$partyId/queue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'id': song.id,
          'title': song.title,
          'artist': song.artist,
          'albumArt': song.albumArtUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Song added to queue');
      } else {
        throw Exception('Failed to add song to queue');
      }
    } catch (e) {
      print('Error adding song to queue: $e');
      throw Exception('Error adding song to queue');
    }
  }

}
