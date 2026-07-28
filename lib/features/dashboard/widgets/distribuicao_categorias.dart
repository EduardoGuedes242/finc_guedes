import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/categoria_visual.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/valor_texto.dart';
import '../../../models/total_categoria.dart';

/// Lista as principais categorias de despesa do período com barras
/// proporcionais ao maior valor.
class DistribuicaoCategorias extends StatelessWidget {
  const DistribuicaoCategorias({
    super.key,
    required this.itens,
    this.limite = 5,
  });

  final List<TotalCategoria> itens;
  final int limite;

  @override
  Widget build(BuildContext context) {
    final visiveis = itens.take(limite).toList();
    final int maior = visiveis.isEmpty
        ? 0
        : visiveis.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final int totalGeral =
        itens.fold<int>(0, (soma, e) => soma + e.total);

    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < visiveis.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _LinhaCategoria(
              item: visiveis[i],
              proporcao: maior == 0 ? 0 : visiveis[i].total / maior,
              percentual: totalGeral == 0 ? 0 : visiveis[i].total / totalGeral,
            ),
          ],
        ],
      ),
    );
  }
}

class _LinhaCategoria extends StatelessWidget {
  const _LinhaCategoria({
    required this.item,
    required this.proporcao,
    required this.percentual,
  });

  final TotalCategoria item;
  final double proporcao;
  final double percentual;

  @override
  Widget build(BuildContext context) {
    final Color cor = CategoriaVisual.cor(item.cor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CategoriaVisual.icone(item.icone), size: 16, color: cor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValorTexto(item.total, cor: AppColors.texto, tamanho: 13.5),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: proporcao.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: AppColors.superficieAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(cor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 38,
              child: Text(
                '${(percentual * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoSuave,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
