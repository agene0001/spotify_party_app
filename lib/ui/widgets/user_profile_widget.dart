import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserProfileWidget extends StatelessWidget {
  final SpotifyUser user;

  const UserProfileWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
          radius: 40,
        ),
        const SizedBox(height: 10),
        Text(user.username, style: const TextStyle(fontSize: 20)),
        Text('Spotify ID: ${user.spotifyId}'),
      ],
    );
  }
}
