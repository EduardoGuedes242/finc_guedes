import '../../core/utils/db_convert.dart';
import '../../models/categoria.dart';

/// SQL centralizado da tabela `CATEGORIAS`.
///
/// Todas as instruções são explícitas e parametrizadas com `?`. Os métodos
/// `*Args` montam a lista de argumentos na mesma ordem dos `?` do comando
/// correspondente, facilitando a auditoria e futuras otimizações.
class CategoriaSql {
  const CategoriaSql._();

  static const String selectAll = '''
SELECT ID, NOME, TIPO, COR, ICONE, ATIVO
FROM CATEGORIAS
ORDER BY NOME COLLATE NOCASE''';

  static const String selectAtivas = '''
SELECT ID, NOME, TIPO, COR, ICONE, ATIVO
FROM CATEGORIAS
WHERE ATIVO = 1
ORDER BY NOME COLLATE NOCASE''';

  /// Categorias ativas de um determinado tipo ('E' ou 'S').
  static const String selectAtivasPorTipo = '''
SELECT ID, NOME, TIPO, COR, ICONE, ATIVO
FROM CATEGORIAS
WHERE ATIVO = 1 AND TIPO = ?
ORDER BY NOME COLLATE NOCASE''';

  static const String selectById = '''
SELECT ID, NOME, TIPO, COR, ICONE, ATIVO
FROM CATEGORIAS
WHERE ID = ?''';

  static const String insert = '''
INSERT INTO CATEGORIAS (NOME, TIPO, COR, ICONE, ATIVO)
VALUES (?, ?, ?, ?, ?)''';

  static List<Object?> insertArgs(Categoria c) => <Object?>[
        c.nome,
        c.tipo.code,
        c.cor,
        c.icone,
        DbConvert.boolToInt(c.ativo),
      ];

  static const String update = '''
UPDATE CATEGORIAS
SET NOME = ?, TIPO = ?, COR = ?, ICONE = ?, ATIVO = ?
WHERE ID = ?''';

  static List<Object?> updateArgs(Categoria c) => <Object?>[
        c.nome,
        c.tipo.code,
        c.cor,
        c.icone,
        DbConvert.boolToInt(c.ativo),
        c.id,
      ];

  static const String delete = 'DELETE FROM CATEGORIAS WHERE ID = ?';

  /// Quantos movimentos referenciam a categoria (para bloquear exclusão).
  static const String contarMovimentos =
      'SELECT COUNT(*) AS TOTAL FROM MOVIMENTOS WHERE CATEGORIA_ID = ?';

  /// Quantas recorrências referenciam a categoria.
  static const String contarRecorrencias =
      'SELECT COUNT(*) AS TOTAL FROM RECORRENCIAS WHERE CATEGORIA_ID = ?';
}
