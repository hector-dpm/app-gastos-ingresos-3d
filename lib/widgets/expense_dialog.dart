import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class ExpenseDialog extends StatefulWidget {
  final ExpenseModel? expense;

  const ExpenseDialog({super.key, this.expense});

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _categories = [
    'Mantenimiento',
    'Herramientas',
    'Repuestos',
    'Servicios',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _selectedCategory = widget.expense?.category ?? 'Mantenimiento';
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  const Icon(Icons.money_off, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    widget.expense == null ? 'Registrar Gasto' : 'Editar Gasto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del gasto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'La descripción es requerida' : null,
              ),
              const SizedBox(height: 12),

              // Monto
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'El monto es requerido';
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Categoría
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              // Fecha
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat.yMd('es_ES').format(_selectedDate)}',
                    ),
                  ),
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

              // Botón guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final expense = ExpenseModel(
                      id: widget.expense?.id,
                      description: _descriptionController.text,
                      amount: double.parse(_amountController.text),
                      category: _selectedCategory,
                      date: _selectedDate,
                    );

                    final provider = Provider.of<ExpenseProvider>(
                      context,
                      listen: false,
                    );

                    if (widget.expense == null) {
                      provider.addExpense(expense);
                    } else {
                      provider.updateExpense(expense);
                    }

                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  widget.expense == null
                      ? 'Registrar Gasto'
                      : 'Actualizar Gasto',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
