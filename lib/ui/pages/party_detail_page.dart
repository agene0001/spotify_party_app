import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/party_service.dart';
import 'package:spotify_party_app/ui/widgets/song_queue_item.dart';
import 'package:spotify_party_app/models/party.dart'; // Assuming you have a Party model
import 'package:spotify_party_app/models/song.dart'; // Assuming you have a Party model

class PartyDetailPage extends StatelessWidget {
  final String partyId;
  final PartyService partyService = PartyService();

  PartyDetailPage({required this.partyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Party Details')),
      body: FutureBuilder<Party>(
        future: partyService.fetchPartyDetails(partyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading party details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No party details available'));
          }

          var party = snapshot.data!;  // Safely access the party data after it's loaded

          return Column(
            children: [
              // Current song playing
              ListTile(
                title: Text('Now Playing: ${party.currentSong.title}'),
                subtitle: Text(party.currentSong.artist),
                leading: Image.network(party.currentSong.albumArtUrl),
              ),
              // Song queue
              Expanded(
                child: ListView.builder(
                  itemCount: party.queue.length,
                  itemBuilder: (context, index) {
                    // Assuming the queue contains song titles or IDs
                    // You need to map this string into a Song object
                    String songTitle = party.queue[index];

                    // Creating a dummy song object (replace with actual data if needed)
                    Song song = Song(
                      id:"1",
                      title: songTitle,
                      artist: 'Unknown',  // Replace with actual artist if you have data
                      albumArtUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/66/The_Beatles_-_Abbey_Road.jpg'
                    );

                    return SongQueueItem(song: song);  // Pass the Song object to the SongQueueItem
                  },
                ),
              ),
              // Play/pause and control buttons (only if the user is the host)
              if (party.isHost)
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.skip_next), onPressed: () => partyService.skipSong(partyId)),
                    IconButton(icon: Icon(Icons.play_arrow), onPressed: () => partyService.playPause(partyId)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
