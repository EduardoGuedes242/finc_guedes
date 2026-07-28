import 'package:flutter/material.dart';

import 'app.dart';
import 'services/recorrencia_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Garante a criação/abertura do banco e gera os movimentos das recorrências
  // devidos até o mês atual antes de iniciar a interface.
  try {
    await RecorrenciaService().gerarPendentes();
  } catch (_) {
    // Falha na geração não deve impedir a abertura do app; a tela inicial
    // exibirá os dados existentes normalmente.
  }

  runApp(const FincGuedesApp());
}
