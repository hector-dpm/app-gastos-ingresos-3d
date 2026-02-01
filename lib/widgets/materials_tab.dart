import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/material_provider.dart';
import '../models/material_model.dart';
import 'material_dialog.dart';

class MaterialsTab extends StatelessWidget {
  const MaterialsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.materials.isEmpty) {
            return const Center(child: Text('No hay materiales registrados.'));
          }
          return ListView.builder(
            itemCount: provider.materials.length,
            itemBuilder: (context, index) {
              final material = provider.materials[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.inventory_2, color: Colors.white),
                  ),
                  title: Text(
                    material.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${material.type} | Color: ${material.color}'),
                      Text('Peso: ${material.weightG.toStringAsFixed(0)}g'),
                      Text('Costo: ${material.cost.toStringAsFixed(2)} €'),
                      Text(
                        'Compra: ${DateFormat.yMd('es_ES').format(material.purchaseDate)}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showMaterialDialog(context, material),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteMaterial(
                          context,
                          provider,
                          material.id!,
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
        onPressed: () => _showMaterialDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDeleteMaterial(
    BuildContext context,
    MaterialProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: const Text('¿Estás seguro de eliminar este material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMaterial(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMaterialDialog(BuildContext context, MaterialModel? material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MaterialDialog(material: material),
    );
  }
}
