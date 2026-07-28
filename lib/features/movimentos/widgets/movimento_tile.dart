import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/datas.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/categoria_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/valor_texto.dart';
import '../../../models/movimento_com_categoria.dart';

/// Item de lista que representa um movimento com os dados da sua categoria.
class MovimentoTile extends StatelessWidget {
  const MovimentoTile({
    super.key,
    required this.item,
    this.onTap,
    this.trailing,
  });

  final MovimentoComCategoria item;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final movimento = item.movimento;
    final bool atrasado = movimento.estaAtrasado();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          CategoriaAvatar(
            cor: item.categoriaCor,
            icone: item.categoriaIcone,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimento.descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.categoriaNome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textoSuave,
                        ),
                      ),
                    ),
                    const Text('  •  ',
                        style: TextStyle(color: AppColors.textoLeve)),
                    Text(
                      Datas.relativa(movimento.dataVencimento),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: atrasado ? AppColors.despesa : AppColors.textoSuave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ValorTexto(
                movimento.valorEfetivo,
                tipo: movimento.tipo,
                comSinal: true,
                tamanho: 15,
              ),
              const SizedBox(height: 5),
              StatusChip.doMovimento(movimento),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
