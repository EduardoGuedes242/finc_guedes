import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Linha com título/descrição e um [Switch], no estilo dos campos do app.
class CampoSwitch extends StatelessWidget {
  const CampoSwitch({
    super.key,
    required this.titulo,
    required this.valor,
    required this.onChanged,
    this.subtitulo,
    this.icone,
    this.cor,
  });

  final String titulo;
  final String? subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;
  final IconData? icone;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final Color destaque = cor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          if (icone != null) ...[
            Icon(icone, size: 20, color: destaque),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoSuave,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: valor,
            activeThumbColor: destaque,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
