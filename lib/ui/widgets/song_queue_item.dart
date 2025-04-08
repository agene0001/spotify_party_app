import 'package:flutter/material.dart';
import '../../models/song.dart';

class SongQueueItem extends StatelessWidget {
  final Song song;

  const SongQueueItem({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(song.albumArtUrl, width: 50),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.thumb_up),
        onPressed: () {
          // TODO: Handle upvote action
        },
      ),
    );
  }
}
