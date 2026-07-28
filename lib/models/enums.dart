/// Enumerações de domínio, com os respectivos códigos persistidos no banco.
///
/// Os códigos correspondem exatamente aos valores definidos em
/// `ESTRUTURA_BANCO.txt` (colunas TIPO, STATUS e ORIGEM).
library;

/// Tipo do lançamento financeiro.
///
/// Persistido na coluna `TIPO char(1)` com `CHECK (TIPO IN ('E','S'))`.
enum TipoLancamento {
  /// Entrada de dinheiro (receita).
  receita('E', 'Receita'),

  /// Saída de dinheiro (despesa).
  despesa('S', 'Despesa');

  const TipoLancamento(this.code, this.label);

  /// Código de 1 caractere gravado no banco.
  final String code;

  /// Rótulo amigável para exibição.
  final String label;

  bool get isReceita => this == TipoLancamento.receita;
  bool get isDespesa => this == TipoLancamento.despesa;

  static TipoLancamento fromCode(String code) {
    return TipoLancamento.values.firstWhere(
      (tipo) => tipo.code == code,
      orElse: () => throw ArgumentError('TIPO inválido: "$code"'),
    );
  }
}

/// Situação de um movimento.
///
/// Persistido na coluna `STATUS integer NOT NULL DEFAULT 0`.
enum StatusMovimento {
  /// Ainda não pago/recebido.
  pendente(0, 'Pendente'),

  /// Efetivado (pago quando despesa, recebido quando receita).
  efetivado(1, 'Efetivado'),

  /// Cancelado — mantido para histórico, desconsiderado nos totais.
  cancelado(2, 'Cancelado');

  const StatusMovimento(this.code, this.label);

  final int code;
  final String label;

  bool get isPendente => this == StatusMovimento.pendente;
  bool get isEfetivado => this == StatusMovimento.efetivado;
  bool get isCancelado => this == StatusMovimento.cancelado;

  static StatusMovimento fromCode(int code) {
    return StatusMovimento.values.firstWhere(
      (status) => status.code == code,
      orElse: () => StatusMovimento.pendente,
    );
  }
}

/// Origem de um movimento.
///
/// Persistido na coluna `ORIGEM integer NOT NULL DEFAULT 0`.
enum OrigemMovimento {
  /// Cadastrado manualmente pelo usuário.
  manual(0, 'Manual'),

  /// Gerado automaticamente a partir de uma recorrência.
  recorrencia(1, 'Recorrência');

  const OrigemMovimento(this.code, this.label);

  final int code;
  final String label;

  bool get isRecorrencia => this == OrigemMovimento.recorrencia;

  static OrigemMovimento fromCode(int code) {
    return OrigemMovimento.values.firstWhere(
      (origem) => origem.code == code,
      orElse: () => OrigemMovimento.manual,
    );
  }
}
