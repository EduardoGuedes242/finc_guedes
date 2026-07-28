import '../../core/utils/db_convert.dart';
import '../../models/movimento.dart';

/// SQL centralizado da tabela `MOVIMENTOS`.
///
/// As leituras que precisam exibir a categoria usam um `INNER JOIN` com
/// `CATEGORIAS`, projetando os campos da categoria com os aliases `CAT_*`.
class MovimentoSql {
  const MovimentoSql._();

  /// Projeção padrão de leitura já com os dados da categoria.
  static const String _selectComCategoria = '''
SELECT M.*,
       C.NOME  AS CAT_NOME,
       C.COR   AS CAT_COR,
       C.ICONE AS CAT_ICONE
FROM MOVIMENTOS M
INNER JOIN CATEGORIAS C ON C.ID = M.CATEGORIA_ID''';

  static const String _orderPadrao =
      'ORDER BY M.DATA_VENCIMENTO ASC, M.ID ASC';

  // ---- Fragmentos de condição (compostos no repositório, sempre com `?`) ----

  static const String condPeriodo = 'M.DATA_VENCIMENTO BETWEEN ? AND ?';
  static const String condTipo = 'M.TIPO = ?';
  static const String condStatus = 'M.STATUS = ?';
  static const String condCategoria = 'M.CATEGORIA_ID = ?';
  static const String condTexto =
      '(M.DESCRICAO LIKE ? OR IFNULL(M.OBSERVACAO, "") LIKE ?)';

  /// Monta uma consulta de listagem a partir de condições já parametrizadas.
  ///
  /// [condicoes] contém apenas os fragmentos acima (todos com `?`), o que
  /// mantém a montagem controlada — nada de valores concatenados diretamente
  /// no SQL.
  static String listagem(List<String> condicoes) {
    final String where =
        condicoes.isEmpty ? '' : 'WHERE ${condicoes.join(' AND ')}';
    return '$_selectComCategoria\n$where\n$_orderPadrao';
  }

  static const String selectById = '''
$_selectComCategoria
WHERE M.ID = ?''';

  /// Próximos vencimentos: pendentes com vencimento a partir de hoje.
  static const String selectProximosVencimentos = '''
$_selectComCategoria
WHERE M.STATUS = ? AND M.DATA_VENCIMENTO >= ?
ORDER BY M.DATA_VENCIMENTO ASC, M.ID ASC
LIMIT ?''';

  /// Lançamentos em atraso: pendentes com vencimento anterior a hoje.
  static const String selectAtrasados = '''
$_selectComCategoria
WHERE M.STATUS = ? AND M.DATA_VENCIMENTO < ?
ORDER BY M.DATA_VENCIMENTO ASC, M.ID ASC''';

  // ---- Escrita ----

  static const String insert = '''
INSERT INTO MOVIMENTOS
  (RECORRENCIA_ID, CATEGORIA_ID, TIPO, DESCRICAO, DATA_VENCIMENTO, DATA_PAGAMENTO,
   VALOR_PREVISTO, VALOR_PAGO, STATUS, ORIGEM, OBSERVACAO)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''';

  static List<Object?> insertArgs(Movimento m) => <Object?>[
        m.recorrenciaId,
        m.categoriaId,
        m.tipo.code,
        m.descricao,
        DbConvert.date(m.dataVencimento),
        DbConvert.dateOrNull(m.dataPagamento),
        m.valorPrevisto,
        m.valorPago,
        m.status.code,
        m.origem.code,
        m.observacao,
      ];

  /// Atualiza os campos editáveis. Não altera RECORRENCIA_ID nem CRIADO_EM.
  static const String update = '''
UPDATE MOVIMENTOS
SET CATEGORIA_ID = ?, TIPO = ?, DESCRICAO = ?, DATA_VENCIMENTO = ?,
    DATA_PAGAMENTO = ?, VALOR_PREVISTO = ?, VALOR_PAGO = ?, STATUS = ?,
    ORIGEM = ?, OBSERVACAO = ?, ALTERADO_EM = ?
WHERE ID = ?''';

  static List<Object?> updateArgs(Movimento m) => <Object?>[
        m.categoriaId,
        m.tipo.code,
        m.descricao,
        DbConvert.date(m.dataVencimento),
        DbConvert.dateOrNull(m.dataPagamento),
        m.valorPrevisto,
        m.valorPago,
        m.status.code,
        m.origem.code,
        m.observacao,
        DbConvert.nowTimestamp(),
        m.id,
      ];

  /// Efetiva (marca como pago/recebido) informando data e valor.
  static const String efetivar = '''
UPDATE MOVIMENTOS
SET STATUS = ?, DATA_PAGAMENTO = ?, VALOR_PAGO = ?, ALTERADO_EM = ?
WHERE ID = ?''';

  /// Reabre um movimento efetivado, limpando pagamento e valor pago.
  static const String reabrir = '''
UPDATE MOVIMENTOS
SET STATUS = ?, DATA_PAGAMENTO = NULL, VALOR_PAGO = NULL, ALTERADO_EM = ?
WHERE ID = ?''';

  static const String delete = 'DELETE FROM MOVIMENTOS WHERE ID = ?';

  /// Remove movimentos pendentes futuros de uma recorrência (usado ao excluir
  /// ou encerrar a recorrência, preservando o histórico já efetivado).
  static const String deletePendentesFuturosDaRecorrencia = '''
DELETE FROM MOVIMENTOS
WHERE RECORRENCIA_ID = ? AND STATUS = ? AND DATA_VENCIMENTO >= ?''';

  /// Desvincula da recorrência os movimentos remanescentes (mantém o histórico
  /// ao excluir a recorrência, respeitando a integridade referencial).
  static const String desvincularRecorrencia =
      'UPDATE MOVIMENTOS SET RECORRENCIA_ID = NULL WHERE RECORRENCIA_ID = ?';

  /// Verifica se já existe movimento de uma recorrência dentro da competência
  /// (rede de segurança contra duplicidade na geração automática).
  static const String existeNaCompetencia = '''
SELECT COUNT(*) AS TOTAL
FROM MOVIMENTOS
WHERE RECORRENCIA_ID = ? AND DATA_VENCIMENTO BETWEEN ? AND ?''';
}
