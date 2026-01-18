import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final totals = transactionProvider.totals;
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(
              'Dinero Total',
              totals['net'] ?? 0.0,
              currencyFormat,
              isNet: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Ingresos',
                    totals['income'] ?? 0.0,
                    currencyFormat,
                    color: Colors.green.shade100,
                    textColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Gastos',
                    totals['expense'] ?? 0.0,
                    currencyFormat,
                    color: Colors.red.shade100,
                    textColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recientes:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            // Show only last 5 transactions
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactionProvider.transactions.take(5).length,
              itemBuilder: (context, index) {
                final tx = transactionProvider.transactions[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      tx.type == 'INGRESO'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: tx.type == 'INGRESO' ? Colors.green : Colors.red,
                    ),
                    title: Text(tx.description),
                    subtitle: Text(DateFormat.yMMMd('es_ES').format(tx.date)),
                    trailing: Text(
                      currencyFormat.format(tx.amount),
                      style: TextStyle(
                        color: tx.type == 'INGRESO' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    NumberFormat format, {
    Color? color,
    Color? textColor,
    bool isNet = false,
  }) {
    Color cardColor = color ?? Colors.white;
    Color txtColor = textColor ?? Colors.black;

    if (isNet) {
      cardColor = amount >= 0 ? Colors.blue.shade100 : Colors.orange.shade100;
      txtColor = Colors.black;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: txtColor)),
            const SizedBox(height: 8),
            Text(
              format.format(amount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
