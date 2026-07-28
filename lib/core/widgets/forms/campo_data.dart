import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/datas.dart';
import 'campo_form.dart';

/// Seletor de data rotulado. Exibe a data selecionada e abre um `DatePicker`
/// ao toque. Quando [permiteLimpar] é verdadeiro, mostra um botão para limpar.
class CampoData extends StatelessWidget {
  const CampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.onChanged,
    this.obrigatorio = false,
    this.hint = 'Selecione a data',
    this.primeiraData,
    this.ultimaData,
    this.permiteLimpar = false,
    this.erro,
  });

  final String rotulo;
  final DateTime? valor;
  final ValueChanged<DateTime?> onChanged;
  final bool obrigatorio;
  final String hint;
  final DateTime? primeiraData;
  final DateTime? ultimaData;
  final bool permiteLimpar;
  final String? erro;

  Future<void> _selecionar(BuildContext context) async {
    final DateTime agora = DateTime.now();
    final DateTime inicial = valor ?? agora;
    final DateTime primeira = primeiraData ?? DateTime(agora.year - 5);
    final DateTime ultima = ultimaData ?? DateTime(agora.year + 6);
    final DateTime inicialAjustada = inicial.isBefore(primeira)
        ? primeira
        : (inicial.isAfter(ultima) ? ultima : inicial);

    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: inicialAjustada,
      firstDate: primeira,
      lastDate: ultima,
      locale: const Locale('pt', 'BR'),
    );
    if (escolhida != null) onChanged(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final bool temValor = valor != null;
    return CampoRotulado(
      rotulo: rotulo,
      obrigatorio: obrigatorio,
      campo: CaixaCampo(
        erro: erro,
        onTap: () => _selecionar(context),
        child: Row(
          children: [
            const Icon(Icons.event_rounded,
                size: 20, color: AppColors.textoSuave),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                temValor ? Datas.curta(valor!) : hint,
                style: TextStyle(
                  fontSize: 15,
                  color: temValor ? AppColors.texto : AppColors.textoLeve,
                  fontWeight: temValor ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (permiteLimpar && temValor)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textoLeve),
              ),
          ],
        ),
      ),
    );
  }
}
