import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/datas.dart';
import '../../../core/utils/moeda.dart';
import '../../../core/widgets/secao_titulo.dart';
import '../../../core/widgets/seletor_periodo.dart';
import '../../../models/enums.dart';
import '../../../models/movimento_com_categoria.dart';
import '../../movimentos/screens/movimento_form_screen.dart';
import '../../movimentos/widgets/movimento_tile.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/distribuicao_categorias.dart';
import '../widgets/resumo_periodo_card.dart';
import '../widgets/saldo_card.dart';

/// Tela inicial com o resumo financeiro, próximos vencimentos e distribuição
/// de despesas.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onVerMovimentos});

  /// Navega para a aba de movimentos (usado nos atalhos "Ver todos").
  final VoidCallback onVerMovimentos;

  Future<void> _novoMovimento(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MovimentoFormScreen(tipoInicial: TipoLancamento.despesa),
      ),
    );
    if (context.mounted) context.read<DashboardController>().carregar();
  }

  Future<void> _editar(BuildContext context, MovimentoComCategoria item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovimentoFormScreen(movimento: item.movimento),
      ),
    );
    if (context.mounted) context.read<DashboardController>().carregar();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final resumo = controller.resumo;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_saudacao(), style: const TextStyle(fontSize: 20)),
            Text(
              Datas.extensa(DateTime.now()),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textoSuave,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novoMovimento(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.carregar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            SeletorPeriodo(
              periodo: controller.periodo,
              onMudar: controller.definirPeriodo,
            ),
            const SizedBox(height: 16),
            SaldoCard(
              saldoAtual: resumo.saldoAtual,
              saldoPrevistoPeriodo: resumo.saldoPrevistoPeriodo,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ResumoPeriodoCard(
                    rotulo: 'Receitas',
                    efetivado: resumo.receitasEfetivadas,
                    previsto: resumo.receitasPrevistas,
                    progresso: resumo.progressoReceitas,
                    cor: AppColors.receita,
                    icone: Icons.south_west_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResumoPeriodoCard(
                    rotulo: 'Despesas',
                    efetivado: resumo.despesasEfetivadas,
                    previsto: resumo.despesasPrevistas,
                    progresso: resumo.progressoDespesas,
                    cor: AppColors.despesa,
                    icone: Icons.north_east_rounded,
                  ),
                ),
              ],
            ),
            if (controller.atrasados.isNotEmpty) ...[
              const SizedBox(height: 12),
              _AlertaAtrasados(
                quantidade: controller.atrasados.length,
                total: controller.atrasados.fold<int>(
                  0,
                  (soma, i) => soma + i.movimento.valorPrevisto,
                ),
                onVer: onVerMovimentos,
              ),
            ],
            const SizedBox(height: 22),
            SecaoTitulo(
              'Próximos vencimentos',
              icone: Icons.event_note_rounded,
              acaoTexto: controller.proximos.isEmpty ? null : 'Ver todos',
              onAcao: controller.proximos.isEmpty ? null : onVerMovimentos,
            ),
            const SizedBox(height: 10),
            if (controller.proximos.isEmpty)
              const _CartaoVazio(
                icone: Icons.event_available_rounded,
                texto: 'Nenhum vencimento pendente. Tudo em dia! 🎉',
              )
            else
              ...controller.proximos.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MovimentoTile(
                    item: item,
                    onTap: () => _editar(context, item),
                  ),
                ),
              ),
            if (controller.despesasPorCategoria.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SecaoTitulo(
                'Despesas por categoria',
                icone: Icons.pie_chart_outline_rounded,
              ),
              const SizedBox(height: 10),
              DistribuicaoCategorias(itens: controller.despesasPorCategoria),
            ],
          ],
        ),
      ),
    );
  }

  String _saudacao() {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Bom dia! 👋';
    if (h < 18) return 'Boa tarde! 👋';
    return 'Boa noite! 👋';
  }
}

class _AlertaAtrasados extends StatelessWidget {
  const _AlertaAtrasados({
    required this.quantidade,
    required this.total,
    required this.onVer,
  });

  final int quantidade;
  final int total;
  final VoidCallback onVer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.suave(AppColors.despesa, 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onVer,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.suave(AppColors.despesa, 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.despesa, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$quantidade ${quantidade == 1 ? 'lançamento atrasado' : 'lançamentos atrasados'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.despesa,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: ${Moeda.format(total)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.despesa),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoVazio extends StatelessWidget {
  const _CartaoVazio({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          Icon(icone, color: AppColors.receita, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textoSuave,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
