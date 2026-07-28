import '../core/utils/db_convert.dart';
import 'enums.dart';

/// Representa uma linha da tabela `MOVIMENTOS`.
///
/// Valores monetários (`VALOR_PREVISTO` / `VALOR_PAGO`) são inteiros em
/// **centavos**. Datas são armazenadas como texto no banco e expostas aqui
/// como [DateTime].
class Movimento {
  const Movimento({
    this.id,
    this.recorrenciaId,
    required this.categoriaId,
    required this.tipo,
    required this.descricao,
    required this.dataVencimento,
    this.dataPagamento,
    required this.valorPrevisto,
    this.valorPago,
    this.status = StatusMovimento.pendente,
    this.origem = OrigemMovimento.manual,
    this.observacao,
    this.criadoEm,
    this.alteradoEm,
  });

  final int? id;
  final int? recorrenciaId;
  final int categoriaId;
  final TipoLancamento tipo;
  final String descricao;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;

  /// Valor previsto em centavos.
  final int valorPrevisto;

  /// Valor efetivamente pago/recebido em centavos (nulo enquanto pendente).
  final int? valorPago;

  final StatusMovimento status;
  final OrigemMovimento origem;
  final String? observacao;
  final DateTime? criadoEm;
  final DateTime? alteradoEm;

  bool get isReceita => tipo.isReceita;
  bool get isDespesa => tipo.isDespesa;
  bool get isEfetivado => status.isEfetivado;
  bool get isPendente => status.isPendente;
  bool get isRecorrente => origem.isRecorrencia;

  /// Valor a considerar na exibição: o pago quando efetivado, senão o previsto.
  int get valorEfetivo =>
      status.isEfetivado ? (valorPago ?? valorPrevisto) : valorPrevisto;

  /// Está em atraso: pendente e com vencimento anterior a hoje.
  bool estaAtrasado({DateTime? referencia}) {
    if (!status.isPendente) return false;
    final DateTime hoje = referencia ?? DateTime.now();
    final DateTime venc = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
    );
    final DateTime base = DateTime(hoje.year, hoje.month, hoje.day);
    return venc.isBefore(base);
  }

  factory Movimento.fromMap(Map<String, Object?> map) {
    return Movimento(
      id: map['ID'] as int?,
      recorrenciaId: map['RECORRENCIA_ID'] as int?,
      categoriaId: map['CATEGORIA_ID'] as int,
      tipo: TipoLancamento.fromCode(map['TIPO'] as String),
      descricao: map['DESCRICAO'] as String,
      dataVencimento: DbConvert.parseDate(map['DATA_VENCIMENTO'] as String),
      dataPagamento: DbConvert.parseDateOrNull(map['DATA_PAGAMENTO'] as String?),
      valorPrevisto: map['VALOR_PREVISTO'] as int,
      valorPago: map['VALOR_PAGO'] as int?,
      status: StatusMovimento.fromCode(map['STATUS'] as int? ?? 0),
      origem: OrigemMovimento.fromCode(map['ORIGEM'] as int? ?? 0),
      observacao: map['OBSERVACAO'] as String?,
      criadoEm: DbConvert.parseDateOrNull(map['CRIADO_EM'] as String?),
      alteradoEm: DbConvert.parseDateOrNull(map['ALTERADO_EM'] as String?),
    );
  }

  Movimento copyWith({
    int? id,
    int? recorrenciaId,
    bool limparRecorrencia = false,
    int? categoriaId,
    TipoLancamento? tipo,
    String? descricao,
    DateTime? dataVencimento,
    DateTime? dataPagamento,
    bool limparDataPagamento = false,
    int? valorPrevisto,
    int? valorPago,
    bool limparValorPago = false,
    StatusMovimento? status,
    OrigemMovimento? origem,
    String? observacao,
    DateTime? criadoEm,
    DateTime? alteradoEm,
  }) {
    return Movimento(
      id: id ?? this.id,
      recorrenciaId:
          limparRecorrencia ? null : (recorrenciaId ?? this.recorrenciaId),
      categoriaId: categoriaId ?? this.categoriaId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      dataPagamento:
          limparDataPagamento ? null : (dataPagamento ?? this.dataPagamento),
      valorPrevisto: valorPrevisto ?? this.valorPrevisto,
      valorPago: limparValorPago ? null : (valorPago ?? this.valorPago),
      status: status ?? this.status,
      origem: origem ?? this.origem,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
      alteradoEm: alteradoEm ?? this.alteradoEm,
    );
  }
}
