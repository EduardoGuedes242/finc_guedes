import '../../../core/state/controller_base.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/movimento_repository.dart';
import '../../../models/enums.dart';
import '../../../models/movimento_com_categoria.dart';
import '../../../models/periodo.dart';
import '../../../models/resumo_financeiro.dart';
import '../../../models/total_categoria.dart';

/// Estado do dashboard: resumo do período, próximos vencimentos, atrasados e
/// distribuição de despesas por categoria.
class DashboardController extends ControllerBase {
  DashboardController({
    DashboardRepository? dashboardRepository,
    MovimentoRepository? movimentoRepository,
  })  : _dashboardRepo = dashboardRepository ?? DashboardRepository(),
        _movimentoRepo = movimentoRepository ?? MovimentoRepository();

  final DashboardRepository _dashboardRepo;
  final MovimentoRepository _movimentoRepo;

  Periodo _periodo = Periodo.mesAtual();
  Periodo get periodo => _periodo;

  ResumoFinanceiro _resumo = ResumoFinanceiro.vazio;
  ResumoFinanceiro get resumo => _resumo;

  List<MovimentoComCategoria> _proximos = const [];
  List<MovimentoComCategoria> get proximos => _proximos;

  List<MovimentoComCategoria> _atrasados = const [];
  List<MovimentoComCategoria> get atrasados => _atrasados;

  List<TotalCategoria> _despesasPorCategoria = const [];
  List<TotalCategoria> get despesasPorCategoria => _despesasPorCategoria;

  Future<void> carregar() {
    return carregarComEstado(() async {
      _resumo = await _dashboardRepo.resumo(_periodo);
      _proximos = await _movimentoRepo.proximosVencimentos(limite: 5);
      _atrasados = await _movimentoRepo.atrasados();
      _despesasPorCategoria = await _dashboardRepo.totaisPorCategoria(
        TipoLancamento.despesa,
        _periodo,
      );
    });
  }

  void definirPeriodo(Periodo periodo) {
    _periodo = periodo;
    carregar();
  }

  void mesAnterior() => definirPeriodo(_periodo.mesAnterior());
  void mesSeguinte() => definirPeriodo(_periodo.mesSeguinte());
}
