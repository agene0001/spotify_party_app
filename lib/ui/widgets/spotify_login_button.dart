import 'package:flutter/material.dart';

class SpotifyLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SpotifyLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.music_note),
      label: const Text("Login with Spotify"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
