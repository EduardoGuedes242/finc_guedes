import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Catálogo de ícones e cores usados nas categorias.
///
/// As categorias guardam apenas uma *chave* de ícone (coluna `ICONE`) e uma cor
/// hexadecimal (coluna `COR`). Este catálogo traduz essas chaves em
/// [IconData]/[Color] e oferece as opções disponíveis para os seletores.
class CategoriaVisual {
  const CategoriaVisual._();

  static const IconData iconePadrao = Icons.category_rounded;

  static const Map<String, IconData> icones = <String, IconData>{
    'salario': Icons.payments_rounded,
    'trabalho': Icons.work_rounded,
    'investimento': Icons.trending_up_rounded,
    'vendas': Icons.sell_rounded,
    'presente': Icons.card_giftcard_rounded,
    'bonus': Icons.stars_rounded,
    'casa': Icons.home_rounded,
    'aluguel': Icons.vpn_key_rounded,
    'alimentacao': Icons.restaurant_rounded,
    'mercado': Icons.shopping_cart_rounded,
    'transporte': Icons.directions_car_rounded,
    'combustivel': Icons.local_gas_station_rounded,
    'saude': Icons.favorite_rounded,
    'farmacia': Icons.medical_services_rounded,
    'educacao': Icons.school_rounded,
    'lazer': Icons.sports_esports_rounded,
    'viagem': Icons.flight_takeoff_rounded,
    'restaurante': Icons.local_cafe_rounded,
    'contas': Icons.receipt_long_rounded,
    'luz': Icons.lightbulb_rounded,
    'agua': Icons.water_drop_rounded,
    'internet': Icons.wifi_rounded,
    'celular': Icons.smartphone_rounded,
    'assinaturas': Icons.subscriptions_rounded,
    'cartao': Icons.credit_card_rounded,
    'banco': Icons.account_balance_rounded,
    'academia': Icons.fitness_center_rounded,
    'pet': Icons.pets_rounded,
    'roupas': Icons.checkroom_rounded,
    'presentes': Icons.redeem_rounded,
    'impostos': Icons.gavel_rounded,
    'outros': Icons.category_rounded,
  };

  /// Cores sugeridas para o seletor de cor da categoria.
  static const List<String> cores = <String>[
    '#0377F2', '#003472', '#0AA307', '#10B981', '#14B8A6', '#22C55E',
    '#3B82F6', '#6C63FF', '#8B5CF6', '#EC4899', '#EF4444', '#CF0D0D',
    '#F59E0B', '#F97316', '#64748B', '#0F172A',
  ];

  /// Chaves de ícone disponíveis para o seletor.
  static List<String> get chavesIcones => icones.keys.toList();

  /// Resolve a chave em um [IconData]; usa um ícone padrão se desconhecida.
  static IconData icone(String? chave) => icones[chave] ?? iconePadrao;

  /// Resolve a cor da categoria (hex) em [Color].
  static Color cor(String? hex, {Color fallback = AppColors.primary}) =>
      AppColors.fromHex(hex, fallback: fallback);
}
