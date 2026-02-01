class Printer {
  final int? id;
  final String name;
  final String model;
  final double cost;
  final DateTime purchaseDate;
  final int printCount; // Contador de impresiones
  final int powerWatts; // Consumo en Watts

  Printer({
    this.id,
    required this.name,
    required this.model,
    required this.cost,
    required this.purchaseDate,
    this.printCount = 0,
    this.powerWatts = 300, // Valor por defecto común
  });

  Printer copyWith({
    int? id,
    String? name,
    String? model,
    double? cost,
    DateTime? purchaseDate,
    int? printCount,
    int? powerWatts,
  }) {
    return Printer(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      cost: cost ?? this.cost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      printCount: printCount ?? this.printCount,
      powerWatts: powerWatts ?? this.powerWatts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': name,
    'modelo': model,
    'costo': cost,
    'fecha_compra': purchaseDate.toIso8601String(),
    'contador_impresiones': printCount,
    'consumo_watts': powerWatts,
  };

  static Printer fromJson(Map<String, dynamic> json) => Printer(
    id: json['id'] as int?,
    name: json['nombre'] as String,
    model: json['modelo'] as String,
    cost: (json['costo'] as num).toDouble(),
    purchaseDate: DateTime.parse(json['fecha_compra'] as String),
    printCount: (json['contador_impresiones'] as int?) ?? 0,
    powerWatts: (json['consumo_watts'] as int?) ?? 300,
  );
}
