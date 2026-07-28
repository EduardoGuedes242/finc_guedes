/// Definição do schema do banco SQLite.
///
/// As instruções abaixo reproduzem FIELMENTE o arquivo `ESTRUTURA_BANCO.txt`
/// existente na raiz do projeto. Nenhuma tabela nova é criada e nenhuma coluna
/// é alterada. As instruções ficam separadas (uma por comando) porque o
/// `sqflite` executa apenas um comando por chamada de `execute`.
///
/// A ordem de criação respeita as dependências de chave estrangeira:
/// CATEGORIAS -> RECORRENCIAS -> MOVIMENTOS, seguidas dos índices.
class DatabaseSchema {
  const DatabaseSchema._();

  /// Versão do schema. Incrementar apenas em migrações futuras.
  static const int version = 1;

  static const String _createCategorias = '''
CREATE TABLE CATEGORIAS (
  ID     integer PRIMARY KEY AUTOINCREMENT,
  NOME   text NOT NULL,
  TIPO   char(1) NOT NULL,
  COR    text,
  ICONE  text,
  ATIVO  integer NOT NULL DEFAULT 1,
  CHECK (TIPO IN ('E','S'))
)''';

  static const String _createRecorrencias = '''
CREATE TABLE RECORRENCIAS (
  ID                         integer PRIMARY KEY AUTOINCREMENT,
  CATEGORIA_ID               integer NOT NULL,
  TIPO                       char(1) NOT NULL,
  DESCRICAO                  text NOT NULL,
  VALOR_PREVISTO             integer NOT NULL,
  DIA_VENCIMENTO             integer NOT NULL,
  DATA_INICIO                text NOT NULL,
  DATA_FIM                   text,
  ATIVO                      integer NOT NULL DEFAULT 1,
  GERAR_ANTECIPADO           integer NOT NULL DEFAULT 0,
  ULTIMA_COMPETENCIA_GERADA  text,
  OBSERVACAO                 text,
  CHECK (TIPO IN ('E','S')),
  CHECK (DIA_VENCIMENTO BETWEEN 1 AND 31),
  FOREIGN KEY (CATEGORIA_ID)
    REFERENCES CATEGORIAS(ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)''';

  static const String _createMovimentos = '''
CREATE TABLE MOVIMENTOS (
  ID               integer PRIMARY KEY AUTOINCREMENT,
  RECORRENCIA_ID   integer,
  CATEGORIA_ID     integer NOT NULL,
  TIPO             char(1) NOT NULL,
  DESCRICAO        text NOT NULL,
  DATA_VENCIMENTO  text NOT NULL,
  DATA_PAGAMENTO   text,
  VALOR_PREVISTO   integer NOT NULL,
  VALOR_PAGO       integer,
  STATUS           integer NOT NULL DEFAULT 0,
  ORIGEM           integer NOT NULL DEFAULT 0,
  OBSERVACAO       text,
  CRIADO_EM        text NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ALTERADO_EM      text,
  CHECK (TIPO IN ('E','S')),
  FOREIGN KEY (RECORRENCIA_ID)
    REFERENCES RECORRENCIAS(ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (CATEGORIA_ID)
    REFERENCES CATEGORIAS(ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)''';

  static const String _idxCategoriasTipo =
      'CREATE INDEX IDX_CATEGORIAS_TIPO ON CATEGORIAS (TIPO)';

  static const String _idxMovimentosCategoria =
      'CREATE INDEX IDX_MOVIMENTOS_CATEGORIA ON MOVIMENTOS (CATEGORIA_ID)';

  static const String _idxMovimentosData =
      'CREATE INDEX IDX_MOVIMENTOS_DATA ON MOVIMENTOS (DATA_VENCIMENTO)';

  static const String _idxMovimentosRecorrencia =
      'CREATE INDEX IDX_MOVIMENTOS_RECORRENCIA ON MOVIMENTOS (RECORRENCIA_ID)';

  static const String _idxMovimentosStatus =
      'CREATE INDEX IDX_MOVIMENTOS_STATUS ON MOVIMENTOS (STATUS)';

  static const String _idxRecorrenciasAtivo =
      'CREATE INDEX IDX_RECORRENCIAS_ATIVO ON RECORRENCIAS (ATIVO)';

  /// Todas as instruções de criação, na ordem correta de execução.
  static const List<String> createStatements = <String>[
    _createCategorias,
    _createRecorrencias,
    _createMovimentos,
    _idxCategoriasTipo,
    _idxMovimentosCategoria,
    _idxMovimentosData,
    _idxMovimentosRecorrencia,
    _idxMovimentosStatus,
    _idxRecorrenciasAtivo,
  ];
}
