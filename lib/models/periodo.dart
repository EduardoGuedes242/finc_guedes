import '../core/utils/datas.dart';
import '../core/utils/db_convert.dart';

/// Intervalo de datas usado nos filtros e no dashboard.
///
/// [inicio] e [fim] são inclusivos (datas sem hora).
class Periodo {
  Periodo({required DateTime inicio, required DateTime fim, this.rotulo})
      : inicio = DateTime(inicio.year, inicio.month, inicio.day),
        fim = DateTime(fim.year, fim.month, fim.day);

  final DateTime inicio;
  final DateTime fim;

  /// Rótulo opcional para exibição (ex.: "Julho de 2026").
  final String? rotulo;

  /// Mês de referência (do primeiro ao último dia).
  factory Periodo.mes(int ano, int mes) {
    final DateTime inicio = DateTime(ano, mes, 1);
    final DateTime fim = DateTime(ano, mes + 1, 0);
    return Periodo(inicio: inicio, fim: fim, rotulo: Datas.competencia(inicio));
  }

  /// Mês atual.
  factory Periodo.mesAtual() {
    final DateTime agora = DateTime.now();
    return Periodo.mes(agora.year, agora.month);
  }

  /// Ano inteiro.
  factory Periodo.ano(int ano) {
    return Periodo(
      inicio: DateTime(ano, 1, 1),
      fim: DateTime(ano, 12, 31),
      rotulo: 'Ano de $ano',
    );
  }

  /// Intervalo livre entre duas datas.
  factory Periodo.intervalo(DateTime inicio, DateTime fim) {
    return Periodo(
      inicio: inicio,
      fim: fim,
      rotulo: '${Datas.curta(inicio)} – ${Datas.curta(fim)}',
    );
  }

  /// Mês anterior ao deste período.
  Periodo mesAnterior() {
    final DateTime alvo = DateTime(inicio.year, inicio.month - 1, 1);
    return Periodo.mes(alvo.year, alvo.month);
  }

  /// Mês seguinte ao deste período.
  Periodo mesSeguinte() {
    final DateTime alvo = DateTime(inicio.year, inicio.month + 1, 1);
    return Periodo.mes(alvo.year, alvo.month);
  }

  /// Verdadeiro quando o período cobre exatamente um mês calendário.
  bool get ehMesCompleto =>
      inicio.day == 1 &&
      fim.day == DateTime(fim.year, fim.month + 1, 0).day &&
      inicio.year == fim.year &&
      inicio.month == fim.month;

  String get inicioIso => DbConvert.date(inicio);
  String get fimIso => DbConvert.date(fim);

  String get descricao => rotulo ?? '${Datas.curta(inicio)} – ${Datas.curta(fim)}';
}
