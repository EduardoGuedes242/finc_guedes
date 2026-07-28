import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/datas.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/categoria_avatar.dart';
import '../../../core/widgets/valor_texto.dart';
import '../../../models/recorrencia_com_categoria.dart';

enum AcaoRecorrencia { editar, alternarAtivo, excluir }

/// Item de lista de conta recorrente.
class RecorrenciaTile extends StatelessWidget {
  const RecorrenciaTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAcao,
  });

  final RecorrenciaComCategoria item;
  final VoidCallback onTap;
  final ValueChanged<AcaoRecorrencia> onAcao;

  @override
  Widget build(BuildContext context) {
    final r = item.recorrencia;
    final bool ativo = r.ativo;
    final Color corValor = ativo ? AppColors.doTipo(r.tipo) : AppColors.textoLeve;

    return Opacity(
      opacity: ativo ? 1 : 0.65,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CategoriaAvatar(cor: item.categoriaCor, icone: item.categoriaIcone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          r.descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.texto,
                          ),
                        ),
                      ),
                      if (!ativo) ...[
                        const SizedBox(width: 8),
                        const _ChipInativa(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.categoriaNome}  •  Todo dia ${r.diaVencimento}'
                    '${r.dataFim != null ? '  •  até ${Datas.curta(r.dataFim!)}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textoSuave,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValorTexto(r.valorPrevisto, cor: corValor, tamanho: 15),
                const Text(
                  '/mês',
                  style: TextStyle(fontSize: 11, color: AppColors.textoLeve),
                ),
              ],
            ),
            PopupMenuButton<AcaoRecorrencia>(
              icon:
                  const Icon(Icons.more_vert_rounded, color: AppColors.textoLeve),
              onSelected: onAcao,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AcaoRecorrencia.editar,
                  child: _Item(icone: Icons.edit_rounded, texto: 'Editar'),
                ),
                PopupMenuItem(
                  value: AcaoRecorrencia.alternarAtivo,
                  child: _Item(
                    icone: ativo
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    texto: ativo ? 'Pausar' : 'Reativar',
                  ),
                ),
                const PopupMenuItem(
                  value: AcaoRecorrencia.excluir,
                  child: _Item(
                    icone: Icons.delete_outline_rounded,
                    texto: 'Excluir',
                    cor: AppColors.despesa,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipInativa extends StatelessWidget {
  const _ChipInativa();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.superficieAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borda),
      ),
      child: const Text(
        'Pausada',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textoSuave,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icone, required this.texto, this.cor});

  final IconData icone;
  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 19, color: cor ?? AppColors.textoSuave),
        const SizedBox(width: 12),
        Text(texto, style: TextStyle(color: cor ?? AppColors.texto)),
      ],
    );
  }
}
