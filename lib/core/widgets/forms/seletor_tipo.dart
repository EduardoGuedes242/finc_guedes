import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../theme/app_colors.dart';

/// Alternador segmentado entre Receita e Despesa.
class SeletorTipo extends StatelessWidget {
  const SeletorTipo({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  final TipoLancamento valor;
  final ValueChanged<TipoLancamento> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.superficieAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          _opcao(TipoLancamento.receita, Icons.south_west_rounded),
          _opcao(TipoLancamento.despesa, Icons.north_east_rounded),
        ],
      ),
    );
  }

  Widget _opcao(TipoLancamento tipo, IconData icone) {
    final bool selecionado = valor == tipo;
    final Color cor = AppColors.doTipo(tipo);
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tipo),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selecionado ? cor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                size: 18,
                color: selecionado ? Colors.white : AppColors.textoSuave,
              ),
              const SizedBox(width: 8),
              Text(
                tipo.label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: selecionado ? Colors.white : AppColors.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
