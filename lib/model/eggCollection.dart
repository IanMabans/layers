class EggCollection {
  final DateTime date;
  final int count;
  late final double feedCost;

  EggCollection({
    required this.date,
    required this.count,
    this.feedCost = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'feedCost': feedCost, // Ensure feedCost is included
    };
  }

  factory EggCollection.fromMap(Map<String, dynamic> map) {
    return EggCollection(
      date: DateTime.parse(map['date']),
      count: map['count'],
      feedCost: map['feedCost'] ?? 0.0, // Ensure feedCost is retrieved
    );
  }

  @override
  String toString() => 'Egg Count: $count, Feed Cost: $feedCost';
}
