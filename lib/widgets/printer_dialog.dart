import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/printer_provider.dart';
import '../models/printer_model.dart';

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
  late TextEditingController _powerController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer?.name ?? '');
    _modelController = TextEditingController(text: widget.printer?.model ?? '');
    _costController = TextEditingController(
      text: widget.printer?.cost.toString() ?? '',
    );
    _powerController = TextEditingController(
      text: widget.printer?.powerWatts.toString() ?? '300',
    );
    _selectedDate = widget.printer?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _costController.dispose();
    _powerController.dispose();
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
              Text(
                widget.printer == null ? 'Nueva Impresora' : 'Editar Impresora',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.print),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El modelo es requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Costo (€)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Requerido';
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _powerController,
                      decoration: const InputDecoration(
                        labelText: 'Consumo (W)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bolt),
                        helperText: 'Default: 300W',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Requerido';
                        if (int.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Fecha de compra: ${DateFormat.yMd('es_ES').format(_selectedDate)}',
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
                    final printer = Printer(
                      id: widget.printer?.id,
                      name: _nameController.text,
                      model: _modelController.text,
                      cost: double.parse(_costController.text),
                      purchaseDate: _selectedDate,
                      printCount: widget.printer?.printCount ?? 0,
                      powerWatts: int.parse(_powerController.text),
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
                child: Text(widget.printer == null ? 'Guardar' : 'Actualizar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
