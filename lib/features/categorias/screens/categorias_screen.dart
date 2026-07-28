import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../models/categoria.dart';
import '../../../models/enums.dart';
import '../controllers/categorias_controller.dart';
import '../widgets/categoria_tile.dart';
import 'categoria_form_screen.dart';

/// Tela de categorias, separadas por tipo em duas abas (Receitas e Despesas).
class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  Future<void> _abrirForm(
    BuildContext context, {
    Categoria? categoria,
    TipoLancamento? tipoInicial,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriaFormScreen(
          categoria: categoria,
          tipoInicial: tipoInicial,
        ),
      ),
    );
  }

  Future<void> _executarAcao(
    BuildContext context,
    AcaoCategoria acao,
    Categoria categoria,
  ) async {
    final controller = context.read<CategoriasController>();
    switch (acao) {
      case AcaoCategoria.editar:
        await _abrirForm(context, categoria: categoria);
      case AcaoCategoria.alternarAtivo:
        await controller.alternarAtivo(categoria);
      case AcaoCategoria.excluir:
        final bool ok = await controller.excluir(categoria.id!);
        if (!context.mounted) return;
        if (!ok) {
          AppFeedback.erro(
            context,
            controller.erro ?? 'Não foi possível excluir.',
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoriasController>();

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Categorias'),
            bottom: const TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textoSuave,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                Tab(text: 'Receitas'),
                Tab(text: 'Despesas'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final int index = DefaultTabController.of(context).index;
              _abrirForm(
                context,
                tipoInicial: index == 0
                    ? TipoLancamento.receita
                    : TipoLancamento.despesa,
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova'),
          ),
          body: controller.carregando && controller.itens.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _ListaCategorias(
                      categorias: controller.receitas,
                      tipo: TipoLancamento.receita,
                      onTapItem: (c) => _abrirForm(context, categoria: c),
                      onAcao: (acao, c) => _executarAcao(context, acao, c),
                    ),
                    _ListaCategorias(
                      categorias: controller.despesas,
                      tipo: TipoLancamento.despesa,
                      onTapItem: (c) => _abrirForm(context, categoria: c),
                      onAcao: (acao, c) => _executarAcao(context, acao, c),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ListaCategorias extends StatelessWidget {
  const _ListaCategorias({
    required this.categorias,
    required this.tipo,
    required this.onTapItem,
    required this.onAcao,
  });

  final List<Categoria> categorias;
  final TipoLancamento tipo;
  final ValueChanged<Categoria> onTapItem;
  final void Function(AcaoCategoria, Categoria) onAcao;

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return EstadoVazio(
        icone: Icons.category_rounded,
        titulo: tipo.isReceita
            ? 'Nenhuma categoria de receita'
            : 'Nenhuma categoria de despesa',
        mensagem: 'Toque em "Nova" para criar uma categoria.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: categorias.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return CategoriaTile(
          categoria: categoria,
          onTap: () => onTapItem(categoria),
          onAcao: (acao) => onAcao(acao, categoria),
        );
      },
    );
  }
}
