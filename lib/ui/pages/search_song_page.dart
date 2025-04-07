import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/spotify_service.dart';

class SearchSongPage extends StatelessWidget {
  final String partyId;
  final SpotifyService spotifyService = SpotifyService();

  SearchSongPage({required this.partyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search and Add Song')),
      body: Column(
        children: [
          TextField(
            onChanged: (query) {
              // Implement search functionality here
            },
            decoration: InputDecoration(hintText: 'Search for songs...'),
          ),
          Expanded(
            child: FutureBuilder(
              future: spotifyService.searchSongs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error searching for songs'));
                }
                var songs = snapshot.data;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(songs[index].title),
                      subtitle: Text(songs[index].artist),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => spotifyService.addSongToQueue(partyId, songs[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
