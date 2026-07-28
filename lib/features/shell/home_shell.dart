import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../categorias/controllers/categorias_controller.dart';
import '../categorias/screens/categorias_screen.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../movimentos/controllers/movimentos_controller.dart';
import '../movimentos/screens/movimentos_screen.dart';
import '../recorrencias/controllers/recorrencias_controller.dart';
import '../recorrencias/screens/recorrencias_screen.dart';

/// Casca principal do app com navegação inferior entre as quatro áreas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    // Carrega os dados de cada área na inicialização.
    context.read<DashboardController>().carregar();
    context.read<MovimentosController>().carregar();
    context.read<CategoriasController>().carregar();
    context.read<RecorrenciasController>().carregar();
  }

  void _selecionar(int indice) {
    if (indice == _indice) return;
    setState(() => _indice = indice);
    _recarregarArea(indice);
  }

  /// Recarrega os dados da área selecionada para refletir alterações feitas em
  /// outras abas (novos lançamentos, recorrências geradas, etc.).
  void _recarregarArea(int indice) {
    switch (indice) {
      case 0:
        context.read<DashboardController>().carregar();
      case 1:
        context.read<MovimentosController>().carregar();
      case 2:
        context.read<RecorrenciasController>().carregar();
      case 3:
        context.read<CategoriasController>().carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final telas = <Widget>[
      DashboardScreen(onVerMovimentos: () => _selecionar(1)),
      const MovimentosScreen(),
      const RecorrenciasScreen(),
      const CategoriasScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _indice, children: telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _selecionar,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_outlined),
            selectedIcon: Icon(Icons.swap_vert_rounded),
            label: 'Movimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew_outlined),
            selectedIcon: Icon(Icons.autorenew_rounded),
            label: 'Recorrências',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}
