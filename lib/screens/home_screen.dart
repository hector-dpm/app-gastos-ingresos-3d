import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'printers_screen.dart';
import 'materials_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    PrintersScreen(),
    MaterialsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            selectedIcon: Icon(
              Icons.dashboard,
              color: Color.fromARGB(255, 255, 77, 0),
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money, color: Color.fromARGB(255, 0, 0, 0)),
            selectedIcon: Icon(
              Icons.attach_money,
              color: Color.fromARGB(255, 255, 77, 0),
            ),
            label: 'Transacciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.print, color: Color.fromARGB(255, 0, 0, 0)),
            selectedIcon: Icon(
              Icons.print,
              color: Color.fromARGB(255, 255, 77, 0),
            ),
            label: 'Impresoras',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            selectedIcon: Icon(
              Icons.inventory_2,
              color: Color.fromARGB(255, 255, 77, 0),
            ),
            label: 'Materiales',
          ),
        ],
      ),
    );
  }
}
