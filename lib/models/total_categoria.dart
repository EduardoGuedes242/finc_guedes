/// Total agregado por categoria dentro de um período (usado nos gráficos do
/// dashboard). [total] está em centavos.
class TotalCategoria {
  const TotalCategoria({
    required this.categoriaId,
    required this.nome,
    this.cor,
    this.icone,
    required this.total,
    required this.quantidade,
  });

  final int categoriaId;
  final String nome;
  final String? cor;
  final String? icone;
  final int total;
  final int quantidade;

  factory TotalCategoria.fromMap(Map<String, Object?> map) {
    return TotalCategoria(
      categoriaId: map['CATEGORIA_ID'] as int,
      nome: (map['CAT_NOME'] as String?) ?? 'Sem categoria',
      cor: map['CAT_COR'] as String?,
      icone: map['CAT_ICONE'] as String?,
      total: (map['TOTAL'] as int?) ?? 0,
      quantidade: (map['QUANTIDADE'] as int?) ?? 0,
    );
  }
}
