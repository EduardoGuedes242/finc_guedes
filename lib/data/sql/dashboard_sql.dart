/// SQL centralizado das consultas agregadas do dashboard.
///
/// Todos os valores retornados estão em centavos. Os parâmetros de STATUS são
/// passados como `?` pelo repositório (evitando literais espalhados).
class DashboardSql {
  const DashboardSql._();

  /// Saldo realizado acumulado (todas as datas): receitas recebidas menos
  /// despesas pagas. Parâmetro: STATUS efetivado.
  static const String saldoAtual = '''
SELECT
  IFNULL(SUM(CASE WHEN TIPO = 'E'
       THEN IFNULL(VALOR_PAGO, VALOR_PREVISTO) ELSE 0 END), 0) AS RECEITAS,
  IFNULL(SUM(CASE WHEN TIPO = 'S'
       THEN IFNULL(VALOR_PAGO, VALOR_PREVISTO) ELSE 0 END), 0) AS DESPESAS
FROM MOVIMENTOS
WHERE STATUS = ?''';

  /// Consolidação do período (previsto e efetivado, por tipo) desconsiderando
  /// cancelados.
  ///
  /// Ordem dos parâmetros:
  /// 1) STATUS efetivado (receitas efetivadas)
  /// 2) STATUS efetivado (despesas efetivadas)
  /// 3) STATUS pendente  (qtd. receitas pendentes)
  /// 4) STATUS pendente  (qtd. despesas pendentes)
  /// 5) data início   6) data fim
  /// 7) STATUS cancelado (para excluir)
  static const String resumoPeriodo = '''
SELECT
  IFNULL(SUM(CASE WHEN TIPO = 'E'
       THEN VALOR_PREVISTO ELSE 0 END), 0) AS REC_PREV,
  IFNULL(SUM(CASE WHEN TIPO = 'E' AND STATUS = ?
       THEN IFNULL(VALOR_PAGO, VALOR_PREVISTO) ELSE 0 END), 0) AS REC_EFET,
  IFNULL(SUM(CASE WHEN TIPO = 'S'
       THEN VALOR_PREVISTO ELSE 0 END), 0) AS DES_PREV,
  IFNULL(SUM(CASE WHEN TIPO = 'S' AND STATUS = ?
       THEN IFNULL(VALOR_PAGO, VALOR_PREVISTO) ELSE 0 END), 0) AS DES_EFET,
  IFNULL(SUM(CASE WHEN TIPO = 'E' AND STATUS = ? THEN 1 ELSE 0 END), 0) AS QTD_REC_PEND,
  IFNULL(SUM(CASE WHEN TIPO = 'S' AND STATUS = ? THEN 1 ELSE 0 END), 0) AS QTD_DES_PEND
FROM MOVIMENTOS
WHERE DATA_VENCIMENTO BETWEEN ? AND ? AND STATUS <> ?''';

  /// Distribuição por categoria de um tipo no período (previsto), do maior
  /// para o menor.
  ///
  /// Parâmetros: TIPO, STATUS cancelado (excluir), data início, data fim.
  static const String totaisPorCategoria = '''
SELECT C.ID          AS CATEGORIA_ID,
       C.NOME        AS CAT_NOME,
       C.COR         AS CAT_COR,
       C.ICONE       AS CAT_ICONE,
       IFNULL(SUM(M.VALOR_PREVISTO), 0) AS TOTAL,
       COUNT(*)      AS QUANTIDADE
FROM MOVIMENTOS M
INNER JOIN CATEGORIAS C ON C.ID = M.CATEGORIA_ID
WHERE M.TIPO = ? AND M.STATUS <> ? AND M.DATA_VENCIMENTO BETWEEN ? AND ?
GROUP BY C.ID, C.NOME, C.COR, C.ICONE
ORDER BY TOTAL DESC''';
}
