class ExpenseModel {
  final int? id;
  final String description;
  final double amount;
  final String category; // Ej: Mantenimiento, Herramientas, Otros
  final DateTime date;

  ExpenseModel({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  ExpenseModel copyWith({
    int? id,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descripcion': description,
    'cantidad': amount,
    'categoria': category,
    'fecha': date.toIso8601String(),
  };

  static ExpenseModel fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as int?,
    description: json['descripcion'] as String,
    amount: (json['cantidad'] as num).toDouble(),
    category: json['categoria'] as String,
    date: DateTime.parse(json['fecha'] as String),
  );
}
