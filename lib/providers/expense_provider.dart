import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await DatabaseHelper.instance.readAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await DatabaseHelper.instance.createExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    await loadExpenses();
  }

  // Calcular total de gastos
  double get totalExpenses =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
}
