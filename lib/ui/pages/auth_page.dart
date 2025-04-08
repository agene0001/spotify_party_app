import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:spotify_party_app/services/auth_service.dart';
import 'package:spotify_party_app/ui/widgets/spotify_login_button.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkForCallback();
  }

  Future<void> _checkForCallback() async {
    if (kIsWeb) {
      setState(() {
        _isLoading = true;
      });

      try {
        final accessToken = await _authService.checkForSpotifyAuthCallback();

        if (accessToken != null) {
          if (kDebugMode) {
            print(
              'Found valid access token from callback, navigating to home...',
            );
          }
          // Use Future.delayed to avoid calling setState during build
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking for auth callback: $e');
        }
        _showErrorDialog("Authentication error: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await _authService.loginWithSpotify();

      if (accessToken != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog("Login failed. Please try again.");
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
      builder:
          (_) => AlertDialog(
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
        child:
            _isLoading
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
