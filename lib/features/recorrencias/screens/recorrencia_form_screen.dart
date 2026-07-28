import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/moeda.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/forms/campo_data.dart';
import '../../../core/widgets/forms/campo_switch.dart';
import '../../../core/widgets/forms/campo_texto.dart';
import '../../../core/widgets/forms/campo_valor.dart';
import '../../../core/widgets/forms/seletor_categoria.dart';
import '../../../core/widgets/forms/seletor_tipo.dart';
import '../../../data/repositories/categoria_repository.dart';
import '../../../models/categoria.dart';
import '../../../models/enums.dart';
import '../../../models/recorrencia.dart';
import '../controllers/recorrencias_controller.dart';

/// Formulário de cadastro/edição de conta recorrente.
class RecorrenciaFormScreen extends StatefulWidget {
  const RecorrenciaFormScreen({super.key, this.recorrencia, this.tipoInicial});

  final Recorrencia? recorrencia;
  final TipoLancamento? tipoInicial;

  bool get editando => recorrencia != null;

  @override
  State<RecorrenciaFormScreen> createState() => _RecorrenciaFormScreenState();
}

class _RecorrenciaFormScreenState extends State<RecorrenciaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoriaRepo = CategoriaRepository();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();

  late TipoLancamento _tipo;
  Categoria? _categoria;
  String? _categoriaErro;
  late int _diaVencimento;
  late DateTime _dataInicio;
  DateTime? _dataFim;
  bool _gerarAntecipado = false;
  bool _salvando = false;

  List<Categoria> _categorias = const [];

  @override
  void initState() {
    super.initState();
    final r = widget.recorrencia;
    _tipo = r?.tipo ?? widget.tipoInicial ?? TipoLancamento.despesa;
    _diaVencimento = r?.diaVencimento ?? DateTime.now().day;
    _dataInicio = r?.dataInicio ?? DateTime.now();
    _dataFim = r?.dataFim;
    _gerarAntecipado = r?.gerarAntecipado ?? false;

    if (r != null) {
      _descricaoController.text = r.descricao;
      _valorController.text = MoedaInputFormatter.textoDeCentavos(r.valorPrevisto);
      _observacaoController.text = r.observacao ?? '';
    }
    _carregarCategorias(selecionarId: r?.categoriaId);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias({int? selecionarId}) async {
    final ativas = await _categoriaRepo.listarAtivasPorTipo(_tipo);
    Categoria? selecionada;
    if (selecionarId != null) {
      selecionada = await _categoriaRepo.buscarPorId(selecionarId);
      if (selecionada != null && !ativas.any((c) => c.id == selecionada!.id)) {
        ativas.insert(0, selecionada);
      }
    }
    if (!mounted) return;
    setState(() {
      _categorias = ativas;
      _categoria = selecionada ?? _categoria;
      if (_categoria != null && _categoria!.tipo != _tipo) _categoria = null;
    });
  }

  void _mudarTipo(TipoLancamento tipo) {
    if (tipo == _tipo) return;
    setState(() {
      _tipo = tipo;
      _categoria = null;
    });
    _carregarCategorias();
  }

  Future<void> _salvar() async {
    final bool formOk = _formKey.currentState?.validate() ?? false;
    setState(() => _categoriaErro = _categoria == null ? 'Selecione a categoria' : null);
    if (!formOk || _categoria == null) return;

    if (_dataFim != null && _dataFim!.isBefore(_dataInicio)) {
      AppFeedback.erro(context, 'A data fim deve ser posterior à data início.');
      return;
    }

    final String obs = _observacaoController.text.trim();
    final recorrencia = Recorrencia(
      id: widget.recorrencia?.id,
      categoriaId: _categoria!.id!,
      tipo: _tipo,
      descricao: _descricaoController.text.trim(),
      valorPrevisto: MoedaInputFormatter.centavos(_valorController.text),
      diaVencimento: _diaVencimento,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      ativo: widget.recorrencia?.ativo ?? true,
      gerarAntecipado: _gerarAntecipado,
      // Preserva a última competência gerada para não duplicar movimentos.
      ultimaCompetenciaGerada: widget.recorrencia?.ultimaCompetenciaGerada,
      observacao: obs.isEmpty ? null : obs,
    );

    setState(() => _salvando = true);
    final controller = context.read<RecorrenciasController>();
    final bool ok = await controller.salvar(recorrencia);
    if (!mounted) return;
    setState(() => _salvando = false);

    if (ok) {
      AppFeedback.sucesso(context, 'Recorrência salva. Movimentos gerados.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível salvar.');
    }
  }

  Future<void> _excluir() async {
    final id = widget.recorrencia?.id;
    if (id == null) return;
    final bool confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Excluir recorrência',
      mensagem: 'Isto remove os lançamentos pendentes futuros gerados por ela. '
          'O histórico já efetivado é mantido. Continuar?',
      textoConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmar || !mounted) return;

    final controller = context.read<RecorrenciasController>();
    final bool ok = await controller.excluir(id);
    if (!mounted) return;
    if (ok) {
      AppFeedback.sucesso(context, 'Recorrência excluída.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível excluir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cor = AppColors.doTipo(_tipo);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar recorrência' : 'Nova recorrência'),
        actions: [
          if (widget.editando)
            IconButton(
              tooltip: 'Excluir',
              onPressed: _salvando ? null : _excluir,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.despesa),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SeletorTipo(valor: _tipo, onChanged: _mudarTipo),
            const SizedBox(height: 20),
            CampoTexto(
              rotulo: 'Descrição',
              controller: _descricaoController,
              obrigatorio: true,
              hint: _tipo.isReceita ? 'Ex.: Salário' : 'Ex.: Aluguel',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 16),
            CampoValor(
              rotulo: 'Valor',
              controller: _valorController,
              corDestaque: cor,
            ),
            const SizedBox(height: 16),
            SeletorCategoria(
              rotulo: 'Categoria',
              categorias: _categorias,
              selecionada: _categoria,
              erro: _categoriaErro,
              onSelecionar: (c) => setState(() {
                _categoria = c;
                _categoriaErro = null;
              }),
            ),
            const SizedBox(height: 4),
            // Componente da biblioteca inforvix_ux para seleção do dia.
            Combobox(
              title: 'Dia do vencimento',
              hintText: 'Selecione o dia',
              selectedValue: '$_diaVencimento',
              options: List<String>.generate(31, (i) => '${i + 1}'),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _diaVencimento = int.parse(valor));
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoData(
                    rotulo: 'Início',
                    obrigatorio: true,
                    valor: _dataInicio,
                    onChanged: (d) =>
                        setState(() => _dataInicio = d ?? _dataInicio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoData(
                    rotulo: 'Fim (opcional)',
                    valor: _dataFim,
                    permiteLimpar: true,
                    primeiraData: _dataInicio,
                    onChanged: (d) => setState(() => _dataFim = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            CampoSwitch(
              titulo: 'Gerar antecipadamente',
              subtitulo: 'Cria o lançamento do próximo mês com um mês de '
                  'antecedência.',
              icone: Icons.update_rounded,
              cor: cor,
              valor: _gerarAntecipado,
              onChanged: (v) => setState(() => _gerarAntecipado = v),
            ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'Observação',
              controller: _observacaoController,
              hint: 'Opcional',
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            ButtonInforvix(
              title: _salvando ? 'Salvando...' : 'Salvar',
              color: cor,
              width: double.infinity,
              paddingTop: 0,
              onClick: () {
                if (!_salvando) _salvar();
              },
            ),
          ],
        ),
      ),
    );
  }
}
