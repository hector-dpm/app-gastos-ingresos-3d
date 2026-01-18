import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/printer_provider.dart';
import '../models/printer_model.dart';

class PrintersScreen extends StatelessWidget {
  const PrintersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresoras')),
      body: Consumer<PrinterProvider>(
        builder: (context, provider, child) {
          if (provider.printers.isEmpty) {
            return const Center(child: Text('No hay impresoras registradas.'));
          }
          return ListView.builder(
            itemCount: provider.printers.length,
            itemBuilder: (context, index) {
              final printer = provider.printers[index];
              return ListTile(
                leading: const Icon(Icons.print),
                title: Text(printer.name),
                subtitle: Text(
                  '${printer.model}\nComprada: ${DateFormat.yMMMd('es_ES').format(printer.purchaseDate)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${printer.cost.toStringAsFixed(2)} €'),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showPrinterDialog(context, printer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, provider, printer.id!),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPrinterDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PrinterProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Impresora'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePrinter(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog(BuildContext context, Printer? printer) {
    showDialog(
      context: context,
      builder: (ctx) => PrinterDialog(printer: printer),
    );
  }
}

class PrinterDialog extends StatefulWidget {
  final Printer? printer;

  const PrinterDialog({super.key, this.printer});

  @override
  State<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _modelController;
  late TextEditingController _costController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer?.name ?? '');
    _modelController = TextEditingController(text: widget.printer?.model ?? '');
    _costController = TextEditingController(
      text: widget.printer?.cost.toString() ?? '',
    );
    _selectedDate = widget.printer?.purchaseDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.printer == null ? 'Nueva Impresora' : 'Editar Impresora',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Costo (€)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final printer = Printer(
                id: widget.printer?.id,
                name: _nameController.text,
                model: _modelController.text,
                cost: double.tryParse(_costController.text) ?? 0.0,
                purchaseDate: _selectedDate,
              );

              final provider = Provider.of<PrinterProvider>(
                context,
                listen: false,
              );
              if (widget.printer == null) {
                provider.addPrinter(printer);
              } else {
                provider.updatePrinter(printer);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
