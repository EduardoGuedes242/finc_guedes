import 'package:flutter/material.dart';

import '../../models/movimento.dart';
import '../theme/app_colors.dart';

/// Etiqueta compacta que indica a situação de um movimento
/// (Pendente, Atrasado, Efetivado ou Cancelado).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.texto,
    required this.cor,
    this.icone,
  });

  final String texto;
  final Color cor;
  final IconData? icone;

  /// Constrói o chip a partir do estado real do movimento (considerando atraso).
  factory StatusChip.doMovimento(Movimento movimento, {DateTime? referencia}) {
    if (movimento.status.isEfetivado) {
      final String rotulo = movimento.isReceita ? 'Recebido' : 'Pago';
      return StatusChip(
        texto: rotulo,
        cor: AppColors.receita,
        icone: Icons.check_circle_rounded,
      );
    }
    if (movimento.status.isCancelado) {
      return const StatusChip(
        texto: 'Cancelado',
        cor: AppColors.textoLeve,
        icone: Icons.block_rounded,
      );
    }
    if (movimento.estaAtrasado(referencia: referencia)) {
      return const StatusChip(
        texto: 'Atrasado',
        cor: AppColors.despesa,
        icone: Icons.error_rounded,
      );
    }
    return const StatusChip(
      texto: 'Pendente',
      cor: AppColors.alerta,
      icone: Icons.schedule_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.suave(cor, 0.13),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 12, color: cor),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
