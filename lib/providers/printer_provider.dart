import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/printer_model.dart';

class PrinterProvider with ChangeNotifier {
  List<Printer> _printers = [];

  List<Printer> get printers => _printers;

  Future<void> loadPrinters() async {
    _printers = await DatabaseHelper.instance.readAllPrinters();
    notifyListeners();
  }

  Future<void> addPrinter(Printer printer) async {
    await DatabaseHelper.instance.createPrinter(printer);
    await loadPrinters();
  }

  Future<void> updatePrinter(Printer printer) async {
    await DatabaseHelper.instance.updatePrinter(printer);
    await loadPrinters();
  }

  Future<void> deletePrinter(int id) async {
    await DatabaseHelper.instance.deletePrinter(id);
    await loadPrinters();
  }
}
