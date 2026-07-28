import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/seletor_periodo.dart';
import '../../../core/widgets/valor_texto.dart';
import '../../../models/enums.dart';
import '../../../models/movimento_com_categoria.dart';
import '../controllers/movimentos_controller.dart';
import '../widgets/efetivar_sheet.dart';
import '../widgets/movimento_tile.dart';
import 'movimento_form_screen.dart';

enum _AcaoMovimento { efetivar, reabrir, editar, excluir }

/// Tela de listagem de movimentos com filtros por período, tipo, status e texto.
class MovimentosScreen extends StatefulWidget {
  const MovimentosScreen({super.key});

  @override
  State<MovimentosScreen> createState() => _MovimentosScreenState();
}

class _MovimentosScreenState extends State<MovimentosScreen> {
  final _buscaController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  void _onBuscaMudou(String valor) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<MovimentosController>().definirTexto(valor);
    });
  }

  Future<void> _novoMovimento() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MovimentoFormScreen(tipoInicial: TipoLancamento.despesa),
      ),
    );
  }

  Future<void> _editar(MovimentoComCategoria item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovimentoFormScreen(movimento: item.movimento),
      ),
    );
  }

  Future<void> _executarAcao(
    _AcaoMovimento acao,
    MovimentoComCategoria item,
  ) async {
    final controller = context.read<MovimentosController>();
    final movimento = item.movimento;
    switch (acao) {
      case _AcaoMovimento.editar:
        await _editar(item);
      case _AcaoMovimento.efetivar:
        final resultado = await mostrarEfetivarSheet(context, movimento);
        if (resultado == null || !mounted) return;
        await controller.efetivar(
          movimento.id!,
          dataPagamento: resultado.data,
          valorPago: resultado.valor,
        );
      case _AcaoMovimento.reabrir:
        await controller.reabrir(movimento.id!);
      case _AcaoMovimento.excluir:
        final ok = await _confirmarExclusao(movimento.descricao);
        if (!ok || !mounted) return;
        await controller.excluir(movimento.id!);
    }
  }

  Future<bool> _confirmarExclusao(String descricao) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir movimento'),
        content: Text('Deseja excluir "$descricao"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.despesa),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovimentosController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Movimentos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoMovimento,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo'),
      ),
      body: Column(
        children: [
          _Cabecalho(
            controller: controller,
            buscaController: _buscaController,
            onBuscaMudou: _onBuscaMudou,
          ),
          Expanded(
            child: _Lista(
              controller: controller,
              onTapItem: _editar,
              onAcao: _executarAcao,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.controller,
    required this.buscaController,
    required this.onBuscaMudou,
  });

  final MovimentosController controller;
  final TextEditingController buscaController;
  final ValueChanged<String> onBuscaMudou;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fundo,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          SeletorPeriodo(
            periodo: controller.periodo,
            onMudar: controller.definirPeriodo,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TotalMini(
                  rotulo: 'Receitas',
                  valor: controller.totalReceitas,
                  cor: AppColors.receita,
                  icone: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TotalMini(
                  rotulo: 'Despesas',
                  valor: controller.totalDespesas,
                  cor: AppColors.despesa,
                  icone: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: buscaController,
            onChanged: onBuscaMudou,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por descrição...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        buscaController.clear();
                        onBuscaMudou('');
                      },
                    ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          _Filtros(controller: controller),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.controller});

  final MovimentosController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'Receitas',
            selecionado: controller.tipo == TipoLancamento.receita,
            cor: AppColors.receita,
            onTap: () => controller.definirTipo(
              controller.tipo == TipoLancamento.receita
                  ? null
                  : TipoLancamento.receita,
            ),
          ),
          _chip(
            label: 'Despesas',
            selecionado: controller.tipo == TipoLancamento.despesa,
            cor: AppColors.despesa,
            onTap: () => controller.definirTipo(
              controller.tipo == TipoLancamento.despesa
                  ? null
                  : TipoLancamento.despesa,
            ),
          ),
          const _SeparadorFiltro(),
          _chip(
            label: 'Pendentes',
            selecionado: controller.status == StatusMovimento.pendente,
            cor: AppColors.alerta,
            onTap: () => controller.definirStatus(
              controller.status == StatusMovimento.pendente
                  ? null
                  : StatusMovimento.pendente,
            ),
          ),
          _chip(
            label: 'Efetivados',
            selecionado: controller.status == StatusMovimento.efetivado,
            cor: AppColors.primary,
            onTap: () => controller.definirStatus(
              controller.status == StatusMovimento.efetivado
                  ? null
                  : StatusMovimento.efetivado,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selecionado,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.suave(cor, 0.14) : AppColors.superficie,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selecionado ? cor : AppColors.borda,
              width: selecionado ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selecionado ? cor : AppColors.textoSuave,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeparadorFiltro extends StatelessWidget {
  const _SeparadorFiltro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      color: AppColors.borda,
    );
  }
}

class _TotalMini extends StatelessWidget {
  const _TotalMini({
    required this.rotulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  final String rotulo;
  final int valor;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.suave(cor, 0.13),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icone, size: 15, color: cor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textoSuave,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                ValorTexto(valor, cor: cor, tamanho: 14.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.controller,
    required this.onTapItem,
    required this.onAcao,
  });

  final MovimentosController controller;
  final ValueChanged<MovimentoComCategoria> onTapItem;
  final void Function(_AcaoMovimento, MovimentoComCategoria) onAcao;

  @override
  Widget build(BuildContext context) {
    if (controller.carregando && controller.itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.itens.isEmpty) {
      return EstadoVazio(
        icone: Icons.receipt_long_rounded,
        titulo: 'Nenhum movimento',
        mensagem: controller.filtrosAtivos > 0
            ? 'Nenhum resultado para os filtros selecionados.'
            : 'Toque em "Novo" para lançar sua primeira receita ou despesa.',
        acao: controller.filtrosAtivos > 0
            ? TextButton(
                onPressed: controller.limparFiltros,
                child: const Text('Limpar filtros'),
              )
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: controller.itens.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = controller.itens[index];
        return MovimentoTile(
          item: item,
          onTap: () => onTapItem(item),
          trailing: _MenuAcoes(item: item, onAcao: onAcao),
        );
      },
    );
  }
}

class _MenuAcoes extends StatelessWidget {
  const _MenuAcoes({required this.item, required this.onAcao});

  final MovimentoComCategoria item;
  final void Function(_AcaoMovimento, MovimentoComCategoria) onAcao;

  @override
  Widget build(BuildContext context) {
    final bool efetivado = item.movimento.status.isEfetivado;
    return PopupMenuButton<_AcaoMovimento>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textoLeve),
      padding: EdgeInsets.zero,
      onSelected: (acao) => onAcao(acao, item),
      itemBuilder: (context) => [
        if (!efetivado)
          const PopupMenuItem(
            value: _AcaoMovimento.efetivar,
            child: _ItemMenu(icone: Icons.check_circle_rounded, texto: 'Efetivar'),
          )
        else
          const PopupMenuItem(
            value: _AcaoMovimento.reabrir,
            child: _ItemMenu(icone: Icons.undo_rounded, texto: 'Reabrir'),
          ),
        const PopupMenuItem(
          value: _AcaoMovimento.editar,
          child: _ItemMenu(icone: Icons.edit_rounded, texto: 'Editar'),
        ),
        const PopupMenuItem(
          value: _AcaoMovimento.excluir,
          child: _ItemMenu(
            icone: Icons.delete_outline_rounded,
            texto: 'Excluir',
            cor: AppColors.despesa,
          ),
        ),
      ],
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.icone, required this.texto, this.cor});

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
