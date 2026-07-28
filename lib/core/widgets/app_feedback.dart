import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Utilidades de feedback ao usuário: mensagens (snackbar) e diálogos de
/// confirmação, padronizando a aparência em todo o app.
class AppFeedback {
  const AppFeedback._();

  static void sucesso(BuildContext context, String mensagem) =>
      _mostrar(context, mensagem, AppColors.receita, Icons.check_circle_rounded);

  static void erro(BuildContext context, String mensagem) =>
      _mostrar(context, mensagem, AppColors.despesa, Icons.error_rounded);

  static void info(BuildContext context, String mensagem) =>
      _mostrar(context, mensagem, AppColors.primary, Icons.info_rounded);

  static void _mostrar(
    BuildContext context,
    String mensagem,
    Color cor,
    IconData icone,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(mensagem)),
            ],
          ),
        ),
      );
  }

  /// Diálogo de confirmação genérico. Retorna `true` quando confirmado.
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    bool destrutivo = false,
  }) async {
    final Color corAcao = destrutivo ? AppColors.despesa : AppColors.primary;
    final bool? resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          mensagem,
          style: const TextStyle(
            color: AppColors.textoSuave,
            height: 1.4,
            fontSize: 14.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textoSuave),
            child: Text(textoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: corAcao,
              foregroundColor: Colors.white,
            ),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}
