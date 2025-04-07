class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      albumArtUrl: json['album_art_url'],
    );
  }
}
