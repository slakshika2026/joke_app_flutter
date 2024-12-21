class Joke {
  final String id;
  final String setup;
  final String punchline;

  // Constructor
  const Joke({
    required this.id,
    required this.setup,
    required this.punchline,
  });

  // Factory constructor to create a Joke object from JSON
  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id']?.toString().trim() ?? '',
      setup: json['setup']?.trim() ?? 'No setup provided',
      punchline: json['punchline']?.trim() ?? 'No punchline provided',
    );
  }

  // Method to convert a Joke object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setup': setup,
      'punchline': punchline,
    };
  }

  @override
  String toString() => 'Joke(id: $id, setup: $setup, punchline: $punchline)';
}
