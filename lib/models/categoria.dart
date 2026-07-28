import 'enums.dart';

/// Representa uma linha da tabela `CATEGORIAS`.
class Categoria {
  const Categoria({
    this.id,
    required this.nome,
    required this.tipo,
    this.cor,
    this.icone,
    this.ativo = true,
  });

  /// `ID integer PRIMARY KEY AUTOINCREMENT` (nulo antes de inserir).
  final int? id;

  /// `NOME text NOT NULL`.
  final String nome;

  /// `TIPO char(1) NOT NULL`.
  final TipoLancamento tipo;

  /// `COR text` — cor em formato hexadecimal (ex.: `#0377F2`).
  final String? cor;

  /// `ICONE text` — chave do ícone no catálogo do app.
  final String? icone;

  /// `ATIVO integer NOT NULL DEFAULT 1`.
  final bool ativo;

  bool get isReceita => tipo.isReceita;
  bool get isDespesa => tipo.isDespesa;

  factory Categoria.fromMap(Map<String, Object?> map) {
    return Categoria(
      id: map['ID'] as int?,
      nome: map['NOME'] as String,
      tipo: TipoLancamento.fromCode(map['TIPO'] as String),
      cor: map['COR'] as String?,
      icone: map['ICONE'] as String?,
      ativo: (map['ATIVO'] as int? ?? 1) == 1,
    );
  }

  Categoria copyWith({
    int? id,
    String? nome,
    TipoLancamento? tipo,
    String? cor,
    String? icone,
    bool? ativo,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  bool operator ==(Object other) => other is Categoria && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
