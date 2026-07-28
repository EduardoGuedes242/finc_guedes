import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cabeçalho de seção com título e, opcionalmente, uma ação à direita
/// (ex.: "Ver todos").
class SecaoTitulo extends StatelessWidget {
  const SecaoTitulo(
    this.titulo, {
    super.key,
    this.acaoTexto,
    this.onAcao,
    this.icone,
  });

  final String titulo;
  final String? acaoTexto;
  final VoidCallback? onAcao;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icone != null) ...[
          Icon(icone, size: 18, color: AppColors.textoSuave),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
        ),
        if (acaoTexto != null && onAcao != null)
          TextButton(
            onPressed: onAcao,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(acaoTexto!),
          ),
      ],
    );
  }
}
