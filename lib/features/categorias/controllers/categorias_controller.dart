import '../../../core/state/controller_base.dart';
import '../../../data/repositories/categoria_repository.dart';
import '../../../models/categoria.dart';
import '../../../models/enums.dart';

/// Estado da tela de categorias: listagem e operações de CRUD.
class CategoriasController extends ControllerBase {
  CategoriasController({CategoriaRepository? repository})
      : _repo = repository ?? CategoriaRepository();

  final CategoriaRepository _repo;

  List<Categoria> _itens = const [];
  List<Categoria> get itens => _itens;

  List<Categoria> get receitas =>
      _itens.where((c) => c.tipo.isReceita).toList();

  List<Categoria> get despesas =>
      _itens.where((c) => c.tipo.isDespesa).toList();

  Future<void> carregar() {
    return carregarComEstado(() async {
      _itens = await _repo.listarTodas();
    });
  }

  /// Insere (quando [Categoria.id] é nulo) ou atualiza uma categoria.
  Future<bool> salvar(Categoria categoria) async {
    final bool ok = await executarAcao(() async {
      if (categoria.id == null) {
        await _repo.inserir(categoria);
      } else {
        await _repo.atualizar(categoria);
      }
    });
    if (ok) await carregar();
    return ok;
  }

  Future<bool> alternarAtivo(Categoria categoria) async {
    final bool ok = await executarAcao(
      () => _repo.atualizar(categoria.copyWith(ativo: !categoria.ativo)),
    );
    if (ok) await carregar();
    return ok;
  }

  Future<bool> excluir(int id) async {
    final bool ok = await executarAcao(() => _repo.excluir(id));
    if (ok) await carregar();
    return ok;
  }

  /// Carrega apenas as categorias ativas de um tipo (usado nos formulários).
  Future<List<Categoria>> ativasPorTipo(TipoLancamento tipo) {
    return _repo.listarAtivasPorTipo(tipo);
  }
}
