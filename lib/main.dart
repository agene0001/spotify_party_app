import 'package:flutter/material.dart';
import 'ui/pages/auth_page.dart';
import 'ui/pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
    ),
  );
  runApp(const SpotifyPartyApp());
}

/// Call this method when your app initializes

class SpotifyPartyApp extends StatelessWidget {
  const SpotifyPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Party App',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthenticationPage(),
        '/home': (context) => HomePage(),
        // '/party-detail': (context) => PartyDetailPage(),
        // '/search-song': (context) => SearchSongPage(),
        // '/settings': (context) => SettingsPage(),
      },
    );
  }
}
