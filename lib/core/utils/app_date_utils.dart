/// Utilidades de data específicas do domínio financeiro.
///
/// Concentram a lógica de "competência" (mês/ano de referência) e o cálculo
/// do dia de vencimento com tratamento de meses curtos (ex.: dia 31 em
/// fevereiro é ajustado para o último dia do mês).
class AppDateUtils {
  const AppDateUtils._();

  /// Retorna a data sem componente de horário.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Primeiro dia do mês da [data] (competência).
  static DateTime firstDayOfMonth(DateTime data) =>
      DateTime(data.year, data.month, 1);

  /// Último dia do mês da [data].
  static DateTime lastDayOfMonth(DateTime data) =>
      DateTime(data.year, data.month + 1, 0);

  /// Quantidade de dias no mês da [data].
  static int daysInMonth(DateTime data) => lastDayOfMonth(data).day;

  /// Avança [meses] a partir do primeiro dia do mês de [data].
  static DateTime addMonths(DateTime data, int meses) =>
      DateTime(data.year, data.month + meses, 1);

  /// Competência (primeiro dia do mês) seguinte à de [data].
  static DateTime nextCompetencia(DateTime data) => addMonths(data, 1);

  /// Verifica se duas datas pertencem ao mesmo mês/ano.
  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// Calcula a data de vencimento dentro da competência [competencia],
  /// respeitando o [diaVencimento] cadastrado e ajustando para o último dia
  /// do mês quando o dia não existe (ex.: 30/31 em fevereiro).
  static DateTime vencimentoNaCompetencia(
    DateTime competencia,
    int diaVencimento,
  ) {
    final int ultimoDia = daysInMonth(competencia);
    final int dia = diaVencimento > ultimoDia ? ultimoDia : diaVencimento;
    return DateTime(competencia.year, competencia.month, dia);
  }
}
