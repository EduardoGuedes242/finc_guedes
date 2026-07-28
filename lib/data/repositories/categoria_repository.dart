import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/errors/app_exception.dart';
import '../../models/categoria.dart';
import '../../models/enums.dart';
import '../sql/categoria_sql.dart';

/// Acesso a dados da tabela `CATEGORIAS`. Toda a persistência usa SQL nativo
/// (via `sqflite`) com as instruções centralizadas em [CategoriaSql].
class CategoriaRepository {
  CategoriaRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Future<List<Categoria>> listarTodas() async {
    final db = await _db;
    final rows = await db.rawQuery(CategoriaSql.selectAll);
    return rows.map(Categoria.fromMap).toList();
  }

  Future<List<Categoria>> listarAtivas() async {
    final db = await _db;
    final rows = await db.rawQuery(CategoriaSql.selectAtivas);
    return rows.map(Categoria.fromMap).toList();
  }

  Future<List<Categoria>> listarAtivasPorTipo(TipoLancamento tipo) async {
    final db = await _db;
    final rows = await db.rawQuery(
      CategoriaSql.selectAtivasPorTipo,
      <Object?>[tipo.code],
    );
    return rows.map(Categoria.fromMap).toList();
  }

  Future<Categoria?> buscarPorId(int id) async {
    final db = await _db;
    final rows = await db.rawQuery(CategoriaSql.selectById, <Object?>[id]);
    if (rows.isEmpty) return null;
    return Categoria.fromMap(rows.first);
  }

  /// Insere e retorna o ID gerado.
  Future<int> inserir(Categoria categoria) async {
    final db = await _db;
    return db.rawInsert(CategoriaSql.insert, CategoriaSql.insertArgs(categoria));
  }

  Future<void> atualizar(Categoria categoria) async {
    final db = await _db;
    await db.rawUpdate(CategoriaSql.update, CategoriaSql.updateArgs(categoria));
  }

  /// Exclui a categoria. Lança [AppException] quando existem movimentos ou
  /// recorrências vinculados (a integridade referencial não permite a exclusão).
  Future<void> excluir(int id) async {
    final db = await _db;
    final int usos = await _contarUsos(db, id);
    if (usos > 0) {
      throw const AppException(
        'Esta categoria está em uso e não pode ser excluída. '
        'Você pode desativá-la para ocultá-la dos novos lançamentos.',
      );
    }
    await db.rawDelete(CategoriaSql.delete, <Object?>[id]);
  }

  Future<int> _contarUsos(Database db, int id) async {
    final movimentos = Sqflite.firstIntValue(
          await db.rawQuery(CategoriaSql.contarMovimentos, <Object?>[id]),
        ) ??
        0;
    final recorrencias = Sqflite.firstIntValue(
          await db.rawQuery(CategoriaSql.contarRecorrencias, <Object?>[id]),
        ) ??
        0;
    return movimentos + recorrencias;
  }
}
