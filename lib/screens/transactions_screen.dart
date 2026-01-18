// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/printer_provider.dart';
import '../providers/material_provider.dart';
import '../models/transaction_model.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(
              child: Text('No hay transacciones registradas.'),
            );
          }
          return ListView.builder(
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.type == 'INGRESO'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    tx.type == 'INGRESO'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: tx.type == 'INGRESO' ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx.description),
                subtitle: Text(DateFormat.yMMMd('es_ES').format(tx.date)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${tx.amount.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tx.type == 'INGRESO' ? Colors.green : Colors.red,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () =>
                          _confirmDelete(context, provider, tx.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TransactionProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Transacción'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const TransactionDialog(),
    );
  }
}

class TransactionDialog extends StatefulWidget {
  const TransactionDialog({super.key});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'GASTO'; // Default
  DateTime _selectedDate = DateTime.now();
  int? _selectedPrinterId;
  int? _selectedMaterialId;

  @override
  Widget build(BuildContext context) {
    final printerProvider = Provider.of<PrinterProvider>(
      context,
      listen: false,
    );
    final materialProvider = Provider.of<MaterialProvider>(
      context,
      listen: false,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nueva Transacción',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Gasto'),
                      value: 'GASTO',
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Ingreso'),
                      value: 'INGRESO',
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto (€)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Vincular Impresora (Opcional)',
                ),
                value: _selectedPrinterId,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Ninguna'),
                  ),
                  ...printerProvider.printers.map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedPrinterId = val),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Vincular Material (Opcional)',
                ),
                value: _selectedMaterialId,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Ninguno'),
                  ),
                  ...materialProvider.materials.map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedMaterialId = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Fecha: ${DateFormat.yMd('es_ES').format(_selectedDate)}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final tx = TransactionModel(
                      type: _type,
                      amount: double.tryParse(_amountController.text) ?? 0.0,
                      description: _descriptionController.text,
                      date: _selectedDate,
                      printerId: _selectedPrinterId,
                      materialId: _selectedMaterialId,
                    );

                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).addTransaction(tx);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
