import 'recorrencia.dart';

/// Projeção de leitura que combina uma [Recorrencia] com os dados de exibição
/// da sua categoria (via `JOIN` com `CATEGORIAS`).
class RecorrenciaComCategoria {
  const RecorrenciaComCategoria({
    required this.recorrencia,
    required this.categoriaNome,
    this.categoriaCor,
    this.categoriaIcone,
  });

  final Recorrencia recorrencia;
  final String categoriaNome;
  final String? categoriaCor;
  final String? categoriaIcone;

  factory RecorrenciaComCategoria.fromMap(Map<String, Object?> map) {
    return RecorrenciaComCategoria(
      recorrencia: Recorrencia.fromMap(map),
      categoriaNome: (map['CAT_NOME'] as String?) ?? 'Sem categoria',
      categoriaCor: map['CAT_COR'] as String?,
      categoriaIcone: map['CAT_ICONE'] as String?,
    );
  }
}
