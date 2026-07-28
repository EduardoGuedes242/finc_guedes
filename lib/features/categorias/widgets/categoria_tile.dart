import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/categoria_avatar.dart';
import '../../../models/categoria.dart';

enum AcaoCategoria { editar, alternarAtivo, excluir }

/// Item de lista de categoria com menu de ações.
class CategoriaTile extends StatelessWidget {
  const CategoriaTile({
    super.key,
    required this.categoria,
    required this.onTap,
    required this.onAcao,
  });

  final Categoria categoria;
  final VoidCallback onTap;
  final ValueChanged<AcaoCategoria> onAcao;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CategoriaAvatar(cor: categoria.cor, icone: categoria.icone),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    categoria.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: categoria.ativo
                          ? AppColors.texto
                          : AppColors.textoLeve,
                    ),
                  ),
                ),
                if (!categoria.ativo) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.superficieAlt,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borda),
                    ),
                    child: const Text(
                      'Inativa',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoSuave,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<AcaoCategoria>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textoLeve),
            onSelected: onAcao,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AcaoCategoria.editar,
                child: _Item(icone: Icons.edit_rounded, texto: 'Editar'),
              ),
              PopupMenuItem(
                value: AcaoCategoria.alternarAtivo,
                child: _Item(
                  icone: categoria.ativo
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  texto: categoria.ativo ? 'Desativar' : 'Ativar',
                ),
              ),
              const PopupMenuItem(
                value: AcaoCategoria.excluir,
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
