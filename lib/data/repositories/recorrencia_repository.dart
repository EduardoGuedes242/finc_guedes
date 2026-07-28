import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/db_convert.dart';
import '../../models/enums.dart';
import '../../models/recorrencia.dart';
import '../../models/recorrencia_com_categoria.dart';
import '../sql/movimento_sql.dart';
import '../sql/recorrencia_sql.dart';

/// Acesso a dados da tabela `RECORRENCIAS`. SQL nativo centralizado em
/// [RecorrenciaSql].
class RecorrenciaRepository {
  RecorrenciaRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Future<List<RecorrenciaComCategoria>> listarComCategoria() async {
    final db = await _db;
    final rows = await db.rawQuery(RecorrenciaSql.selectAllComCategoria);
    return rows.map(RecorrenciaComCategoria.fromMap).toList();
  }

  Future<Recorrencia?> buscarPorId(int id) async {
    final db = await _db;
    final rows = await db.rawQuery(RecorrenciaSql.selectById, <Object?>[id]);
    if (rows.isEmpty) return null;
    return Recorrencia.fromMap(rows.first);
  }

  Future<int> inserir(Recorrencia recorrencia) async {
    final db = await _db;
    return db.rawInsert(
      RecorrenciaSql.insert,
      RecorrenciaSql.insertArgs(recorrencia),
    );
  }

  Future<void> atualizar(Recorrencia recorrencia) async {
    final db = await _db;
    await db.rawUpdate(
      RecorrenciaSql.update,
      RecorrenciaSql.updateArgs(recorrencia),
    );
  }

  Future<void> definirAtivo(int id, bool ativo) async {
    final db = await _db;
    await db.rawUpdate(
      RecorrenciaSql.updateAtivo,
      <Object?>[DbConvert.boolToInt(ativo), id],
    );
  }

  /// Exclui a recorrência dentro de uma transação: remove os lançamentos
  /// pendentes futuros gerados por ela e desvincula os demais (preservando o
  /// histórico já efetivado), depois exclui a recorrência.
  Future<void> excluir(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.rawDelete(
        MovimentoSql.deletePendentesFuturosDaRecorrencia,
        <Object?>[
          id,
          StatusMovimento.pendente.code,
          DbConvert.date(DateTime.now()),
        ],
      );
      await txn.rawUpdate(
        MovimentoSql.desvincularRecorrencia,
        <Object?>[id],
      );
      await txn.rawDelete(RecorrenciaSql.delete, <Object?>[id]);
    });
  }
}
