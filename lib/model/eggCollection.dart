class EggCollection {
  final int? id;
  final DateTime date;
  final int count;
  final double feedCost;

  EggCollection({
    this.id,
    required this.date,
    required this.count,
    this.feedCost = 0.0,
  });

  EggCollection copyWith({int? id, DateTime? date, int? count, double? feedCost}) {
    return EggCollection(
      id: id ?? this.id,
      date: date ?? this.date,
      count: count ?? this.count,
      feedCost: feedCost ?? this.feedCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'count': count,
      'feedCost': feedCost,
    };
  }

  factory EggCollection.fromMap(Map<String, dynamic> map) {
    return EggCollection(
      id: map['id'],
      date: DateTime.parse(map['date']),
      count: map['count'],
      feedCost: map['feedCost'] ?? 0.0,
    );
  }

  @override
  String toString() => 'Egg Count: $count, Feed Cost: $feedCost';
}
