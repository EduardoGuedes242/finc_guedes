import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/utils/app_date_utils.dart';
import '../core/utils/db_convert.dart';
import '../data/sql/movimento_sql.dart';
import '../data/sql/recorrencia_sql.dart';
import '../models/enums.dart';
import '../models/movimento.dart';
import '../models/recorrencia.dart';

/// Motor de geração automática dos movimentos recorrentes.
///
/// Regras aplicadas por recorrência ativa:
/// - Gera uma competência (mês) por vez, do início pendente até o horizonte.
/// - O horizonte é o mês atual; com `GERAR_ANTECIPADO = 1`, avança um mês.
/// - O dia de vencimento é ajustado para o último dia do mês quando necessário.
/// - Respeita `DATA_INICIO` e `DATA_FIM`.
/// - É idempotente: usa `ULTIMA_COMPETENCIA_GERADA` e uma verificação de
///   duplicidade por competência para nunca gerar o mesmo lançamento duas vezes.
///
/// Toda a operação roda em uma única transação, garantindo atomicidade.
class RecorrenciaService {
  RecorrenciaService({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  /// Limite de segurança para evitar laços muito longos com dados atípicos.
  static const int _maxCompetencias = 1200; // 100 anos.

  /// Gera os movimentos pendentes de todas as recorrências ativas.
  /// Retorna a quantidade de movimentos criados.
  Future<int> gerarPendentes({DateTime? referencia}) async {
    final db = await _appDatabase.database;
    final DateTime hoje = AppDateUtils.dateOnly(referencia ?? DateTime.now());

    int totalGerados = 0;
    await db.transaction((txn) async {
      final rows = await txn.rawQuery(RecorrenciaSql.selectAtivas);
      final recorrencias = rows.map(Recorrencia.fromMap).toList();
      for (final Recorrencia recorrencia in recorrencias) {
        totalGerados += await _gerarParaRecorrencia(txn, recorrencia, hoje);
      }
    });
    return totalGerados;
  }

  Future<int> _gerarParaRecorrencia(
    Transaction txn,
    Recorrencia recorrencia,
    DateTime hoje,
  ) async {
    final int? recorrenciaId = recorrencia.id;
    if (recorrenciaId == null) return 0;

    final DateTime inicioData = AppDateUtils.dateOnly(recorrencia.dataInicio);
    final DateTime? fimData = recorrencia.dataFim == null
        ? null
        : AppDateUtils.dateOnly(recorrencia.dataFim!);

    // Horizonte: mês atual (+1 se gerar antecipado).
    DateTime horizonte = AppDateUtils.firstDayOfMonth(hoje);
    if (recorrencia.gerarAntecipado) {
      horizonte = AppDateUtils.addMonths(horizonte, 1);
    }

    // Primeira competência a avaliar.
    DateTime competencia = recorrencia.ultimaCompetenciaGerada != null
        ? AppDateUtils.nextCompetencia(recorrencia.ultimaCompetenciaGerada!)
        : AppDateUtils.firstDayOfMonth(inicioData);

    int gerados = 0;
    DateTime? ultimaProcessada;
    int guarda = 0;

    while (!competencia.isAfter(horizonte) && guarda < _maxCompetencias) {
      guarda++;
      final DateTime vencimento = AppDateUtils.vencimentoNaCompetencia(
        competencia,
        recorrencia.diaVencimento,
      );

      // Passou da data fim: encerra a geração desta recorrência.
      if (fimData != null && vencimento.isAfter(fimData)) break;

      // Vencimento antes do início: pula a competência (não avança o marcador).
      if (vencimento.isBefore(inicioData)) {
        competencia = AppDateUtils.nextCompetencia(competencia);
        continue;
      }

      final bool jaExiste = await _existeNaCompetencia(
        txn,
        recorrenciaId,
        competencia,
      );
      if (!jaExiste) {
        await txn.rawInsert(
          MovimentoSql.insert,
          MovimentoSql.insertArgs(_movimentoDe(recorrencia, vencimento)),
        );
        gerados++;
      }

      ultimaProcessada = competencia;
      competencia = AppDateUtils.nextCompetencia(competencia);
    }

    if (ultimaProcessada != null) {
      await txn.rawUpdate(
        RecorrenciaSql.updateUltimaCompetencia,
        <Object?>[DbConvert.date(ultimaProcessada), recorrenciaId],
      );
    }
    return gerados;
  }

  Movimento _movimentoDe(Recorrencia recorrencia, DateTime vencimento) {
    return Movimento(
      recorrenciaId: recorrencia.id,
      categoriaId: recorrencia.categoriaId,
      tipo: recorrencia.tipo,
      descricao: recorrencia.descricao,
      dataVencimento: vencimento,
      valorPrevisto: recorrencia.valorPrevisto,
      status: StatusMovimento.pendente,
      origem: OrigemMovimento.recorrencia,
      observacao: recorrencia.observacao,
    );
  }

  Future<bool> _existeNaCompetencia(
    Transaction txn,
    int recorrenciaId,
    DateTime competencia,
  ) async {
    final DateTime primeiro = AppDateUtils.firstDayOfMonth(competencia);
    final DateTime ultimo = AppDateUtils.lastDayOfMonth(competencia);
    final int total = Sqflite.firstIntValue(
          await txn.rawQuery(MovimentoSql.existeNaCompetencia, <Object?>[
            recorrenciaId,
            DbConvert.date(primeiro),
            DbConvert.date(ultimo),
          ]),
        ) ??
        0;
    return total > 0;
  }
}
