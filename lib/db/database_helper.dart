import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/printer_model.dart';
import '../models/material_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('impresoras_materiales_gastos_ingresos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
    fecha_compra $tipoTexto
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

    // Tabla de Transacciones
    await db.execute('''
    CREATE TABLE transacciones ( 
    id $idType, 
    tipo $tipoTexto,
    cantidad $tipoReal,
    descripcion $tipoTexto,
    fecha $tipoTexto,
    printer_id $tipoEntero,
    material_id $tipoEntero,
    FOREIGN KEY (printer_id) REFERENCES printers (id) ON DELETE SET NULL,
    FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE SET NULL
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
      columns: ['id', 'nombre', 'modelo', 'costo', 'fecha_compra'],
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

  // --- CRUD Transacciones ---
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final db = await instance.database;
    final id = await db.insert('transacciones', transaction.toJson());
    return transaction.copyWith(id: id);
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transacciones', orderBy: 'fecha DESC');
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transacciones', where: 'id = ?', whereArgs: [id]);
  }

  // --- Agregaciones ---
  Future<Map<String, double>> getTotals() async {
    final db = await instance.database;

    // Total Ingresos
    final resultIncome = await db.rawQuery(
      "SELECT SUM(cantidad) as ingreso FROM transacciones WHERE tipo = 'INGRESO'",
    );
    double income = (resultIncome.first['ingreso'] as num?)?.toDouble() ?? 0.0;

    // Total Gastos
    final resultExpense = await db.rawQuery(
      "SELECT SUM(cantidad) as gasto FROM transacciones WHERE tipo = 'GASTO'",
    );
    double expense = (resultExpense.first['gasto'] as num?)?.toDouble() ?? 0.0;

    return {'ingreso': income, 'gasto': expense, 'net': income - expense};
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
