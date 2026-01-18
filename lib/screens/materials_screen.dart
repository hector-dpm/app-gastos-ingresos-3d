import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/material_provider.dart';
import '../models/material_model.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materiales')),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.materials.isEmpty) {
            return const Center(child: Text('No hay materiales registrados.'));
          }
          return ListView.builder(
            itemCount: provider.materials.length,
            itemBuilder: (context, index) {
              final material = provider.materials[index];
              return ListTile(
                leading: Icon(
                  Icons.inventory_2,
                  color: _getColor(material.color),
                ),
                title: Text('${material.name} (${material.type})'),
                subtitle: Text(
                  'Peso: ${material.weightG}g\nColor: ${material.color}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${material.cost.toStringAsFixed(2)} €'),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showMaterialDialog(context, material),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, provider, material.id!),
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
        onPressed: () => _showMaterialDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getColor(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('rojo')) return Colors.red;
    if (name.contains('azul')) return Colors.blue;
    if (name.contains('verde')) return Colors.green;
    if (name.contains('negro')) return Colors.black;
    if (name.contains('blanco')) {
      return Colors.grey;
    }
    return Colors.grey;
  }

  void _confirmDelete(BuildContext context, MaterialProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: const Text('¿Estás seguro?'),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showMaterialDialog(BuildContext context, MaterialModel? material) {
    showDialog(
      context: context,
      builder: (ctx) => MaterialDialog(material: material),
    );
  }
}

class MaterialDialog extends StatefulWidget {
  final MaterialModel? material;

  const MaterialDialog({super.key, this.material});

  @override
  State<MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<MaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _colorController;
  late TextEditingController _weightController;
  late TextEditingController _costController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _typeController = TextEditingController(
      text: widget.material?.type ?? 'PLA',
    );
    _colorController = TextEditingController(
      text: widget.material?.color ?? '',
    );
    _weightController = TextEditingController(
      text: widget.material?.weightG.toString() ?? '1000',
    );
    _costController = TextEditingController(
      text: widget.material?.cost.toString() ?? '',
    );
    _selectedDate = widget.material?.purchaseDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.material == null ? 'Nuevo Material' : 'Editar Material',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre (ej. Marca)',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (PLA, PETG...)',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (g)'),
                keyboardType: TextInputType.number,
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
              final material = MaterialModel(
                id: widget.material?.id,
                name: _nameController.text,
                type: _typeController.text,
                color: _colorController.text,
                weightG: double.tryParse(_weightController.text) ?? 0.0,
                cost: double.tryParse(_costController.text) ?? 0.0,
                purchaseDate: _selectedDate,
              );

              final provider = Provider.of<MaterialProvider>(
                context,
                listen: false,
              );
              if (widget.material == null) {
                provider.addMaterial(material);
              } else {
                provider.updateMaterial(material);
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
