import 'package:flutter/material.dart';
import 'package:inforvix_ux/ui/cores.dart';

import '../../models/enums.dart';

/// Cores semânticas do app, ancoradas na paleta oficial da Inforvix
/// ([PaletaCores]) e estendidas com tons de apoio para uma interface moderna.
class AppColors {
  const AppColors._();

  // Marca
  static const Color primary = PaletaCores.azulClaro; // #0377F2
  static const Color primaryDark = PaletaCores.azulEscuro; // #003472

  // Semânticas financeiras
  static const Color receita = PaletaCores.verde; // #0AA307
  static const Color despesa = PaletaCores.vermelho; // #CF0D0D
  static const Color alerta = Color(0xFFF59E0B);

  // Neutros / superfícies (tema claro)
  static const Color fundo = Color(0xFFF3F5F9);
  static const Color superficie = Colors.white;
  static const Color superficieAlt = Color(0xFFF8FAFC);
  static const Color texto = PaletaCores.preto; // #1E1E1E
  static const Color textoSuave = Color(0xFF6B7280);
  static const Color textoLeve = Color(0xFF9AA3AF);
  static const Color borda = Color(0xFFE6E9EF);

  /// Cor associada ao tipo do lançamento.
  static Color doTipo(TipoLancamento tipo) =>
      tipo.isReceita ? receita : despesa;

  /// Converte uma cor hexadecimal (`#RRGGBB` ou `#AARRGGBB`) em [Color].
  /// Retorna [fallback] quando o valor é nulo ou inválido.
  static Color fromHex(String? hex, {Color fallback = primary}) {
    if (hex == null || hex.isEmpty) return fallback;
    String valor = hex.replaceFirst('#', '').trim();
    if (valor.length == 6) valor = 'FF$valor';
    final int? intVal = int.tryParse(valor, radix: 16);
    if (intVal == null) return fallback;
    return Color(intVal);
  }

  /// Versão suave (fundo) de uma cor, para chips e ícones.
  static Color suave(Color cor, [double opacidade = 0.12]) =>
      cor.withValues(alpha: opacidade);
}
