import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../ui/categoria_visual.dart';

/// Avatar arredondado que representa uma categoria: um ícone colorido sobre um
/// fundo suave na mesma cor. Usado em listas, tiles e no dashboard.
class CategoriaAvatar extends StatelessWidget {
  const CategoriaAvatar({
    super.key,
    this.cor,
    this.icone,
    this.tamanho = 44,
  });

  final String? cor;
  final String? icone;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final Color base = CategoriaVisual.cor(cor);
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: AppColors.suave(base, 0.14),
        borderRadius: BorderRadius.circular(tamanho * 0.3),
      ),
      child: Icon(
        CategoriaVisual.icone(icone),
        color: base,
        size: tamanho * 0.5,
      ),
    );
  }
}
