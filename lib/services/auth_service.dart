import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart'; // Import flutter_web_auth
import 'package:uuid/uuid.dart'; // For generating state parameter
import 'package:web/web.dart' as web;
class AuthService {
  // --- Spotify Configuration ---
  final String? _clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
  final String? _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];
  // IMPORTANT: Use the EXACT Redirect URI registered in Spotify Dashboard
  final String _redirectUri = kIsWeb?"http://localhost:8000/home":'spotifypartyapp://callback';
  // Define the callback URL scheme (must match the scheme in _redirectUri)
  final String _callbackUrlScheme = 'spotifypartyapp';

  final String _authorizationEndpoint = 'https://accounts.spotify.com/authorize';
  final String _tokenEndpoint = 'https://accounts.spotify.com/api/token';

  // Define the scopes (permissions) your app needs
  // See: https://developer.spotify.com/documentation/web-api/concepts/scopes
  final String _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    'user-library-read',
    'user-library-modify',
    'streaming', // Required for playback control if you implement it
    // Add other scopes as needed
  ].join(' '); // Join scopes with spaces

  // --- Secure Storage ---
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _accessTokenKey = 'spotify_access_token';
  final String _refreshTokenKey = 'spotify_refresh_token';
  final String _tokenExpiryKey = 'spotify_token_expiry'; // Store expiry timestamp

  // --- Public Methods ---

  /// Initiates the Spotify Login flow.
  /// Returns the access token if successful, null otherwise.
  Future<String?> loginWithSpotify() async {
    // Check if we're on web platform
    if (_clientId == null || _clientSecret == null) {
      if (kDebugMode) {
        print('Error: Spotify Client ID or Secret not found in .env');
      }
      return null;
    }

    // Generate a secure random state parameter to prevent CSRF attacks
    final String state = const Uuid().v4();

    // 1. Construct Authorization URL
    final Uri authUri = Uri.parse('$_authorizationEndpoint?').replace(queryParameters: {
      'client_id': _clientId,
      'response_type': 'code', // We want an authorization code
      'redirect_uri': _redirectUri,
      'scope': _scopes,
      'state': state, // Include the state parameter
      'show_dialog': 'true', // Optional: Force user to re-approve scopes
    });

    if (kIsWeb) {
      return _loginWithSpotifyWeb(state,authUri);
    } else {
      return _loginWithSpotifyMobile(state,authUri);
    }
  }
  Future<String?> checkForSpotifyAuthCallback() async {
    if (!kIsWeb) return null;

    // Get current URL
    final Uri currentUri = Uri.parse(web.window.location.href);

    // if (kDebugMode) {
    //   print('Checking for Spotify auth callback in URL: ${currentUri.toString()}');
    // }

    // Check if this is a callback from Spotify (will have 'code' parameter)
    if (currentUri.queryParameters.containsKey('code')) {
      final String? code = currentUri.queryParameters['code'];
      final String? state = currentUri.queryParameters['state'];

      // if (kDebugMode) {
      //   print('Found Spotify callback with code: ${code?.substring(0, 5)}...');
      // }

      if (code != null) {
        // Exchange the code for tokens
        final accessToken = await _exchangeCodeForTokens(code);

        // Clean up the URL by removing the query parameters
        web.window.history.pushState({} as JSAny?, '', '/');

        return accessToken;
      }
    }

    return null;
  }

  /// Retrieves the current valid access token.
  /// Automatically refreshes if expired. Returns null if refresh fails or no token exists.
  Future<String?> getAccessToken() async {
    final String? accessToken = await _secureStorage.read(key: _accessTokenKey);
    final String? expiryTimestampStr = await _secureStorage.read(key: _tokenExpiryKey);

    if (accessToken == null || expiryTimestampStr == null) {
      return null; // No token stored
    }

    final int? expiryTimestamp = int.tryParse(expiryTimestampStr);
    if (expiryTimestamp == null) {
      await logout(); // Corrupted data
      return null;
    }

    // Check if token is expired (add a small buffer, e.g., 60 seconds)
    final DateTime expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    if (DateTime.now().isAfter(expiryTime.subtract(const Duration(seconds: 60)))) {
      if (kDebugMode) {
        print('Access token expired, attempting refresh...');
      }
      // Token expired, try to refresh
      return await _refreshAccessToken();
    } else {
      // Token is still valid
      return accessToken;
    }
  }

  /// Clears stored Spotify tokens.
  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
    if (kDebugMode) {
      print('Logged out, tokens cleared.');
    }
    // Optionally: Add call to revoke token on Spotify side if needed
    // See: https://developer.spotify.com/documentation/web-api/reference/#/operations/revoke-access-token (requires backend usually)
  }


  // --- Private Helper Methods ---
  Future<String?> _loginWithSpotifyMobile(state, authUri) async {

    if (kDebugMode) {
      print('Auth URI: $authUri');
    }

    try {
      // 2. Open the Authorization URL using flutter_web_auth
      // This opens a web view/browser tab for the user to log in and authorize
      // It listens for the redirect back to your _callbackUrlScheme
      final String resultUrl = await FlutterWebAuth.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: _callbackUrlScheme,
        preferEphemeral: true, // iOS option: use private session
      );

      if (kDebugMode) {
        print('Callback Result URL: $resultUrl');
      }

      // 3. Handle the Callback URL
      final Uri callbackUri = Uri.parse(resultUrl);

      // Verify the state parameter
      final String? returnedState = callbackUri.queryParameters['state'];
      if (returnedState == null || returnedState != state) {
        if (kDebugMode) {
          print('Error: Invalid state parameter received. Potential CSRF attack.');
        }
        return null; // State mismatch, abort!
      }

      // Check for errors in the callback
      final String? error = callbackUri.queryParameters['error'];
      if (error != null) {
        if (kDebugMode) {
          print('Spotify Auth Error: $error');
        }
        return null; // User denied access or another error occurred
      }

      // Extract the authorization code
      final String? code = callbackUri.queryParameters['code'];
      if (code == null) {
        if (kDebugMode) {
          print('Error: Authorization code not found in callback.');
        }
        return null;
      }

      // 4. Exchange the code for tokens
      return await _exchangeCodeForTokens(code);

    } catch (e) {
      if (kDebugMode) {
        print('Error during Spotify Authentication: $e');
      }
      return null;
    }
  }
  Future<String?> _loginWithSpotifyWeb(state, authUri) async {

    // Redirect the browser to Spotify login
    web.window.location.href = authUri.toString();

    // This function won't actually return here since we're redirecting
    // The code handling will need to be done when the app loads after redirect
    return "";
  }
  /// Exchanges an authorization code for access and refresh tokens.
  Future<String?> _exchangeCodeForTokens(String code) async {
    if (_clientId == null || _clientSecret == null) return null;

    try {
      final String credentials = base64.encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri, // Must match the one used in the auth request
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        final String? accessToken = tokenData['access_token'];
        final String? refreshToken = tokenData['refresh_token'];
        final int? expiresIn = tokenData['expires_in']; // Usually 3600 seconds (1 hour)

        if (accessToken != null && refreshToken != null && expiresIn != null) {
          await _storeTokens(accessToken, refreshToken, expiresIn);
          if (kDebugMode) {
            print('Tokens obtained and stored successfully.');
          }
          return accessToken;
        }
      } else {
        if (kDebugMode) {
          print('Error exchanging code for tokens: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during token exchange: $e');
      }
    }
    return null; // Failed to exchange or store tokens
  }

  /// Uses the refresh token to get a new access token.
  Future<String?> _refreshAccessToken() async {
    if (_clientId == null || _clientSecret == null) return null;

    final String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      if (kDebugMode) {
        print('Cannot refresh: Refresh token not found.');
      }
      await logout(); // Clear potentially inconsistent state
      return null;
    }

    try {
      final String credentials = base64.encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        final String? newAccessToken = tokenData['access_token'];
        final int? expiresIn = tokenData['expires_in'];
        // Spotify might return a new refresh token, but often doesn't. Handle if it does.
        final String? newRefreshToken = tokenData['refresh_token'];

        if (newAccessToken != null && expiresIn != null) {
          // Use the new refresh token if provided, otherwise keep the old one
          await _storeTokens(newAccessToken, newRefreshToken ?? refreshToken, expiresIn);
          if (kDebugMode) {
            print('Access token refreshed successfully.');
          }
          return newAccessToken;
        }
      } else {
        if (kDebugMode) {
          print('Error refreshing token: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        // If refresh fails (e.g., token revoked), log the user out
        await logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during token refresh: $e');
      }
    }

    return null; // Refresh failed
  }

  /// Stores tokens securely and calculates expiry time.
  Future<void> _storeTokens(String accessToken, String refreshToken, int expiresInSeconds) async {
    final DateTime expiryTime = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _tokenExpiryKey, value: expiryTime.millisecondsSinceEpoch.toString());
  }
}
