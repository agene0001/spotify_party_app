import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ui/pages/auth_page.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/party_detail_page.dart';
import 'ui/pages/search_song_page.dart';
import 'ui/pages/settings_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'package:web/web.dart' as web;
void main() async{
  await dotenv.load(fileName: ".env");

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
