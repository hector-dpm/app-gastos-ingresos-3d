class TransactionModel {
  final int? id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final int? printerId;
  final int? materialId;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.printerId,
    this.materialId,
  });

  TransactionModel copyWith({
    int? id,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    int? printerId,
    int? materialId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      printerId: printerId ?? this.printerId,
      materialId: materialId ?? this.materialId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo': type,
    'cantidad': amount,
    'descripcion': description,
    'fecha': date.toIso8601String(),
    'printer_id': printerId,
    'material_id': materialId,
  };

  static TransactionModel fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as int?,
        type: json['tipo'] as String,
        amount: (json['cantidad'] as num).toDouble(),
        description: json['descripcion'] as String,
        date: DateTime.parse(json['fecha'] as String),
        printerId: json['printer_id'] as int?,
        materialId: json['material_id'] as int?,
      );
}
