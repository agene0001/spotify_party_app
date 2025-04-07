import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserProfileWidget extends StatelessWidget {
  final User user;

  UserProfileWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
          radius: 40,
        ),
        SizedBox(height: 10),
        Text(user.username, style: TextStyle(fontSize: 20)),
        Text('Spotify ID: ${user.spotifyId}'),
      ],
    );
  }
}
