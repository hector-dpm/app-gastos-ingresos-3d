// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../widgets/printers_tab.dart';
import '../widgets/materials_tab.dart';

class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Componentes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.print), text: 'Impresoras'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Materiales'),
            ],
          ),
        ),
        body: const TabBarView(children: [PrintersTab(), MaterialsTab()]),
      ),
    );
  }
}
