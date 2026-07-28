import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../models/enums.dart';
import '../../../models/recorrencia_com_categoria.dart';
import '../controllers/recorrencias_controller.dart';
import '../widgets/recorrencia_tile.dart';
import 'recorrencia_form_screen.dart';

/// Tela de contas recorrentes.
class RecorrenciasScreen extends StatelessWidget {
  const RecorrenciasScreen({super.key});

  Future<void> _abrirForm(BuildContext context, {RecorrenciaComCategoria? item}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecorrenciaFormScreen(
          recorrencia: item?.recorrencia,
          tipoInicial: TipoLancamento.despesa,
        ),
      ),
    );
  }

  Future<void> _executarAcao(
    BuildContext context,
    AcaoRecorrencia acao,
    RecorrenciaComCategoria item,
  ) async {
    final controller = context.read<RecorrenciasController>();
    switch (acao) {
      case AcaoRecorrencia.editar:
        await _abrirForm(context, item: item);
      case AcaoRecorrencia.alternarAtivo:
        await controller.alternarAtivo(item.recorrencia);
      case AcaoRecorrencia.excluir:
        final bool confirmar = await AppFeedback.confirmar(
          context,
          titulo: 'Excluir recorrência',
          mensagem:
              'Isto remove os lançamentos pendentes futuros gerados por ela. '
              'O histórico já efetivado é mantido. Continuar?',
          textoConfirmar: 'Excluir',
          destrutivo: true,
        );
        if (!confirmar || !context.mounted) return;
        final bool ok = await controller.excluir(item.recorrencia.id!);
        if (!context.mounted) return;
        if (ok) {
          AppFeedback.sucesso(context, 'Recorrência excluída.');
        } else {
          AppFeedback.erro(
            context,
            controller.erro ?? 'Não foi possível excluir.',
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecorrenciasController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Contas recorrentes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova'),
      ),
      body: _corpo(context, controller),
    );
  }

  Widget _corpo(BuildContext context, RecorrenciasController controller) {
    if (controller.carregando && controller.itens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.vazio) {
      return EstadoVazio(
        icone: Icons.autorenew_rounded,
        titulo: 'Nenhuma conta recorrente',
        mensagem:
            'Cadastre contas fixas (aluguel, salário, assinaturas) e os '
            'lançamentos serão gerados automaticamente a cada mês.',
      );
    }

    return Column(
      children: [
        const _Explicacao(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: controller.itens.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = controller.itens[index];
              return RecorrenciaTile(
                item: item,
                onTap: () => _abrirForm(context, item: item),
                onAcao: (acao) => _executarAcao(context, acao, item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Explicacao extends StatelessWidget {
  const _Explicacao();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.suave(AppColors.primary, 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.suave(AppColors.primary, 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Os movimentos são gerados automaticamente todo mês conforme o dia '
              'de vencimento.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.texto.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
