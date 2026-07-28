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
import '../../../models/movimento.dart';
import '../controllers/movimentos_controller.dart';

/// Formulário de cadastro/edição de um movimento (receita ou despesa).
class MovimentoFormScreen extends StatefulWidget {
  const MovimentoFormScreen({super.key, this.movimento, this.tipoInicial});

  final Movimento? movimento;
  final TipoLancamento? tipoInicial;

  bool get editando => movimento != null;

  @override
  State<MovimentoFormScreen> createState() => _MovimentoFormScreenState();
}

class _MovimentoFormScreenState extends State<MovimentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoriaRepo = CategoriaRepository();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _valorPagoController = TextEditingController();
  final _observacaoController = TextEditingController();

  late TipoLancamento _tipo;
  Categoria? _categoria;
  String? _categoriaErro;
  late DateTime _dataVencimento;
  bool _efetivado = false;
  DateTime? _dataPagamento;

  List<Categoria> _categorias = const [];
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movimento;
    _tipo = m?.tipo ?? widget.tipoInicial ?? TipoLancamento.despesa;
    _dataVencimento = m?.dataVencimento ?? DateTime.now();
    _efetivado = m?.status.isEfetivado ?? false;
    _dataPagamento = m?.dataPagamento;

    if (m != null) {
      _descricaoController.text = m.descricao;
      _valorController.text = MoedaInputFormatter.textoDeCentavos(m.valorPrevisto);
      _valorPagoController.text = MoedaInputFormatter.textoDeCentavos(
        m.valorPago ?? m.valorPrevisto,
      );
      _observacaoController.text = m.observacao ?? '';
    }
    _carregarCategorias(selecionarId: m?.categoriaId);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _valorPagoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias({int? selecionarId}) async {
    final ativas = await _categoriaRepo.listarAtivasPorTipo(_tipo);
    Categoria? selecionada;
    if (selecionarId != null) {
      selecionada = await _categoriaRepo.buscarPorId(selecionarId);
      // Garante que a categoria atual apareça na lista mesmo se inativa.
      if (selecionada != null && !ativas.any((c) => c.id == selecionada!.id)) {
        ativas.insert(0, selecionada);
      }
    }
    if (!mounted) return;
    setState(() {
      _categorias = ativas;
      _categoria = selecionada ??
          (_categoria != null
              ? ativas.firstWhere(
                  (c) => c.id == _categoria!.id,
                  orElse: () => _categoria!,
                )
              : null);
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

    final int valorPrevisto = MoedaInputFormatter.centavos(_valorController.text);
    final int valorPago = MoedaInputFormatter.centavos(_valorPagoController.text);
    final String obs = _observacaoController.text.trim();

    final movimento = Movimento(
      id: widget.movimento?.id,
      recorrenciaId: widget.movimento?.recorrenciaId,
      categoriaId: _categoria!.id!,
      tipo: _tipo,
      descricao: _descricaoController.text.trim(),
      dataVencimento: _dataVencimento,
      dataPagamento: _efetivado ? (_dataPagamento ?? DateTime.now()) : null,
      valorPrevisto: valorPrevisto,
      valorPago: _efetivado ? (valorPago > 0 ? valorPago : valorPrevisto) : null,
      status: _efetivado ? StatusMovimento.efetivado : StatusMovimento.pendente,
      origem: widget.movimento?.origem ?? OrigemMovimento.manual,
      observacao: obs.isEmpty ? null : obs,
    );

    setState(() => _salvando = true);
    final controller = context.read<MovimentosController>();
    final bool ok = await controller.salvar(movimento);
    if (!mounted) return;
    setState(() => _salvando = false);

    if (ok) {
      AppFeedback.sucesso(context, 'Movimento salvo com sucesso.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível salvar.');
    }
  }

  Future<void> _excluir() async {
    final id = widget.movimento?.id;
    if (id == null) return;
    final bool confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Excluir movimento',
      mensagem: 'Deseja realmente excluir "${widget.movimento!.descricao}"? '
          'Esta ação não pode ser desfeita.',
      textoConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmar || !mounted) return;

    final controller = context.read<MovimentosController>();
    final bool ok = await controller.excluir(id);
    if (!mounted) return;
    if (ok) {
      AppFeedback.sucesso(context, 'Movimento excluído.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível excluir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cor = AppColors.doTipo(_tipo);
    final String titulo = widget.editando
        ? 'Editar movimento'
        : (_tipo.isReceita ? 'Nova receita' : 'Nova despesa');

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
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
              hint: _tipo.isReceita ? 'Ex.: Salário' : 'Ex.: Conta de luz',
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
            const SizedBox(height: 16),
            CampoData(
              rotulo: 'Vencimento',
              obrigatorio: true,
              valor: _dataVencimento,
              onChanged: (d) => setState(() => _dataVencimento = d ?? _dataVencimento),
            ),
            const SizedBox(height: 20),
            CampoSwitch(
              titulo: _tipo.isReceita ? 'Já foi recebido' : 'Já foi pago',
              icone: Icons.check_circle_outline_rounded,
              cor: cor,
              valor: _efetivado,
              onChanged: (v) => setState(() {
                _efetivado = v;
                if (v && _dataPagamento == null) _dataPagamento = DateTime.now();
              }),
            ),
            if (_efetivado) ...[
              const SizedBox(height: 16),
              CampoData(
                rotulo: _tipo.isReceita ? 'Data do recebimento' : 'Data do pagamento',
                valor: _dataPagamento ?? DateTime.now(),
                onChanged: (d) => setState(() => _dataPagamento = d),
              ),
              const SizedBox(height: 16),
              CampoValor(
                rotulo: _tipo.isReceita ? 'Valor recebido' : 'Valor pago',
                controller: _valorPagoController,
                corDestaque: cor,
              ),
            ],
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
