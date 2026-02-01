class SaleModel {
  final int? id;
  final String description;
  final double salePrice; // Precio de venta
  final double weightUsedG; // Peso usado en gramos
  final int printerId;
  final int materialId;
  final double materialCostPerG; // Costo por gramo del material
  final double electricityCost; // Costo de electricidad (calculado)
  final DateTime date;

  // Nuevos campos
  final double printTimeHours; // Tiempo en horas
  final double kwhPrice; // Precio del kWh
  final double otherCosts; // Otros costos (fallos, post-procesado)

  SaleModel({
    this.id,
    required this.description,
    required this.salePrice,
    required this.weightUsedG,
    required this.printerId,
    required this.materialId,
    required this.materialCostPerG,
    required this.electricityCost,
    required this.date,
    this.printTimeHours = 0.0,
    this.kwhPrice = 0.0,
    this.otherCosts = 0.0,
  });

  // Calcular costo total de producción (material + luz + otros)
  double get productionCost =>
      (weightUsedG * materialCostPerG) + electricityCost + otherCosts;

  // Calcular ganancia neta
  double get netProfit => salePrice - productionCost;

  SaleModel copyWith({
    int? id,
    String? description,
    double? salePrice,
    double? weightUsedG,
    int? printerId,
    int? materialId,
    double? materialCostPerG,
    double? electricityCost,
    DateTime? date,
    double? printTimeHours,
    double? kwhPrice,
    double? otherCosts,
  }) {
    return SaleModel(
      id: id ?? this.id,
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      weightUsedG: weightUsedG ?? this.weightUsedG,
      printerId: printerId ?? this.printerId,
      materialId: materialId ?? this.materialId,
      materialCostPerG: materialCostPerG ?? this.materialCostPerG,
      electricityCost: electricityCost ?? this.electricityCost,
      date: date ?? this.date,
      printTimeHours: printTimeHours ?? this.printTimeHours,
      kwhPrice: kwhPrice ?? this.kwhPrice,
      otherCosts: otherCosts ?? this.otherCosts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descripcion': description,
    'precio_venta': salePrice,
    'peso_usado_g': weightUsedG,
    'printer_id': printerId,
    'material_id': materialId,
    'costo_material_por_g': materialCostPerG,
    'costo_electricidad': electricityCost,
    'fecha': date.toIso8601String(),
    'tiempo_impresion_h': printTimeHours,
    'precio_kwh': kwhPrice,
    'otros_costos': otherCosts,
  };

  static SaleModel fromJson(Map<String, dynamic> json) => SaleModel(
    id: json['id'] as int?,
    description: json['descripcion'] as String,
    salePrice: (json['precio_venta'] as num).toDouble(),
    weightUsedG: (json['peso_usado_g'] as num).toDouble(),
    printerId: json['printer_id'] as int,
    materialId: json['material_id'] as int,
    materialCostPerG: (json['costo_material_por_g'] as num).toDouble(),
    electricityCost: (json['costo_electricidad'] as num).toDouble(),
    date: DateTime.parse(json['fecha'] as String),
    printTimeHours: (json['tiempo_impresion_h'] as num?)?.toDouble() ?? 0.0,
    kwhPrice: (json['precio_kwh'] as num?)?.toDouble() ?? 0.0,
    otherCosts: (json['otros_costos'] as num?)?.toDouble() ?? 0.0,
  );
}
