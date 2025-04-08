import 'package:flutter/material.dart';
import 'ui/pages/auth_page.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/party_detail_page.dart';
import 'ui/pages/search_song_page.dart';
import 'ui/pages/settings_page.dart';

void main() {
  runApp(SpotifyPartyApp());
}

class SpotifyPartyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Party App',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationPage(),
        '/home': (context) => HomePage(),
        // '/party-detail': (context) => PartyDetailPage(),
        // '/search-song': (context) => SearchSongPage(),
        // '/settings': (context) => SettingsPage(),
      },
    );
  }
}
