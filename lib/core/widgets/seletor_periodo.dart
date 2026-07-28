import 'package:flutter/material.dart';

import '../../models/periodo.dart';
import '../theme/app_colors.dart';

/// Navegador de período mensal: setas para mês anterior/seguinte e rótulo
/// central tocável que abre um seletor de mês.
class SeletorPeriodo extends StatelessWidget {
  const SeletorPeriodo({
    super.key,
    required this.periodo,
    required this.onMudar,
  });

  final Periodo periodo;
  final ValueChanged<Periodo> onMudar;

  Future<void> _selecionarMes(BuildContext context) async {
    final DateTime agora = DateTime.now();
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: periodo.inicio,
      firstDate: DateTime(agora.year - 5),
      lastDate: DateTime(agora.year + 6, 12, 31),
      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Selecione um mês',
    );
    if (escolhida != null) {
      onMudar(Periodo.mes(escolhida.year, escolhida.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          _seta(
            icone: Icons.chevron_left_rounded,
            onTap: () => onMudar(periodo.mesAnterior()),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _selecionarMes(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 17, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      periodo.descricao,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _seta(
            icone: Icons.chevron_right_rounded,
            onTap: () => onMudar(periodo.mesSeguinte()),
          ),
        ],
      ),
    );
  }

  Widget _seta({required IconData icone, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icone, color: AppColors.textoSuave),
      ),
    );
  }
}
