import 'package:cloud_firestore/cloud_firestore.dart';
class Party {
  final String id;
  final String name;
  final String createdBy;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? currentTrack;
  final bool isPlaying;
  final List<String> participants;
  final List<Map<String, dynamic>>? queue; // Add the queue field

  Party({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.isActive,
    required this.createdAt,
    this.currentTrack,
    required this.isPlaying,
    required this.participants,
    this.queue, // Add queue to the constructor
  });

  factory Party.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Party(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentTrack: data['currentTrack'] as Map<String, dynamic>?,
      isPlaying: data['isPlaying'] ?? false,
      participants: List<String>.from(data['participants'] ?? []),
      queue: data['queue'] != null ? List<Map<String, dynamic>>.from(data['queue']) : null, // Handle the queue
    );
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      currentTrack: json['currentTrack'] as Map<String, dynamic>?,
      isPlaying: json['isPlaying'] ?? false,
      participants: List<String>.from(json['participants'] ?? []),
      queue: json['queue'] != null ? List<Map<String, dynamic>>.from(json['queue']) : null, // Handle the queue
    );
  }
}
