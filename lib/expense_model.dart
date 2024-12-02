class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({required this.id, required this.amount, required this.category, required this.date, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String, // As seen in Firebase, ID is a string.
      amount: (json['amount'] as int).toDouble(), // Amount appears as an integer in Firebase, convert to double.
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    );
  }
}