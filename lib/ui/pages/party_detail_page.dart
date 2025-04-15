import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/party_service.dart';
import 'package:spotify_party_app/services/user_service.dart';
import 'package:spotify_party_app/ui/widgets/song_queue_item.dart';
import 'package:spotify_party_app/models/party.dart';
import 'package:spotify_party_app/models/song.dart';
import 'package:spotify_party_app/services/auth_service.dart';

class PartyDetailPage extends StatefulWidget {
  final String partyId;

  const PartyDetailPage({super.key, required this.partyId});

  @override
  State<PartyDetailPage> createState() => _PartyDetailPageState();
}

class _PartyDetailPageState extends State<PartyDetailPage> {

  late final UserService userService;
  late final PartyService _partyService;
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    userService = UserService();  // Initialize userService
    _partyService = PartyService(userService: userService);  // Now you can initialize _partyService
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Details')),
      body: StreamBuilder<Party>(
        // Use the stream method instead of future for real-time updates
        stream: _partyService.listenToParty(widget.partyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Party not found'));
          }

          Party party = snapshot.data!;

          String? currentUserId = (userService.getUserId() ?? '') as String?;
          bool isHost = party.createdBy == currentUserId;

          // Extract current song from party data if available
          Map<String, dynamic>? currentTrackData = party.currentTrack;
          Song currentSong = Song(
            id: currentTrackData?['id'] ?? 'No song playing',
            title: currentTrackData?['title'] ?? 'No song playing',
            artist: currentTrackData?['artist'] ?? '',
            albumArtUrl: currentTrackData?['albumArtUrl'] ?? 'https://via.placeholder.com/64',
          );

          // Get queue from party data
          List<Song> queue = [];
          if (party.queue != null && party.queue is List) {
            queue = (party.queue as List).map((item) {
              if (item is Map<String, dynamic>) {
                return Song(
                  id: item['id'] ?? '',
                  title: item['title'] ?? 'Unknown song',
                  artist: item['artist'] ?? 'Unknown artist',
                  albumArtUrl: item['albumArtUrl'] ?? 'https://via.placeholder.com/64',
                );
              }
              return Song(
                id: '',
                title: 'Unknown song',
                artist: 'Unknown artist',
                albumArtUrl: 'https://via.placeholder.com/64',
              );
            }).toList();
          }

          return Column(
            children: [
              // Current song playing
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).primaryColorLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            currentSong.albumArtUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.music_note),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentSong.artist,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Player controls (only for host)
              if (isHost)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          party.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 40,
                        ),
                        onPressed: () => _partyService.playPause(widget.partyId),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 36),
                        onPressed: () => _partyService.skipSong(widget.partyId),
                      ),
                    ],
                  ),
                ),

              // Queue header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'QUEUE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Song'),
                      onPressed: () {
                        // Navigate to song search/add page
                        Navigator.pushNamed(context, '/search', arguments: widget.partyId);
                      },
                    ),
                  ],
                ),
              ),

              // Song queue
              Expanded(
                child: queue.isEmpty
                    ? const Center(child: Text('No songs in queue'))
                    : ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    return SongQueueItem(song: queue[index]);
                  },
                ),
              ),

              // Leave party button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _partyService.leaveParty(widget.partyId);
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: Text(isHost ? 'End Party' : 'Leave Party'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}