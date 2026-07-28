import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Rótulo padrão exibido acima dos campos de formulário, no mesmo estilo dos
/// componentes `EditInforvix` da biblioteca inforvix_ux.
class RotuloCampo extends StatelessWidget {
  const RotuloCampo(this.texto, {super.key, this.obrigatorio = false});

  final String texto;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: RichText(
        text: TextSpan(
          text: texto,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.texto,
          ),
          children: obrigatorio
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.despesa),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

/// Caixa tocável com a mesma aparência de um campo de input, usada por
/// seletores que abrem pickers (data, categoria, etc.).
class CaixaCampo extends StatelessWidget {
  const CaixaCampo({
    super.key,
    required this.child,
    this.onTap,
    this.erro,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    final bool temErro = erro != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: temErro ? AppColors.despesa : AppColors.borda,
                ),
              ),
              child: child,
            ),
          ),
        ),
        if (temErro)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              erro!,
              style: const TextStyle(color: AppColors.despesa, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Agrupa um [RotuloCampo] com o campo abaixo, com espaçamento padrão.
class CampoRotulado extends StatelessWidget {
  const CampoRotulado({
    super.key,
    required this.rotulo,
    required this.campo,
    this.obrigatorio = false,
  });

  final String rotulo;
  final Widget campo;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloCampo(rotulo, obrigatorio: obrigatorio),
        campo,
      ],
    );
  }
}
