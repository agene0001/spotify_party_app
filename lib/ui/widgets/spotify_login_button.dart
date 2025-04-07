import 'package:flutter/material.dart';

class SpotifyLoginButton extends StatelessWidget {
  final VoidCallback onLogin;

  SpotifyLoginButton({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogin,
      child: Text('Login with Spotify'),
    );
  }
}
