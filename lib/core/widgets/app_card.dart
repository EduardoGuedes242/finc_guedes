import 'package:flutter/material.dart';

/// Contêiner padronizado (Card com borda e cantos arredondados do tema),
/// com espaçamento interno configurável e suporte a toque.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final Widget conteudo = Padding(padding: padding, child: child);
    return Card(
      color: color,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: onTap == null
          ? conteudo
          : InkWell(onTap: onTap, child: conteudo),
    );
  }
}
