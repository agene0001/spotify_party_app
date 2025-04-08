import 'package:flutter/material.dart';
import 'package:spotify_party_app/services/party_service.dart';
import 'package:spotify_party_app/ui/widgets/party_card.dart';

class HomePage extends StatelessWidget {

  final PartyService partyService = PartyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Active Listening Parties')),
      body: FutureBuilder(
        future: partyService.fetchActiveParties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching parties'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No active parties.'));
          }
          var parties = snapshot.data;
          return ListView.builder(
            itemCount: parties?.length,
            itemBuilder: (context, index) {
              return PartyCard(party: parties![index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-party'),
        child: Icon(Icons.add),
      ),
    );
  }
}
