import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/moeda.dart';
import 'campo_form.dart';

/// Campo de entrada de valor monetário. Os dígitos digitados são interpretados
/// como centavos e formatados automaticamente (ex.: `1234` -> `1.234,00`).
///
/// O valor em centavos é lido com [MoedaInputFormatter.centavos] a partir do
/// texto do [controller].
class CampoValor extends StatelessWidget {
  const CampoValor({
    super.key,
    required this.rotulo,
    required this.controller,
    this.obrigatorio = true,
    this.corDestaque,
  });

  final String rotulo;
  final TextEditingController controller;
  final bool obrigatorio;

  /// Cor aplicada ao prefixo "R$" e ao texto (ex.: verde para receita).
  final Color? corDestaque;

  @override
  Widget build(BuildContext context) {
    final Color cor = corDestaque ?? AppColors.texto;
    return CampoRotulado(
      rotulo: rotulo,
      obrigatorio: obrigatorio,
      campo: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [MoedaInputFormatter()],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: cor,
        ),
        validator: (_) {
          if (!obrigatorio) return null;
          return MoedaInputFormatter.centavos(controller.text) <= 0
              ? 'Informe um valor'
              : null;
        },
        decoration: InputDecoration(
          hintText: '0,00',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Text(
              r'R$',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}
