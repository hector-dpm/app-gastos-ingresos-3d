import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/printer_model.dart';
import '../models/material_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('impresoras_materiales.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración V2 (ya implementada previamente)
      // Agregar contador_impresiones a impresoras
      await db.execute(
        'ALTER TABLE impresoras ADD COLUMN contador_impresiones INTEGER DEFAULT 0',
      );

      // Crear tabla de ventas
      await db.execute('''
        CREATE TABLE ventas ( 
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          descripcion TEXT NOT NULL,
          precio_venta REAL NOT NULL,
          peso_usado_g REAL NOT NULL,
          printer_id INTEGER NOT NULL,
          material_id INTEGER NOT NULL,
          costo_material_por_g REAL NOT NULL,
          costo_electricidad REAL NOT NULL,
          fecha TEXT NOT NULL,
          FOREIGN KEY (printer_id) REFERENCES impresoras (id) ON DELETE CASCADE,
          FOREIGN KEY (material_id) REFERENCES materiales (id) ON DELETE CASCADE
        )
      ''');

      // Crear tabla de gastos
      await db.execute('''
        CREATE TABLE gastos ( 
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          descripcion TEXT NOT NULL,
          cantidad REAL NOT NULL,
          categoria TEXT NOT NULL,
          fecha TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Migración V3
      // Agregar consumo a impresoras
      try {
        await db.execute(
          'ALTER TABLE impresoras ADD COLUMN consumo_watts INTEGER DEFAULT 300',
        );
      } catch (e) {
        // Columna podría ya existir si se ejecutó onCreate v3 directamente
      }

      // Agregar campos a ventas. SQLite no soporta agregar múltiples columnas en una sola sentencia fácil, así que una por una.
      try {
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN tiempo_impresion_h REAL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN precio_kwh REAL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN otros_costos REAL DEFAULT 0',
        );
      } catch (e) {
        // Ignorar si ya existen
      }
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const tipoTexto = 'TEXT NOT NULL';
    const tipoReal = 'REAL NOT NULL';
    const tipoEntero = 'INTEGER';

    // Tabla de Impresoras
    await db.execute('''
    CREATE TABLE impresoras ( 
    id $idType, 
    nombre $tipoTexto,
    modelo $tipoTexto,
    costo $tipoReal,
    fecha_compra $tipoTexto,
    contador_impresiones $tipoEntero DEFAULT 0,
    consumo_watts $tipoEntero DEFAULT 300
    )
''');

    // Tabla de Materiales
    await db.execute('''
    CREATE TABLE materiales ( 
    id $idType, 
    nombre $tipoTexto,
    tipo $tipoTexto,
    color $tipoTexto,
    peso_g $tipoReal,
    costo $tipoReal,
    fecha_compra $tipoTexto
    )
''');

    // Tabla de Ventas
    await db.execute('''
    CREATE TABLE ventas ( 
    id $idType, 
    descripcion $tipoTexto,
    precio_venta $tipoReal,
    peso_usado_g $tipoReal,
    printer_id $tipoEntero NOT NULL,
    material_id $tipoEntero NOT NULL,
    costo_material_por_g $tipoReal,
    costo_electricidad $tipoReal,
    fecha $tipoTexto,
    tiempo_impresion_h $tipoReal DEFAULT 0,
    precio_kwh $tipoReal DEFAULT 0,
    otros_costos $tipoReal DEFAULT 0,
    FOREIGN KEY (printer_id) REFERENCES impresoras (id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materiales (id) ON DELETE CASCADE
    )
''');

    // Tabla de Gastos
    await db.execute('''
    CREATE TABLE gastos ( 
    id $idType, 
    descripcion $tipoTexto,
    cantidad $tipoReal,
    categoria $tipoTexto,
    fecha $tipoTexto
    )
''');
  }

  // --- CRUD Impresoras ---
  Future<Printer> createPrinter(Printer printer) async {
    final db = await instance.database;
    final id = await db.insert('impresoras', printer.toJson());
    return printer.copyWith(id: id);
  }

  Future<Printer> readPrinter(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'impresoras',
      columns: [
        'id',
        'nombre',
        'modelo',
        'costo',
        'fecha_compra',
        'contador_impresiones',
        'consumo_watts',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Printer.fromJson(maps.first);
    } else {
      throw Exception('ID de impresora $id no encontrado');
    }
  }

  Future<List<Printer>> readAllPrinters() async {
    final db = await instance.database;
    final result = await db.query('impresoras', orderBy: 'nombre ASC');
    return result.map((json) => Printer.fromJson(json)).toList();
  }

  Future<int> updatePrinter(Printer printer) async {
    final db = await instance.database;
    return db.update(
      'impresoras',
      printer.toJson(),
      where: 'id = ?',
      whereArgs: [printer.id],
    );
  }

  Future<int> deletePrinter(int id) async {
    final db = await instance.database;
    return await db.delete('impresoras', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementPrinterCount(int printerId) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE impresoras SET contador_impresiones = contador_impresiones + 1 WHERE id = ?',
      [printerId],
    );
  }

  // --- CRUD Materiales ---
  Future<MaterialModel> createMaterial(MaterialModel material) async {
    final db = await instance.database;
    final id = await db.insert('materiales', material.toJson());
    return material.copyWith(id: id);
  }

  Future<List<MaterialModel>> readAllMaterials() async {
    final db = await instance.database;
    final result = await db.query('materiales', orderBy: 'nombre ASC');
    return result.map((json) => MaterialModel.fromJson(json)).toList();
  }

  Future<int> updateMaterial(MaterialModel material) async {
    final db = await instance.database;
    return db.update(
      'materiales',
      material.toJson(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await instance.database;
    return await db.delete('materiales', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> decreaseMaterialWeight(int materialId, double weightG) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE materiales SET peso_g = peso_g - ? WHERE id = ?',
      [weightG, materialId],
    );
  }

  // --- CRUD Ventas ---
  Future<SaleModel> createSale(SaleModel sale) async {
    final db = await instance.database;
    final id = await db.insert('ventas', sale.toJson());

    // Actualizar peso del material y contador
    await decreaseMaterialWeight(sale.materialId, sale.weightUsedG);
    await incrementPrinterCount(sale.printerId);

    return sale.copyWith(id: id);
  }

  Future<List<SaleModel>> readAllSales() async {
    final db = await instance.database;
    final result = await db.query('ventas', orderBy: 'fecha DESC');
    return result.map((json) => SaleModel.fromJson(json)).toList();
  }

  Future<int> updateSale(SaleModel sale) async {
    final db = await instance.database;

    // 1. Obtener la venta anterior para revertir sus efectos
    final oldSaleResult = await db.query(
      'ventas',
      where: 'id = ?',
      whereArgs: [sale.id],
    );
    if (oldSaleResult.isNotEmpty) {
      final oldSale = SaleModel.fromJson(oldSaleResult.first);

      // Revertir: Devolver peso al material anterior
      await db.rawUpdate(
        'UPDATE materiales SET peso_g = peso_g + ? WHERE id = ?',
        [oldSale.weightUsedG, oldSale.materialId],
      );

      // Revertir: Restar al contador de la impresora anterior
      await db.rawUpdate(
        'UPDATE impresoras SET contador_impresiones = contador_impresiones - 1 WHERE id = ?',
        [oldSale.printerId],
      );
    }

    // 2. Actualizar la venta
    final result = await db.update(
      'ventas',
      sale.toJson(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );

    // 3. Aplicar nuevos efectos
    await decreaseMaterialWeight(sale.materialId, sale.weightUsedG);
    await incrementPrinterCount(sale.printerId);

    return result;
  }

  Future<int> deleteSale(int id) async {
    final db = await instance.database;

    // 1. Obtener la venta antes de borrar para restaurar
    final saleResult = await db.query(
      'ventas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (saleResult.isNotEmpty) {
      final sale = SaleModel.fromJson(saleResult.first);

      // Restaurar peso
      await db.rawUpdate(
        'UPDATE materiales SET peso_g = peso_g + ? WHERE id = ?',
        [sale.weightUsedG, sale.materialId],
      );

      // Restaurar contador de impresora
      await db.rawUpdate(
        'UPDATE impresoras SET contador_impresiones = contador_impresiones - 1 WHERE id = ?',
        [sale.printerId],
      );
    }

    return await db.delete('ventas', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Gastos ---
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final db = await instance.database;
    final id = await db.insert('gastos', expense.toJson());
    return expense.copyWith(id: id);
  }

  Future<List<ExpenseModel>> readAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('gastos', orderBy: 'fecha DESC');
    return result.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.update(
      'gastos',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // --- Estadísticas ---
  Future<Map<String, double>> getFinancialSummary() async {
    final db = await instance.database;

    // Total ventas (precio de venta)
    final salesResult = await db.rawQuery(
      'SELECT SUM(precio_venta) as total FROM ventas',
    );
    double totalSales = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total costos de producción (material + electricidad + otros)
    final costsResult = await db.rawQuery(
      'SELECT SUM((peso_usado_g * costo_material_por_g) + costo_electricidad + otros_costos) as total FROM ventas',
    );
    double totalCosts = (costsResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total gastos
    final expensesResult = await db.rawQuery(
      'SELECT SUM(cantidad) as total FROM gastos',
    );
    double totalExpenses =
        (expensesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    double netProfit = totalSales - totalCosts - totalExpenses;

    return {
      'totalSales': totalSales,
      'totalCosts': totalCosts,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
    };
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
