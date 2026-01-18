class MaterialModel {
  final int? id;
  final String name;
  final String type;
  final String color;
  final double weightG;
  final double cost;
  final DateTime purchaseDate;

  MaterialModel({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.weightG,
    required this.cost,
    required this.purchaseDate,
  });

  MaterialModel copyWith({
    int? id,
    String? name,
    String? type,
    String? color,
    double? weightG,
    double? cost,
    DateTime? purchaseDate,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      weightG: weightG ?? this.weightG,
      cost: cost ?? this.cost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': name,
    'tipo': type,
    'color': color,
    'peso_g': weightG,
    'costo': cost,
    'fecha_compra': purchaseDate.toIso8601String(),
  };

  static MaterialModel fromJson(Map<String, dynamic> json) => MaterialModel(
    id: json['id'] as int?,
    name: json['nombre'] as String,
    type: json['tipo'] as String,
    color: json['color'] as String,
    weightG: (json['peso_g'] as num).toDouble(),
    cost: (json['costo'] as num).toDouble(),
    purchaseDate: DateTime.parse(json['fecha_compra'] as String),
  );
}
