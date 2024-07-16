// model/sales.dart

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
}
