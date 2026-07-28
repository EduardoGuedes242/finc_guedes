import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/categorias/controllers/categorias_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/movimentos/controllers/movimentos_controller.dart';
import 'features/recorrencias/controllers/recorrencias_controller.dart';
import 'features/shell/home_shell.dart';

/// Raiz do aplicativo: registra os controllers (Notifiers) e configura o
/// [MaterialApp] com tema, localização pt-BR e a tela inicial.
class FincGuedesApp extends StatelessWidget {
  const FincGuedesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => MovimentosController()),
        ChangeNotifierProvider(create: (_) => CategoriasController()),
        ChangeNotifierProvider(create: (_) => RecorrenciasController()),
      ],
      child: MaterialApp(
        title: 'Finc Guedes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}
