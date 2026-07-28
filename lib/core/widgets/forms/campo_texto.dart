import 'package:flutter/material.dart';

import 'campo_form.dart';

/// Campo de texto rotulado, padronizado com o tema do app (equivalente ao
/// `EditInforvix`, porém integrado a [Form]/validação e ao tema global).
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.controller,
    this.hint,
    this.obrigatorio = false,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.textInputAction,
    this.onSubmitted,
  });

  final String rotulo;
  final TextEditingController controller;
  final String? hint;
  final bool obrigatorio;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CampoRotulado(
      rotulo: rotulo,
      obrigatorio: obrigatorio,
      campo: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          counterText: '',
        ),
      ),
    );
  }
}
