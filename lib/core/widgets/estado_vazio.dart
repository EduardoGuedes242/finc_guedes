import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estado vazio padronizado: ícone, título, mensagem e ação opcional.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.acao,
    this.compacto = false,
  });

  final IconData icone;
  final String titulo;
  final String? mensagem;
  final Widget? acao;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compacto ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compacto ? 64 : 84,
              height: compacto ? 64 : 84,
              decoration: BoxDecoration(
                color: AppColors.suave(AppColors.primary, 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: compacto ? 30 : 40,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: compacto ? 14 : 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.texto,
              ),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: 6),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: AppColors.textoSuave,
                ),
              ),
            ],
            if (acao != null) ...[
              const SizedBox(height: 20),
              acao!,
            ],
          ],
        ),
      ),
    );
  }
}
