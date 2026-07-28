import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Helpers para trabalhar com valores monetários.
///
/// IMPORTANTE: no banco os valores (`VALOR_PREVISTO`, `VALOR_PAGO`, etc.) são
/// armazenados como **inteiros em centavos**, evitando erros de ponto
/// flutuante. Toda a conversão entre centavos e a exibição em reais passa por
/// esta classe.
class Moeda {
  const Moeda._();

  static final NumberFormat _brl =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);

  static final NumberFormat _semSimbolo =
      NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

  /// Formata centavos como moeda brasileira: `123456` -> `R$ 1.234,56`.
  static String format(int centavos) => _brl.format(centavos / 100);

  /// Formata centavos sem o símbolo `R$`: `123456` -> `1.234,56`.
  static String formatSemSimbolo(int centavos) =>
      _semSimbolo.format(centavos / 100).trim();

  /// Formata com sinal explícito conforme entrada/saída.
  static String formatComSinal(int centavos, {required bool positivo}) {
    final String prefixo = positivo ? '+ ' : '- ';
    return '$prefixo${format(centavos.abs())}';
  }

  /// Converte reais (double) para centavos (int), arredondando.
  static int reaisParaCentavos(double reais) => (reais * 100).round();

  /// Converte centavos para reais (double).
  static double centavosParaReais(int centavos) => centavos / 100;
}

/// Formata a entrada de texto de um campo monetário tratando os dígitos
/// digitados como centavos: digitar `1`, `2`, `3`, `4` resulta em `12,34`.
///
/// O valor em centavos pode ser obtido com [centavos].
class MoedaInputFormatter extends TextInputFormatter {
  MoedaInputFormatter({this.maxDigitos = 12});

  /// Limite de dígitos para evitar overflow visual.
  final int maxDigitos;

  static final NumberFormat _formato =
      NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > maxDigitos) {
      digitos = digitos.substring(0, maxDigitos);
    }
    if (digitos.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final int valorCentavos = int.parse(digitos);
    final String texto = _formato.format(valorCentavos / 100).trim();

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  /// Extrai o valor em centavos de um texto já formatado.
  static int centavos(String texto) {
    final String digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return 0;
    return int.parse(digitos);
  }

  /// Monta o texto formatado a partir de um valor em centavos (para edição).
  static String textoDeCentavos(int centavos) {
    if (centavos == 0) return '';
    return _formato.format(centavos / 100).trim();
  }
}
