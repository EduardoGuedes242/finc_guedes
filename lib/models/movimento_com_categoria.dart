import 'movimento.dart';

/// Projeção de leitura que combina um [Movimento] com os dados de exibição da
/// sua categoria (obtidos via `JOIN` com a tabela `CATEGORIAS`).
///
/// Usada nas listagens para evitar consultas adicionais por linha.
class MovimentoComCategoria {
  const MovimentoComCategoria({
    required this.movimento,
    required this.categoriaNome,
    this.categoriaCor,
    this.categoriaIcone,
  });

  final Movimento movimento;
  final String categoriaNome;
  final String? categoriaCor;
  final String? categoriaIcone;

  /// Faz o parse de uma linha do `JOIN`. As colunas da categoria vêm com os
  /// aliases `CAT_NOME`, `CAT_COR` e `CAT_ICONE` para não colidir com as
  /// colunas de `MOVIMENTOS`.
  factory MovimentoComCategoria.fromMap(Map<String, Object?> map) {
    return MovimentoComCategoria(
      movimento: Movimento.fromMap(map),
      categoriaNome: (map['CAT_NOME'] as String?) ?? 'Sem categoria',
      categoriaCor: map['CAT_COR'] as String?,
      categoriaIcone: map['CAT_ICONE'] as String?,
    );
  }
}
