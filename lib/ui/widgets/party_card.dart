import 'package:flutter/material.dart';
import '../../models/party.dart';

class PartyCard extends StatelessWidget {
  final Party party;

  const PartyCard({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(party.name),
        subtitle: Text('Participants: ${party.participants.length}'),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Navigate to party details page
          },
          child: const Text('Join'),
        ),
      ),
    );
  }
}
