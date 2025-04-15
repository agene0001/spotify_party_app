import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:spotify_party_app/services/auth_service.dart';
import 'package:spotify_party_app/services/user_service.dart'; // Import UserService
import 'package:spotify_party_app/ui/widgets/spotify_login_button.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); // Create an instance of UserService

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use UserService to check if a user is signed in
      final user = await _userService.getUserId();

      if (user != null) {
        // If a user is signed in with Firebase, check for Spotify auth callback
        final accessToken = await _authService.checkForSpotifyAuthCallback();

        if (accessToken != null) {
          if (kDebugMode) {
            print('Found valid access token from callback, navigating to home...');
          }
          // Navigate to home if Spotify login is successful
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } else {
          // If no valid Spotify access token, show Spotify login button
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // No Firebase user, prompt for Firebase sign-in
        _showFirebaseSignInPrompt();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for current user: $e');
      }
      _showErrorDialog("Error checking user: ${e.toString()}");
    } finally {
      if (_userService.getUserId() == null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFirebaseSignInPrompt() {
    // Show a dialog to prompt the user to sign in with Firebase
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign In Required"),
        content: const Text("Please sign in with your Firebase account to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleFirebaseSignIn();
            },
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFirebaseSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implement Firebase sign-in (e.g., Google sign-in or email/password)
      await _authService.loginWithGoogle();

      // After Firebase sign-in, check for Spotify auth
      final accessToken = await _authService.checkForSpotifyAuthCallback();
      if (accessToken != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If Spotify auth is not found, show the Spotify login button
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog("Firebase sign-in failed: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.loginWithSpotify();
      await Future.delayed(const Duration(seconds: 1));

      if (result != null && result.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog("Authentication was not completed. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Spotify Party')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/home.png', height: 100),
            const SizedBox(height: 20),
            const Text('Login with your Spotify account'),
            const SizedBox(height: 20),
            SpotifyLoginButton(onPressed: _handleLogin),
          ],
        ),
      ),
    );
  }
}
