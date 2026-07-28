import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../theme/app_colors.dart';
import '../utils/moeda.dart';

/// Exibe um valor monetário (em centavos) já formatado, com cor e sinal
/// opcionais conforme o tipo do lançamento.
class ValorTexto extends StatelessWidget {
  const ValorTexto(
    this.centavos, {
    super.key,
    this.tipo,
    this.comSinal = false,
    this.tamanho = 16,
    this.peso = FontWeight.w700,
    this.cor,
  });

  final int centavos;
  final TipoLancamento? tipo;
  final bool comSinal;
  final double tamanho;
  final FontWeight peso;

  /// Cor explícita; quando ausente, deriva do [tipo] (ou usa o texto padrão).
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final Color corFinal =
        cor ?? (tipo == null ? AppColors.texto : AppColors.doTipo(tipo!));

    final String texto = comSinal && tipo != null
        ? Moeda.formatComSinal(centavos, positivo: tipo!.isReceita)
        : Moeda.format(centavos);

    return Text(
      texto,
      style: TextStyle(
        fontSize: tamanho,
        fontWeight: peso,
        color: corFinal,
        letterSpacing: -0.2,
      ),
    );
  }
}
