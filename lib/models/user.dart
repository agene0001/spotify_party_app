class User {
  final String id;
  final String username;
  final String profileImageUrl;
  final String spotifyId;
  final bool notificationsEnabled;

  User({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.spotifyId,
    required this.notificationsEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
      spotifyId: json['spotify_id'],
      notificationsEnabled: json['notifications_enabled'] ?? false,
    );
  }
}
