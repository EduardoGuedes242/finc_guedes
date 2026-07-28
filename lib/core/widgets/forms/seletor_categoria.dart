import 'package:flutter/material.dart';

import '../../../models/categoria.dart';
import '../../theme/app_colors.dart';
import '../categoria_avatar.dart';
import 'campo_form.dart';

/// Seletor de categoria: exibe a categoria escolhida e abre um bottom sheet
/// com as opções disponíveis (já filtradas pelo tipo do lançamento).
class SeletorCategoria extends StatelessWidget {
  const SeletorCategoria({
    super.key,
    required this.rotulo,
    required this.categorias,
    required this.selecionada,
    required this.onSelecionar,
    this.obrigatorio = true,
    this.erro,
  });

  final String rotulo;
  final List<Categoria> categorias;
  final Categoria? selecionada;
  final ValueChanged<Categoria> onSelecionar;
  final bool obrigatorio;
  final String? erro;

  Future<void> _abrir(BuildContext context) async {
    if (categorias.isEmpty) return;
    final Categoria? escolhida = await showModalBottomSheet<Categoria>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ListaCategorias(
        categorias: categorias,
        selecionada: selecionada,
      ),
    );
    if (escolhida != null) onSelecionar(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final Categoria? cat = selecionada;
    final bool vazio = categorias.isEmpty;

    return CampoRotulado(
      rotulo: rotulo,
      obrigatorio: obrigatorio,
      campo: CaixaCampo(
        erro: erro,
        onTap: () => _abrir(context),
        child: Row(
          children: [
            if (cat != null)
              CategoriaAvatar(cor: cat.cor, icone: cat.icone, tamanho: 34)
            else
              Icon(
                vazio ? Icons.error_outline_rounded : Icons.category_rounded,
                size: 22,
                color: AppColors.textoSuave,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cat?.nome ??
                    (vazio
                        ? 'Nenhuma categoria — cadastre primeiro'
                        : 'Selecione a categoria'),
                style: TextStyle(
                  fontSize: 15,
                  color: cat != null ? AppColors.texto : AppColors.textoLeve,
                  fontWeight:
                      cat != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (!vazio)
              const Icon(Icons.expand_more_rounded,
                  color: AppColors.textoSuave),
          ],
        ),
      ),
    );
  }
}

class _ListaCategorias extends StatelessWidget {
  const _ListaCategorias({required this.categorias, required this.selecionada});

  final List<Categoria> categorias;
  final Categoria? selecionada;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borda,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecione a categoria',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categorias.length,
                separatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, i) {
                  final Categoria cat = categorias[i];
                  final bool sel = cat.id == selecionada?.id;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    leading: CategoriaAvatar(
                        cor: cat.cor, icone: cat.icone, tamanho: 40),
                    title: Text(
                      cat.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: sel
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
