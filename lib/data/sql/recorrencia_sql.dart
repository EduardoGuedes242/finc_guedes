import '../../core/utils/db_convert.dart';
import '../../models/recorrencia.dart';

/// SQL centralizado da tabela `RECORRENCIAS`.
class RecorrenciaSql {
  const RecorrenciaSql._();

  static const String _colunas =
      'ID, CATEGORIA_ID, TIPO, DESCRICAO, VALOR_PREVISTO, DIA_VENCIMENTO, '
      'DATA_INICIO, DATA_FIM, ATIVO, GERAR_ANTECIPADO, '
      'ULTIMA_COMPETENCIA_GERADA, OBSERVACAO';

  /// Listagem com dados da categoria para exibição.
  static const String selectAllComCategoria = '''
SELECT R.*,
       C.NOME  AS CAT_NOME,
       C.COR   AS CAT_COR,
       C.ICONE AS CAT_ICONE
FROM RECORRENCIAS R
INNER JOIN CATEGORIAS C ON C.ID = R.CATEGORIA_ID
ORDER BY R.ATIVO DESC, R.DESCRICAO COLLATE NOCASE''';

  /// Recorrências ativas — usadas pelo motor de geração de movimentos.
  static const String selectAtivas =
      'SELECT $_colunas FROM RECORRENCIAS WHERE ATIVO = 1 ORDER BY ID';

  static const String selectById =
      'SELECT $_colunas FROM RECORRENCIAS WHERE ID = ?';

  static const String insert = '''
INSERT INTO RECORRENCIAS
  (CATEGORIA_ID, TIPO, DESCRICAO, VALOR_PREVISTO, DIA_VENCIMENTO, DATA_INICIO,
   DATA_FIM, ATIVO, GERAR_ANTECIPADO, ULTIMA_COMPETENCIA_GERADA, OBSERVACAO)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''';

  static List<Object?> insertArgs(Recorrencia r) => <Object?>[
        r.categoriaId,
        r.tipo.code,
        r.descricao,
        r.valorPrevisto,
        r.diaVencimento,
        DbConvert.date(r.dataInicio),
        DbConvert.dateOrNull(r.dataFim),
        DbConvert.boolToInt(r.ativo),
        DbConvert.boolToInt(r.gerarAntecipado),
        DbConvert.dateOrNull(r.ultimaCompetenciaGerada),
        r.observacao,
      ];

  static const String update = '''
UPDATE RECORRENCIAS
SET CATEGORIA_ID = ?, TIPO = ?, DESCRICAO = ?, VALOR_PREVISTO = ?,
    DIA_VENCIMENTO = ?, DATA_INICIO = ?, DATA_FIM = ?, ATIVO = ?,
    GERAR_ANTECIPADO = ?, ULTIMA_COMPETENCIA_GERADA = ?, OBSERVACAO = ?
WHERE ID = ?''';

  static List<Object?> updateArgs(Recorrencia r) => <Object?>[
        r.categoriaId,
        r.tipo.code,
        r.descricao,
        r.valorPrevisto,
        r.diaVencimento,
        DbConvert.date(r.dataInicio),
        DbConvert.dateOrNull(r.dataFim),
        DbConvert.boolToInt(r.ativo),
        DbConvert.boolToInt(r.gerarAntecipado),
        DbConvert.dateOrNull(r.ultimaCompetenciaGerada),
        r.observacao,
        r.id,
      ];

  /// Atualiza apenas a última competência gerada (após gerar movimentos).
  static const String updateUltimaCompetencia =
      'UPDATE RECORRENCIAS SET ULTIMA_COMPETENCIA_GERADA = ? WHERE ID = ?';

  /// Ativa/desativa a recorrência.
  static const String updateAtivo =
      'UPDATE RECORRENCIAS SET ATIVO = ? WHERE ID = ?';

  static const String delete = 'DELETE FROM RECORRENCIAS WHERE ID = ?';
}
