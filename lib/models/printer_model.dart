class Printer {
  final int? id;
  final String name;
  final String model;
  final double cost;
  final DateTime purchaseDate;

  Printer({
    this.id,
    required this.name,
    required this.model,
    required this.cost,
    required this.purchaseDate,
  });

  Printer copyWith({
    int? id,
    String? name,
    String? model,
    double? cost,
    DateTime? purchaseDate,
  }) {
    return Printer(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      cost: cost ?? this.cost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'model': model,
    'cost': cost,
    'purchase_date': purchaseDate.toIso8601String(),
  };

  static Printer fromJson(Map<String, dynamic> json) => Printer(
    id: json['id'] as int?,
    name: json['name'] as String,
    model: json['model'] as String,
    cost: (json['cost'] as num).toDouble(),
    purchaseDate: DateTime.parse(json['purchase_date'] as String),
  );
}
