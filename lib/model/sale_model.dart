class Sales {
  final String id;
  final DateTime date;
  final int quantity;
  final double price;

  Sales({
    required this.id,
    required this.date,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'price': price,
    };
  }

  static Sales fromMap(Map<String, dynamic> map) {
    return Sales(
      id: map['id'],
      date: DateTime.parse(map['date']),
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
