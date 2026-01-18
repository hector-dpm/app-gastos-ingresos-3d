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
    _database = await _initDB('printing_expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intNullable = 'INTEGER';

    // Tabla de Impresoras
    await db.execute('''
CREATE TABLE printers ( 
  id $idType, 
  name $textType,
  model $textType,
  cost $realType,
  purchase_date $textType
  )
''');

    // Tabla de Materiales
    await db.execute('''
CREATE TABLE materials ( 
  id $idType, 
  name $textType,
  type $textType,
  color $textType,
  weight_g $realType,
  cost $realType,
  purchase_date $textType
  )
''');

    // Tabla de Transacciones
    await db.execute('''
CREATE TABLE transactions ( 
  id $idType, 
  type $textType,
  amount $realType,
  description $textType,
  date $textType,
  printer_id $intNullable,
  material_id $intNullable,
  FOREIGN KEY (printer_id) REFERENCES printers (id) ON DELETE SET NULL,
  FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE SET NULL
  )
''');
  }

  // --- CRUD Impresoras ---
  Future<Printer> createPrinter(Printer printer) async {
    final db = await instance.database;
    final id = await db.insert('printers', printer.toJson());
    return printer.copyWith(id: id);
  }

  Future<Printer> readPrinter(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'printers',
      columns: ['id', 'name', 'model', 'cost', 'purchase_date'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Printer.fromJson(maps.first);
    } else {
      throw Exception('Printer ID $id not found');
    }
  }

  Future<List<Printer>> readAllPrinters() async {
    final db = await instance.database;
    final result = await db.query('printers', orderBy: 'name ASC');
    return result.map((json) => Printer.fromJson(json)).toList();
  }

  Future<int> updatePrinter(Printer printer) async {
    final db = await instance.database;
    return db.update(
      'printers',
      printer.toJson(),
      where: 'id = ?',
      whereArgs: [printer.id],
    );
  }

  Future<int> deletePrinter(int id) async {
    final db = await instance.database;
    return await db.delete('printers', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Materiales ---
  Future<MaterialModel> createMaterial(MaterialModel material) async {
    final db = await instance.database;
    final id = await db.insert('materials', material.toJson());
    return material.copyWith(id: id);
  }

  Future<List<MaterialModel>> readAllMaterials() async {
    final db = await instance.database;
    final result = await db.query('materials', orderBy: 'name ASC');
    return result.map((json) => MaterialModel.fromJson(json)).toList();
  }

  Future<int> updateMaterial(MaterialModel material) async {
    final db = await instance.database;
    return db.update(
      'materials',
      material.toJson(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await instance.database;
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Transacciones ---
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toJson());
    return transaction.copyWith(id: id);
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Agregaciones ---
  Future<Map<String, double>> getTotals() async {
    final db = await instance.database;

    // Total Ingresos
    final resultIncome = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'INGRESO'",
    );
    double income = (resultIncome.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total Gastos
    final resultExpense = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'GASTO'",
    );
    double expense = (resultExpense.first['total'] as num?)?.toDouble() ?? 0.0;

    return {'income': income, 'expense': expense, 'net': income - expense};
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
