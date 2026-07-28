import 'package:intl/intl.dart';

/// Formatação de datas para exibição em português, sem depender da inicialização
/// assíncrona de dados de locale do `intl` (os nomes de meses são fixos aqui).
class Datas {
  const Datas._();

  static final DateFormat _ddMMyyyy = DateFormat('dd/MM/yyyy');

  static const List<String> meses = <String>[
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> mesesAbrev = <String>[
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  /// `24/07/2026`.
  static String curta(DateTime data) => _ddMMyyyy.format(data);

  /// `24/07/2026`, aceitando nulos.
  static String? curtaOuNull(DateTime? data) =>
      data == null ? null : curta(data);

  /// `24 de Julho de 2026`.
  static String extensa(DateTime data) =>
      '${data.day} de ${meses[data.month - 1]} de ${data.year}';

  /// `Julho de 2026` (rótulo de competência/mês).
  static String competencia(DateTime data) =>
      '${meses[data.month - 1]} de ${data.year}';

  /// `Jul/2026`.
  static String competenciaCurta(DateTime data) =>
      '${mesesAbrev[data.month - 1]}/${data.year}';

  /// Rótulo relativo amigável para vencimentos ("Hoje", "Amanhã", "Ontem")
  /// ou a data curta quando fora dessa janela.
  static String relativa(DateTime data, {DateTime? referencia}) {
    final DateTime hoje = _semHora(referencia ?? DateTime.now());
    final DateTime alvo = _semHora(data);
    final int dias = alvo.difference(hoje).inDays;
    if (dias == 0) return 'Hoje';
    if (dias == 1) return 'Amanhã';
    if (dias == -1) return 'Ontem';
    if (dias > 1 && dias <= 7) return 'Em $dias dias';
    if (dias < -1 && dias >= -7) return 'Há ${dias.abs()} dias';
    return curta(data);
  }

  static DateTime _semHora(DateTime data) =>
      DateTime(data.year, data.month, data.day);
}
