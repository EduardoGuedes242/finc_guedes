import '../../../core/state/controller_base.dart';
import '../../../data/repositories/recorrencia_repository.dart';
import '../../../models/recorrencia.dart';
import '../../../models/recorrencia_com_categoria.dart';
import '../../../services/recorrencia_service.dart';

/// Estado da tela de contas recorrentes: listagem e CRUD. Após inserir/editar,
/// dispara a geração automática dos movimentos correspondentes.
class RecorrenciasController extends ControllerBase {
  RecorrenciasController({
    RecorrenciaRepository? repository,
    RecorrenciaService? service,
  })  : _repo = repository ?? RecorrenciaRepository(),
        _service = service ?? RecorrenciaService();

  final RecorrenciaRepository _repo;
  final RecorrenciaService _service;

  List<RecorrenciaComCategoria> _itens = const [];
  List<RecorrenciaComCategoria> get itens => _itens;

  bool get vazio => _itens.isEmpty;

  Future<void> carregar() {
    return carregarComEstado(() async {
      _itens = await _repo.listarComCategoria();
    });
  }

  /// Insere/atualiza a recorrência e gera imediatamente os movimentos devidos.
  Future<bool> salvar(Recorrencia recorrencia) async {
    final bool ok = await executarAcao(() async {
      if (recorrencia.id == null) {
        await _repo.inserir(recorrencia);
      } else {
        await _repo.atualizar(recorrencia);
      }
      await _service.gerarPendentes();
    });
    if (ok) await carregar();
    return ok;
  }

  Future<bool> alternarAtivo(Recorrencia recorrencia) async {
    final bool ok = await executarAcao(
      () => _repo.definirAtivo(recorrencia.id!, !recorrencia.ativo),
    );
    if (ok) await carregar();
    return ok;
  }

  Future<bool> excluir(int id) async {
    final bool ok = await executarAcao(() => _repo.excluir(id));
    if (ok) await carregar();
    return ok;
  }
}
