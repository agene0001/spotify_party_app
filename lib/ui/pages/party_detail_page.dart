import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/party_service.dart';
import 'package:spotify_party_app/ui/widgets/song_queue_item.dart';

class PartyDetailPage extends StatelessWidget {
  final String partyId;
  final PartyService partyService = PartyService();

  PartyDetailPage({required this.partyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Party Details')),
      body: FutureBuilder(
        future: partyService.fetchPartyDetails(partyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading party details'));
          }
          var party = snapshot.data;
          return Column(
            children: [
              // Current song playing
              ListTile(
                title: Text('Now Playing: ${party.currentSong.title}'),
                subtitle: Text('${party.currentSong.artist}'),
                leading: Image.network(party.currentSong.albumArt),
              ),
              // Song queue
              Expanded(
                child: ListView.builder(
                  itemCount: party.songQueue.length,
                  itemBuilder: (context, index) {
                    return SongQueueItem(song: party.songQueue[index]);
                  },
                ),
              ),
              // Play/pause and control buttons
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
