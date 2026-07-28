import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../models/enums.dart';
import '../../models/periodo.dart';
import '../../models/resumo_financeiro.dart';
import '../../models/total_categoria.dart';
import '../sql/dashboard_sql.dart';

/// Consultas de leitura consolidadas do dashboard. SQL centralizado em
/// [DashboardSql].
class DashboardRepository {
  DashboardRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// Monta o [ResumoFinanceiro] do [periodo] informado.
  Future<ResumoFinanceiro> resumo(Periodo periodo) async {
    final db = await _db;

    final saldoRows = await db.rawQuery(
      DashboardSql.saldoAtual,
      <Object?>[StatusMovimento.efetivado.code],
    );
    final saldo = saldoRows.first;
    final int receitasRealizadas = (saldo['RECEITAS'] as int?) ?? 0;
    final int despesasRealizadas = (saldo['DESPESAS'] as int?) ?? 0;

    final periodoRows = await db.rawQuery(
      DashboardSql.resumoPeriodo,
      <Object?>[
        StatusMovimento.efetivado.code, // REC_EFET
        StatusMovimento.efetivado.code, // DES_EFET
        StatusMovimento.pendente.code, // QTD_REC_PEND
        StatusMovimento.pendente.code, // QTD_DES_PEND
        periodo.inicioIso,
        periodo.fimIso,
        StatusMovimento.cancelado.code, // excluir cancelados
      ],
    );
    final p = periodoRows.first;

    return ResumoFinanceiro(
      saldoAtual: receitasRealizadas - despesasRealizadas,
      receitasPrevistas: (p['REC_PREV'] as int?) ?? 0,
      receitasEfetivadas: (p['REC_EFET'] as int?) ?? 0,
      despesasPrevistas: (p['DES_PREV'] as int?) ?? 0,
      despesasEfetivadas: (p['DES_EFET'] as int?) ?? 0,
      qtdReceitasPendentes: (p['QTD_REC_PEND'] as int?) ?? 0,
      qtdDespesasPendentes: (p['QTD_DES_PEND'] as int?) ?? 0,
    );
  }

  /// Distribuição por categoria (previsto) de um tipo dentro do período.
  Future<List<TotalCategoria>> totaisPorCategoria(
    TipoLancamento tipo,
    Periodo periodo,
  ) async {
    final db = await _db;
    final rows = await db.rawQuery(
      DashboardSql.totaisPorCategoria,
      <Object?>[
        tipo.code,
        StatusMovimento.cancelado.code,
        periodo.inicioIso,
        periodo.fimIso,
      ],
    );
    return rows.map(TotalCategoria.fromMap).toList();
  }
}
