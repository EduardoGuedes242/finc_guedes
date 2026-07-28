import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/db_convert.dart';
import '../../models/enums.dart';
import '../../models/movimento.dart';
import '../../models/movimento_com_categoria.dart';
import '../../models/periodo.dart';
import '../sql/movimento_sql.dart';

/// Acesso a dados da tabela `MOVIMENTOS`. SQL nativo centralizado em
/// [MovimentoSql].
class MovimentoRepository {
  MovimentoRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Lista movimentos com filtros opcionais. As condições são montadas apenas
  /// com fragmentos pré-definidos e valores parametrizados (`?`).
  Future<List<MovimentoComCategoria>> buscar({
    required Periodo periodo,
    TipoLancamento? tipo,
    StatusMovimento? status,
    String? texto,
  }) async {
    final db = await _db;

    final List<String> condicoes = <String>[MovimentoSql.condPeriodo];
    final List<Object?> args = <Object?>[periodo.inicioIso, periodo.fimIso];

    if (tipo != null) {
      condicoes.add(MovimentoSql.condTipo);
      args.add(tipo.code);
    }
    if (status != null) {
      condicoes.add(MovimentoSql.condStatus);
      args.add(status.code);
    }
    final String? termo = texto?.trim();
    if (termo != null && termo.isNotEmpty) {
      condicoes.add(MovimentoSql.condTexto);
      final String like = '%$termo%';
      args
        ..add(like)
        ..add(like);
    }

    final rows = await db.rawQuery(MovimentoSql.listagem(condicoes), args);
    return rows.map(MovimentoComCategoria.fromMap).toList();
  }

  Future<MovimentoComCategoria?> buscarPorId(int id) async {
    final db = await _db;
    final rows = await db.rawQuery(MovimentoSql.selectById, <Object?>[id]);
    if (rows.isEmpty) return null;
    return MovimentoComCategoria.fromMap(rows.first);
  }

  /// Próximos vencimentos (pendentes a partir de hoje).
  Future<List<MovimentoComCategoria>> proximosVencimentos({
    int limite = 5,
  }) async {
    final db = await _db;
    final rows = await db.rawQuery(
      MovimentoSql.selectProximosVencimentos,
      <Object?>[
        StatusMovimento.pendente.code,
        DbConvert.date(DateTime.now()),
        limite,
      ],
    );
    return rows.map(MovimentoComCategoria.fromMap).toList();
  }

  /// Lançamentos pendentes com vencimento vencido.
  Future<List<MovimentoComCategoria>> atrasados() async {
    final db = await _db;
    final rows = await db.rawQuery(
      MovimentoSql.selectAtrasados,
      <Object?>[StatusMovimento.pendente.code, DbConvert.date(DateTime.now())],
    );
    return rows.map(MovimentoComCategoria.fromMap).toList();
  }

  Future<int> inserir(Movimento movimento) async {
    final db = await _db;
    return db.rawInsert(MovimentoSql.insert, MovimentoSql.insertArgs(movimento));
  }

  Future<void> atualizar(Movimento movimento) async {
    final db = await _db;
    await db.rawUpdate(MovimentoSql.update, MovimentoSql.updateArgs(movimento));
  }

  /// Efetiva o movimento (pago/recebido) com data e valor informados.
  Future<void> efetivar(
    int id, {
    required DateTime dataPagamento,
    required int valorPago,
  }) async {
    final db = await _db;
    await db.rawUpdate(MovimentoSql.efetivar, <Object?>[
      StatusMovimento.efetivado.code,
      DbConvert.date(dataPagamento),
      valorPago,
      DbConvert.nowTimestamp(),
      id,
    ]);
  }

  /// Reabre um movimento efetivado, voltando-o para pendente.
  Future<void> reabrir(int id) async {
    final db = await _db;
    await db.rawUpdate(MovimentoSql.reabrir, <Object?>[
      StatusMovimento.pendente.code,
      DbConvert.nowTimestamp(),
      id,
    ]);
  }

  Future<void> excluir(int id) async {
    final db = await _db;
    await db.rawDelete(MovimentoSql.delete, <Object?>[id]);
  }
}
