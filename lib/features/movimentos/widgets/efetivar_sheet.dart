import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/moeda.dart';
import '../../../core/widgets/forms/campo_data.dart';
import '../../../core/widgets/forms/campo_valor.dart';
import '../../../models/movimento.dart';

/// Resultado da efetivação: data e valor confirmados.
typedef DadosEfetivacao = ({DateTime data, int valor});

/// Abre um bottom sheet para confirmar a efetivação (pagamento/recebimento) de
/// um movimento, permitindo ajustar a data e o valor.
Future<DadosEfetivacao?> mostrarEfetivarSheet(
  BuildContext context,
  Movimento movimento,
) {
  return showModalBottomSheet<DadosEfetivacao>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EfetivarSheet(movimento: movimento),
  );
}

class _EfetivarSheet extends StatefulWidget {
  const _EfetivarSheet({required this.movimento});

  final Movimento movimento;

  @override
  State<_EfetivarSheet> createState() => _EfetivarSheetState();
}

class _EfetivarSheetState extends State<_EfetivarSheet> {
  late final TextEditingController _valorController;
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(
      text: MoedaInputFormatter.textoDeCentavos(
        widget.movimento.valorPago ?? widget.movimento.valorPrevisto,
      ),
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  void _confirmar() {
    final int valor = MoedaInputFormatter.centavos(_valorController.text);
    Navigator.of(context).pop((data: _data, valor: valor));
  }

  @override
  Widget build(BuildContext context) {
    final bool receita = widget.movimento.isReceita;
    final Color cor = AppColors.doTipo(widget.movimento.tipo);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borda,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              receita ? 'Confirmar recebimento' : 'Confirmar pagamento',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              widget.movimento.descricao,
              style: const TextStyle(color: AppColors.textoSuave, fontSize: 14),
            ),
            const SizedBox(height: 20),
            CampoData(
              rotulo: 'Data',
              valor: _data,
              onChanged: (d) => setState(() => _data = d ?? _data),
            ),
            const SizedBox(height: 16),
            CampoValor(
              rotulo: receita ? 'Valor recebido' : 'Valor pago',
              controller: _valorController,
              corDestaque: cor,
            ),
            const SizedBox(height: 24),
            ButtonInforvix(
              title: 'Confirmar',
              color: cor,
              width: double.infinity,
              paddingTop: 0,
              onClick: _confirmar,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
