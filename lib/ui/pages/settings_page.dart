import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/user_service.dart';
import 'package:spotify_party_app/ui/widgets/user_profile_widget.dart';
import 'package:spotify_party_app/models/user.dart'; // Assuming you have a Party model

class SettingsPage extends StatelessWidget {
  final UserService userService = UserService();
  final String accessToken; // Add this
  SettingsPage({required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: FutureBuilder(
        future: userService.getUserProfile(accessToken),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading settings'));
          }
          var user = snapshot.data as User;
          return Column(
            children: [
              UserProfileWidget(user: user),
              SwitchListTile(
                title: Text('Party Notifications'),
                value: user.notificationsEnabled,
                onChanged: (value) => userService.updateUserSettings(accessToken,value),
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () => userService.logout(accessToken),
              ),
            ],
          );
        },
      ),
    );
  }
}
