import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/auth_service.dart';

class SpotifyLoginButton extends StatelessWidget {
  final AuthService authService;  // Declare a variable for the authService

  // Modify the constructor to accept authService as a named parameter
  SpotifyLoginButton({required this.authService});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Call the login method from the AuthService when button is pressed
        String? token = await authService.loginWithSpotify();
        if (token != null) {
          // Handle successful login (e.g., navigate to the next screen)
          print('Logged in with token: $token');
        } else {
          // Handle failed login
          print('Login failed');
        }
      },
      child: Text('Login with Spotify'),
    );
  }
}
