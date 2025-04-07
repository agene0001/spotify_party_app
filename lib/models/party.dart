class Party {
  final String id;
  final String name;
  final List<String> participants;
  final List<String> queue;

  Party({
    required this.id,
    required this.name,
    required this.participants,
    required this.queue,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      participants: List<String>.from(json['participants']),
      queue: List<String>.from(json['queue']),
    );
  }
}
