import 'package:intl/intl.dart';

/// Conversões entre tipos Dart e as representações textuais/inteiras usadas
/// pelo SQLite neste projeto.
///
/// Convenções adotadas para as colunas `text` de data:
/// - Datas simples (vencimento, pagamento, início, fim): `yyyy-MM-dd`.
/// - Carimbos de tempo (CRIADO_EM / ALTERADO_EM): `yyyy-MM-dd HH:mm:ss`,
///   mesmo formato produzido por `CURRENT_TIMESTAMP` do SQLite.
class DbConvert {
  const DbConvert._();

  static final DateFormat _date = DateFormat('yyyy-MM-dd');
  static final DateFormat _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Formata apenas a data (sem hora) para texto `yyyy-MM-dd`.
  static String date(DateTime value) => _date.format(_dateOnly(value));

  /// Idem, aceitando nulos.
  static String? dateOrNull(DateTime? value) =>
      value == null ? null : date(value);

  /// Faz o parse de uma data textual `yyyy-MM-dd`.
  static DateTime parseDate(String value) => _date.parseStrict(value);

  /// Idem, aceitando nulos/vazios.
  static DateTime? parseDateOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    // Aceita tanto "yyyy-MM-dd" quanto "yyyy-MM-dd HH:mm:ss".
    return DateTime.parse(value.replaceFirst(' ', 'T'));
  }

  /// Carimbo de tempo atual em `yyyy-MM-dd HH:mm:ss`.
  static String nowTimestamp() => _timestamp.format(DateTime.now());

  /// Converte booleano para inteiro (0/1) usado nas colunas `ATIVO`,
  /// `GERAR_ANTECIPADO`, etc.
  static int boolToInt(bool value) => value ? 1 : 0;

  /// Converte inteiro (0/1) do banco para booleano.
  static bool intToBool(Object? value) => (value as int? ?? 0) == 1;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
