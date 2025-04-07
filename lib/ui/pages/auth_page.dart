import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/auth_service.dart';
import 'package:spotify_party_app/ui/widgets/spotify_login_button.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Spotify Party')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),
            Text('Login with your Spotify account'),
            SizedBox(height: 20),
            SpotifyLoginButton(authService: AuthService()),
          ],
        ),
      ),
    );
  }
}
