import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/printer_provider.dart';
import '../models/printer_model.dart';
import 'printer_dialog.dart';

class PrintersTab extends StatelessWidget {
  const PrintersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PrinterProvider>(
        builder: (context, provider, child) {
          if (provider.printers.isEmpty) {
            return const Center(child: Text('No hay impresoras registradas.'));
          }
          return ListView.builder(
            itemCount: provider.printers.length,
            itemBuilder: (context, index) {
              final printer = provider.printers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.print, color: Colors.white),
                  ),
                  title: Text(
                    printer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modelo: ${printer.model}'),
                      Text('Costo: ${printer.cost.toStringAsFixed(2)} €'),
                      Text(
                        'Compra: ${DateFormat.yMd('es_ES').format(printer.purchaseDate)}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showPrinterDialog(context, printer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeletePrinter(
                          context,
                          provider,
                          printer.id!,
                        ),
                      ),
                    ],
                  ),
                ),
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

  void _confirmDeletePrinter(
    BuildContext context,
    PrinterProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Impresora'),
        content: const Text('¿Estás seguro de eliminar esta impresora?'),
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
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog(BuildContext context, Printer? printer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PrinterDialog(printer: printer),
    );
  }
}
