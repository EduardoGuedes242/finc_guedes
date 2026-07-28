/// Resumo financeiro consolidado exibido no dashboard.
///
/// Todos os valores estão em **centavos**.
class ResumoFinanceiro {
  const ResumoFinanceiro({
    this.saldoAtual = 0,
    this.receitasPrevistas = 0,
    this.receitasEfetivadas = 0,
    this.despesasPrevistas = 0,
    this.despesasEfetivadas = 0,
    this.qtdReceitasPendentes = 0,
    this.qtdDespesasPendentes = 0,
  });

  /// Saldo realizado acumulado (todas as receitas recebidas menos todas as
  /// despesas pagas, em qualquer data).
  final int saldoAtual;

  /// Total de receitas previstas no período (pendentes + efetivadas).
  final int receitasPrevistas;

  /// Total de receitas já recebidas no período.
  final int receitasEfetivadas;

  /// Total de despesas previstas no período (pendentes + efetivadas).
  final int despesasPrevistas;

  /// Total de despesas já pagas no período.
  final int despesasEfetivadas;

  final int qtdReceitasPendentes;
  final int qtdDespesasPendentes;

  /// Saldo previsto do período (receitas − despesas previstas).
  int get saldoPrevistoPeriodo => receitasPrevistas - despesasPrevistas;

  /// Saldo já realizado no período (receitas − despesas efetivadas).
  int get saldoEfetivadoPeriodo => receitasEfetivadas - despesasEfetivadas;

  /// Percentual das receitas do período já recebidas (0..1).
  double get progressoReceitas =>
      receitasPrevistas == 0 ? 0 : receitasEfetivadas / receitasPrevistas;

  /// Percentual das despesas do período já pagas (0..1).
  double get progressoDespesas =>
      despesasPrevistas == 0 ? 0 : despesasEfetivadas / despesasPrevistas;

  static const ResumoFinanceiro vazio = ResumoFinanceiro();
}
