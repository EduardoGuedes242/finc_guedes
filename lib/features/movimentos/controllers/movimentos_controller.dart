import '../../../core/state/controller_base.dart';
import '../../../data/repositories/movimento_repository.dart';
import '../../../models/enums.dart';
import '../../../models/movimento.dart';
import '../../../models/movimento_com_categoria.dart';
import '../../../models/periodo.dart';

/// Estado da tela de movimentos: filtros (período, tipo, status, texto),
/// listagem e ações de efetivar/reabrir/excluir.
class MovimentosController extends ControllerBase {
  MovimentosController({MovimentoRepository? repository})
      : _repo = repository ?? MovimentoRepository();

  final MovimentoRepository _repo;

  Periodo _periodo = Periodo.mesAtual();
  Periodo get periodo => _periodo;

  TipoLancamento? _tipo;
  TipoLancamento? get tipo => _tipo;

  StatusMovimento? _status;
  StatusMovimento? get status => _status;

  String _texto = '';
  String get texto => _texto;

  List<MovimentoComCategoria> _itens = const [];
  List<MovimentoComCategoria> get itens => _itens;

  bool get vazio => _itens.isEmpty;

  /// Filtros ativos além do período (para exibir contador/limpar).
  int get filtrosAtivos =>
      (_tipo != null ? 1 : 0) +
      (_status != null ? 1 : 0) +
      (_texto.trim().isNotEmpty ? 1 : 0);

  /// Total de receitas (valor efetivo) na listagem atual.
  int get totalReceitas => _somar(TipoLancamento.receita);

  /// Total de despesas (valor efetivo) na listagem atual.
  int get totalDespesas => _somar(TipoLancamento.despesa);

  int _somar(TipoLancamento tipo) {
    return _itens
        .map((i) => i.movimento)
        .where((m) => m.tipo == tipo && !m.status.isCancelado)
        .fold<int>(0, (soma, m) => soma + m.valorEfetivo);
  }

  Future<void> carregar() {
    return carregarComEstado(() async {
      _itens = await _repo.buscar(
        periodo: _periodo,
        tipo: _tipo,
        status: _status,
        texto: _texto,
      );
    });
  }

  void definirPeriodo(Periodo periodo) {
    _periodo = periodo;
    carregar();
  }

  void mesAnterior() => definirPeriodo(_periodo.mesAnterior());
  void mesSeguinte() => definirPeriodo(_periodo.mesSeguinte());

  void definirTipo(TipoLancamento? tipo) {
    _tipo = tipo;
    carregar();
  }

  void definirStatus(StatusMovimento? status) {
    _status = status;
    carregar();
  }

  void definirTexto(String texto) {
    _texto = texto;
    carregar();
  }

  void limparFiltros() {
    _tipo = null;
    _status = null;
    _texto = '';
    carregar();
  }

  /// Insere (quando [Movimento.id] é nulo) ou atualiza um movimento.
  Future<bool> salvar(Movimento movimento) async {
    final bool ok = await executarAcao(() async {
      if (movimento.id == null) {
        await _repo.inserir(movimento);
      } else {
        await _repo.atualizar(movimento);
      }
    });
    if (ok) await carregar();
    return ok;
  }

  Future<bool> efetivar(
    int id, {
    required DateTime dataPagamento,
    required int valorPago,
  }) async {
    final bool ok = await executarAcao(
      () => _repo.efetivar(id, dataPagamento: dataPagamento, valorPago: valorPago),
    );
    if (ok) await carregar();
    return ok;
  }

  Future<bool> reabrir(int id) async {
    final bool ok = await executarAcao(() => _repo.reabrir(id));
    if (ok) await carregar();
    return ok;
  }

  Future<bool> excluir(int id) async {
    final bool ok = await executarAcao(() => _repo.excluir(id));
    if (ok) await carregar();
    return ok;
  }
}
