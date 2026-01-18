import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  Map<String, double> _totals = {'income': 0.0, 'expense': 0.0, 'net': 0.0};

  List<TransactionModel> get transactions => _transactions;
  Map<String, double> get totals => _totals;

  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.readAllTransactions();
    await loadTotals();
    notifyListeners();
  }

  Future<void> loadTotals() async {
    _totals = await DatabaseHelper.instance.getTotals();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.createTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }
}
