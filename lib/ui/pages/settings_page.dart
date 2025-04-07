import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/user_service.dart';
import 'package:spotify_party_app/ui/widgets/user_profile_widget.dart';

class SettingsPage extends StatelessWidget {
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: FutureBuilder(
        future: userService.fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading settings'));
          }
          var user = snapshot.data;
          return Column(
            children: [
              UserProfileWidget(user: user),
              SwitchListTile(
                title: Text('Party Notifications'),
                value: user.notificationsEnabled,
                onChanged: (value) => userService.updateUserSettings(value),
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () => userService.logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
