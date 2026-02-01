import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/printer_provider.dart';
import '../providers/material_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/sale_dialog.dart';
import '../widgets/expense_dialog.dart';
import 'sales_list_screen.dart';
import 'expenses_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final printerProvider = Provider.of<PrinterProvider>(context);
    final materialProvider = Provider.of<MaterialProvider>(context);
    final saleProvider = Provider.of<SaleProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    // Calcular totales
    final totalRevenue = saleProvider.totalRevenue;
    final totalCosts = saleProvider.totalCosts;
    final totalExpenses = expenseProvider.totalExpenses;
    final netProfit = totalRevenue - totalCosts - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          // Botón para registrar venta
          IconButton(
            icon: const Icon(Icons.sell, color: Colors.green),
            tooltip: 'Registrar Venta',
            onPressed: () => _showSaleDialog(context),
          ),
          // Botón para registrar gasto
          IconButton(
            icon: const Icon(Icons.money_off, color: Colors.red),
            tooltip: 'Registrar Gasto',
            onPressed: () => _showExpenseDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen financiero principal
            Card(
              color: netProfit >= 0
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Ganancia Neta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(netProfit),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: netProfit >= 0
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resumen de ingresos y gastos
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'Ventas',
                    totalRevenue,
                    currencyFormat,
                    Icons.trending_up,
                    Colors.blue.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinancialCard(
                    'Costos',
                    totalCosts,
                    currencyFormat,
                    Icons.build,
                    Colors.orange.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'Gastos',
                    totalExpenses,
                    currencyFormat,
                    Icons.money_off,
                    Colors.red.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComponentCard(
                    'Impresoras',
                    printerProvider.printers.length,
                    Icons.print,
                    Colors.purple.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ventas recientes
            if (saleProvider.sales.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ventas Recientes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => _showAllSales(context),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: saleProvider.sales.take(3).length,
                itemBuilder: (context, index) {
                  final sale = saleProvider.sales[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.sell, color: Colors.white),
                      ),
                      title: Text(sale.description),
                      subtitle: Text(
                        'Ganancia: ${currencyFormat.format(sale.netProfit)} | ${DateFormat.yMd('es_ES').format(sale.date)}',
                      ),
                      trailing: Text(
                        currencyFormat.format(sale.salePrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Gastos recientes
            if (expenseProvider.expenses.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastos Recientes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => _showAllExpenses(context),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenseProvider.expenses.take(3).length,
                itemBuilder: (context, index) {
                  final expense = expenseProvider.expenses[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.money_off, color: Colors.white),
                      ),
                      title: Text(expense.description),
                      subtitle: Text(
                        '${expense.category} | ${DateFormat.yMd('es_ES').format(expense.date)}',
                      ),
                      trailing: Text(
                        currencyFormat.format(expense.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            // Mensaje si no hay datos
            if (saleProvider.sales.isEmpty &&
                expenseProvider.expenses.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay transacciones registradas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa los botones de arriba para registrar ventas o gastos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'sale',
            backgroundColor: Colors.green,
            onPressed: () => _showSaleDialog(context),
            child: const Icon(Icons.sell),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'expense',
            backgroundColor: Colors.red,
            onPressed: () => _showExpenseDialog(context),
            child: const Icon(Icons.money_off),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    double amount,
    NumberFormat format,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              format.format(amount),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const SaleDialog(),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const ExpenseDialog(),
    );
  }

  void _showAllSales(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SalesListScreen()));
  }

  void _showAllExpenses(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ExpensesListScreen()));
  }
}
