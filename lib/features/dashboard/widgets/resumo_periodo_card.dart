import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/valor_texto.dart';

/// Cartão de resumo de um tipo (receitas ou despesas) no período: valor
/// efetivado em destaque, previsto e barra de progresso.
class ResumoPeriodoCard extends StatelessWidget {
  const ResumoPeriodoCard({
    super.key,
    required this.rotulo,
    required this.efetivado,
    required this.previsto,
    required this.progresso,
    required this.cor,
    required this.icone,
  });

  final String rotulo;
  final int efetivado;
  final int previsto;
  final double progresso;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.suave(cor, 0.13),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icone, size: 16, color: cor),
              ),
              const SizedBox(width: 8),
              Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoSuave,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValorTexto(efetivado, cor: cor, tamanho: 18),
          const SizedBox(height: 3),
          Text(
            'de ${_curto(previsto)} previsto',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textoLeve),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.suave(cor, 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(cor),
            ),
          ),
        ],
      ),
    );
  }

  String _curto(int centavos) {
    final double reais = centavos / 100;
    if (reais >= 1000) {
      return 'R\$ ${(reais / 1000).toStringAsFixed(reais >= 10000 ? 0 : 1)}k';
    }
    return 'R\$ ${reais.toStringAsFixed(0)}';
  }
}
