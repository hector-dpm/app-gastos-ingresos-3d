import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/sale_model.dart';

class SaleProvider with ChangeNotifier {
  List<SaleModel> _sales = [];

  List<SaleModel> get sales => _sales;

  Future<void> loadSales() async {
    _sales = await DatabaseHelper.instance.readAllSales();
    notifyListeners();
  }

  Future<void> addSale(SaleModel sale) async {
    await DatabaseHelper.instance.createSale(sale);
    await loadSales();
  }

  Future<void> updateSale(SaleModel sale) async {
    await DatabaseHelper.instance.updateSale(sale);
    await loadSales();
  }

  Future<void> deleteSale(int id) async {
    await DatabaseHelper.instance.deleteSale(id);
    await loadSales();
  }

  // Calcular totales
  double get totalRevenue =>
      _sales.fold(0.0, (sum, sale) => sum + sale.salePrice);
  double get totalCosts =>
      _sales.fold(0.0, (sum, sale) => sum + sale.productionCost);
  double get totalProfit =>
      _sales.fold(0.0, (sum, sale) => sum + sale.netProfit);
}
