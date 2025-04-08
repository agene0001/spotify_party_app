import "./song.dart";
class Party {
  final String id;
  final String name;
  final List<String> participants;
  final List<String> queue;
  final Song currentSong; // Current song being played
  final bool isHost; // Indicates if the user is the host

  Party({
    required this.id,
    required this.name,
    required this.participants,
    required this.queue,
    required this.currentSong, // Initialize currentSong
    required this.isHost, // Initialize isHost
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      participants: List<String>.from(json['participants']),
      queue: List<String>.from(json['queue']),
      currentSong: Song.fromJson(json['currentSong']), // Assuming you have a Song model
      isHost: json['isHost'], // Check if the user is the host
    );
  }
}
