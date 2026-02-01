import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';
import '../providers/printer_provider.dart';
import '../providers/material_provider.dart';
import '../models/sale_model.dart';
import '../models/printer_model.dart';

class SaleDialog extends StatefulWidget {
  final SaleModel? sale;

  const SaleDialog({super.key, this.sale});

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _salePriceController;
  late TextEditingController _weightUsedController;

  // Nuevos controladores de tiempo y electricidad
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _kwhPriceController;
  late TextEditingController _otherCostsController;

  int? _selectedPrinterId;
  int? _selectedMaterialId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.sale?.description ?? '',
    );
    _salePriceController = TextEditingController(
      text: widget.sale?.salePrice.toString() ?? '',
    );
    _weightUsedController = TextEditingController(
      text: widget.sale?.weightUsedG.toString() ?? '',
    );

    // Convertir horas decimales a horas y minutos
    double totalHours = widget.sale?.printTimeHours ?? 0.0;
    int hours = totalHours.floor();
    int minutes = ((totalHours - hours) * 60).round();

    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
    _kwhPriceController = TextEditingController(
      text: widget.sale?.kwhPrice.toString() ?? '0.15',
    ); // Precio promedio
    _otherCostsController = TextEditingController(
      text: widget.sale?.otherCosts.toString() ?? '0.0',
    );

    _selectedPrinterId = widget.sale?.printerId;
    _selectedMaterialId = widget.sale?.materialId;
    _selectedDate = widget.sale?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _salePriceController.dispose();
    _weightUsedController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _kwhPriceController.dispose();
    _otherCostsController.dispose();
    super.dispose();
  }

  // Calcular costo de electricidad basado en potencia de impresora y tiempo
  double _calculateElectricityCost(Printer? printer) {
    if (printer == null) return 0.0;

    final hours = double.tryParse(_hoursController.text) ?? 0.0;
    final minutes = double.tryParse(_minutesController.text) ?? 0.0;
    final totalHours = hours + (minutes / 60.0);

    final kwhPrice = double.tryParse(_kwhPriceController.text) ?? 0.0;
    final powerKw = printer.powerWatts / 1000.0;

    return powerKw * totalHours * kwhPrice;
  }

  double _calculateTotalCost() {
    double total = 0.0;

    // Costo Material
    final materialProvider = Provider.of<MaterialProvider>(
      context,
      listen: false,
    );
    if (_selectedMaterialId != null && _weightUsedController.text.isNotEmpty) {
      final material = materialProvider.materials.firstWhere(
        (m) => m.id == _selectedMaterialId,
      );
      final weightUsed = double.tryParse(_weightUsedController.text) ?? 0.0;
      final costPerG = material.cost / material.weightG;
      total += weightUsed * costPerG;
    }

    // Costo Electricidad
    final printerProvider = Provider.of<PrinterProvider>(
      context,
      listen: false,
    );
    if (_selectedPrinterId != null) {
      final printer = printerProvider.printers.firstWhere(
        (p) => p.id == _selectedPrinterId,
      );
      total += _calculateElectricityCost(printer);
    }

    // Otros Costos
    total += double.tryParse(_otherCostsController.text) ?? 0.0;

    return total;
  }

  double _calculateProfit() {
    final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    final cost = _calculateTotalCost();
    return salePrice - cost;
  }

  @override
  Widget build(BuildContext context) {
    final printerProvider = Provider.of<PrinterProvider>(context);
    final materialProvider = Provider.of<MaterialProvider>(context);

    // Obtener impresora seleccionada para mostrar info de consumo
    Printer? selectedPrinter;
    if (_selectedPrinterId != null) {
      try {
        selectedPrinter = printerProvider.printers.firstWhere(
          (p) => p.id == _selectedPrinterId,
        );
      } catch (e) {
        // Ignorar si no se encuentra
      }
    }

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
                  const Icon(Icons.sell, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    widget.sale == null ? 'Registrar Venta' : 'Editar Venta',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la pieza',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Precio de venta
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Venta (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value!.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Impresora
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Impresora Utilizada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.print),
                ),
                value: _selectedPrinterId,
                items: printerProvider.printers.map((printer) {
                  return DropdownMenuItem(
                    value: printer.id,
                    child: Text('${printer.name} (${printer.powerWatts}W)'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPrinterId = val),
                validator: (value) =>
                    value == null ? 'Selecciona una impresora' : null,
              ),

              if (selectedPrinter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, bottom: 8),
                  child: Text(
                    'Consumo: ${selectedPrinter.powerWatts} Watts | Impresiones: ${selectedPrinter.printCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),

              const SizedBox(height: 4),

              // Tiempo de impresión
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Horas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Precio kWh (Electricidad)
              TextFormField(
                controller: _kwhPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio kWh (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.electric_bolt),
                  helperText: 'Costo eléctrico calculado automáticamente',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Material
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Material Usado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                value: _selectedMaterialId,
                items: materialProvider.materials.map((material) {
                  return DropdownMenuItem(
                    value: material.id,
                    child: Text(
                      '${material.name} (${material.weightG.toStringAsFixed(0)}g)',
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMaterialId = val),
                validator: (value) =>
                    value == null ? 'Selecciona un material' : null,
              ),
              const SizedBox(height: 12),

              // Peso usado
              TextFormField(
                controller: _weightUsedController,
                decoration: const InputDecoration(
                  labelText: 'Peso Usado (gramos)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value!.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Otros costos
              TextFormField(
                controller: _otherCostsController,
                decoration: const InputDecoration(
                  labelText: 'Otros Costos (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                  helperText: 'Ej: laca, fallos, post-procesado',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Resumen de cálculos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de Costos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedPrinter != null)
                      _buildCostRow(
                        'Electricidad (${_calculateElectricityCost(selectedPrinter).toStringAsFixed(3)} kWh):',
                        _calculateElectricityCost(selectedPrinter),
                      ),
                    _buildCostRow(
                      'Material:',
                      _calculateMaterialCost(materialProvider),
                    ),
                    _buildCostRow(
                      'Otros:',
                      double.tryParse(_otherCostsController.text) ?? 0.0,
                    ),
                    const Divider(),
                    _buildCostRow(
                      'Costo Total:',
                      _calculateTotalCost(),
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ganancia Neta:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_calculateProfit().toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _calculateProfit() >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveSale(context, selectedPrinter, materialProvider);
                  }
                },
                child: Text(
                  widget.sale == null ? 'Registrar Venta' : 'Actualizar Venta',
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

  double _calculateMaterialCost(MaterialProvider provider) {
    if (_selectedMaterialId == null || _weightUsedController.text.isEmpty)
      return 0.0;
    try {
      final material = provider.materials.firstWhere(
        (m) => m.id == _selectedMaterialId,
      );
      final weight = double.tryParse(_weightUsedController.text) ?? 0.0;
      return weight * (material.cost / material.weightG);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildCostRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} €',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSale(
    BuildContext context,
    Printer? printer,
    MaterialProvider materialProvider,
  ) {
    // Calcular valores finales
    final material = materialProvider.materials.firstWhere(
      (m) => m.id == _selectedMaterialId,
    );
    final weightUsed = double.parse(_weightUsedController.text);
    final costPerG = material.cost / material.weightG;

    final hours = double.tryParse(_hoursController.text) ?? 0.0;
    final minutes = double.tryParse(_minutesController.text) ?? 0.0;
    final totalHours = hours + (minutes / 60.0);

    final electricityCost = _calculateElectricityCost(printer);
    final otherCosts = double.tryParse(_otherCostsController.text) ?? 0.0;
    final kwhPrice = double.tryParse(_kwhPriceController.text) ?? 0.0;

    final sale = SaleModel(
      id: widget.sale?.id, // Importante para actualizar
      description: _descriptionController.text,
      salePrice: double.parse(_salePriceController.text),
      weightUsedG: weightUsed,
      printerId: _selectedPrinterId!,
      materialId: _selectedMaterialId!,
      materialCostPerG: costPerG,
      electricityCost: electricityCost,
      date: _selectedDate,
      printTimeHours: totalHours,
      kwhPrice: kwhPrice,
      otherCosts: otherCosts,
    );

    final saleProvider = Provider.of<SaleProvider>(context, listen: false);

    if (widget.sale == null) {
      saleProvider.addSale(sale);
    } else {
      saleProvider.updateSale(sale);
    }

    // Recargar datos
    Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
    Provider.of<PrinterProvider>(context, listen: false).loadPrinters();

    Navigator.of(context).pop();
  }
}
