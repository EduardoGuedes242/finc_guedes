import '../core/utils/db_convert.dart';
import 'enums.dart';

/// Representa uma linha da tabela `RECORRENCIAS` (conta recorrente).
class Recorrencia {
  const Recorrencia({
    this.id,
    required this.categoriaId,
    required this.tipo,
    required this.descricao,
    required this.valorPrevisto,
    required this.diaVencimento,
    required this.dataInicio,
    this.dataFim,
    this.ativo = true,
    this.gerarAntecipado = false,
    this.ultimaCompetenciaGerada,
    this.observacao,
  });

  final int? id;
  final int categoriaId;
  final TipoLancamento tipo;
  final String descricao;

  /// Valor previsto em centavos.
  final int valorPrevisto;

  /// Dia do vencimento (1 a 31). Meses curtos são ajustados na geração.
  final int diaVencimento;

  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool ativo;

  /// Quando verdadeiro, gera a competência do próximo mês antecipadamente.
  final bool gerarAntecipado;

  /// Primeiro dia da última competência (mês) já gerada. Nulo se nunca gerou.
  final DateTime? ultimaCompetenciaGerada;

  final String? observacao;

  bool get isReceita => tipo.isReceita;
  bool get isDespesa => tipo.isDespesa;

  factory Recorrencia.fromMap(Map<String, Object?> map) {
    return Recorrencia(
      id: map['ID'] as int?,
      categoriaId: map['CATEGORIA_ID'] as int,
      tipo: TipoLancamento.fromCode(map['TIPO'] as String),
      descricao: map['DESCRICAO'] as String,
      valorPrevisto: map['VALOR_PREVISTO'] as int,
      diaVencimento: map['DIA_VENCIMENTO'] as int,
      dataInicio: DbConvert.parseDate(map['DATA_INICIO'] as String),
      dataFim: DbConvert.parseDateOrNull(map['DATA_FIM'] as String?),
      ativo: (map['ATIVO'] as int? ?? 1) == 1,
      gerarAntecipado: (map['GERAR_ANTECIPADO'] as int? ?? 0) == 1,
      ultimaCompetenciaGerada:
          DbConvert.parseDateOrNull(map['ULTIMA_COMPETENCIA_GERADA'] as String?),
      observacao: map['OBSERVACAO'] as String?,
    );
  }

  Recorrencia copyWith({
    int? id,
    int? categoriaId,
    TipoLancamento? tipo,
    String? descricao,
    int? valorPrevisto,
    int? diaVencimento,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool limparDataFim = false,
    bool? ativo,
    bool? gerarAntecipado,
    DateTime? ultimaCompetenciaGerada,
    bool limparUltimaCompetencia = false,
    String? observacao,
  }) {
    return Recorrencia(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valorPrevisto: valorPrevisto ?? this.valorPrevisto,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: limparDataFim ? null : (dataFim ?? this.dataFim),
      ativo: ativo ?? this.ativo,
      gerarAntecipado: gerarAntecipado ?? this.gerarAntecipado,
      ultimaCompetenciaGerada: limparUltimaCompetencia
          ? null
          : (ultimaCompetenciaGerada ?? this.ultimaCompetenciaGerada),
      observacao: observacao ?? this.observacao,
    );
  }
}
