import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/categoria_visual.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/categoria_avatar.dart';
import '../../../core/widgets/forms/campo_form.dart';
import '../../../core/widgets/forms/campo_texto.dart';
import '../../../core/widgets/forms/seletor_tipo.dart';
import '../../../models/categoria.dart';
import '../../../models/enums.dart';
import '../controllers/categorias_controller.dart';

/// Formulário de cadastro/edição de categoria.
class CategoriaFormScreen extends StatefulWidget {
  const CategoriaFormScreen({super.key, this.categoria, this.tipoInicial});

  final Categoria? categoria;
  final TipoLancamento? tipoInicial;

  bool get editando => categoria != null;

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  late TipoLancamento _tipo;
  late String _cor;
  late String _icone;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.categoria;
    _tipo = c?.tipo ?? widget.tipoInicial ?? TipoLancamento.despesa;
    _cor = c?.cor ?? CategoriaVisual.cores.first;
    _icone = c?.icone ?? CategoriaVisual.chavesIcones.first;
    _nomeController.text = c?.nome ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final categoria = Categoria(
      id: widget.categoria?.id,
      nome: _nomeController.text.trim(),
      tipo: _tipo,
      cor: _cor,
      icone: _icone,
      ativo: widget.categoria?.ativo ?? true,
    );

    setState(() => _salvando = true);
    final controller = context.read<CategoriasController>();
    final bool ok = await controller.salvar(categoria);
    if (!mounted) return;
    setState(() => _salvando = false);

    if (ok) {
      AppFeedback.sucesso(context, 'Categoria salva.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível salvar.');
    }
  }

  Future<void> _excluir() async {
    final id = widget.categoria?.id;
    if (id == null) return;
    final bool confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Excluir categoria',
      mensagem:
          'Deseja excluir "${widget.categoria!.nome}"? Categorias em uso não '
          'podem ser excluídas — nesse caso, desative-a.',
      textoConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmar || !mounted) return;

    final controller = context.read<CategoriasController>();
    final bool ok = await controller.excluir(id);
    if (!mounted) return;
    if (ok) {
      AppFeedback.sucesso(context, 'Categoria excluída.');
      Navigator.of(context).pop(true);
    } else {
      AppFeedback.erro(context, controller.erro ?? 'Não foi possível excluir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cor = CategoriaVisual.cor(_cor);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar categoria' : 'Nova categoria'),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Center(
              child: Column(
                children: [
                  CategoriaAvatar(cor: _cor, icone: _icone, tamanho: 76),
                  const SizedBox(height: 10),
                  Text(
                    _nomeController.text.trim().isEmpty
                        ? 'Prévia'
                        : _nomeController.text.trim(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SeletorTipo(
              valor: _tipo,
              onChanged: (t) => setState(() => _tipo = t),
            ),
            const SizedBox(height: 20),
            CampoTexto(
              rotulo: 'Nome',
              controller: _nomeController,
              obrigatorio: true,
              hint: 'Ex.: Mercado',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              onSubmitted: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            const RotuloCampo('Cor'),
            _SeletorCor(
              selecionada: _cor,
              onSelecionar: (c) => setState(() => _cor = c),
            ),
            const SizedBox(height: 20),
            const RotuloCampo('Ícone'),
            _SeletorIcone(
              cor: cor,
              selecionado: _icone,
              onSelecionar: (i) => setState(() => _icone = i),
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

class _SeletorCor extends StatelessWidget {
  const _SeletorCor({required this.selecionada, required this.onSelecionar});

  final String selecionada;
  final ValueChanged<String> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: CategoriaVisual.cores.map((hex) {
        final bool sel = hex == selecionada;
        final Color cor = AppColors.fromHex(hex);
        return GestureDetector(
          onTap: () => onSelecionar(hex),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor,
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? AppColors.texto : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: sel
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _SeletorIcone extends StatelessWidget {
  const _SeletorIcone({
    required this.cor,
    required this.selecionado,
    required this.onSelecionar,
  });

  final Color cor;
  final String selecionado;
  final ValueChanged<String> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: CategoriaVisual.chavesIcones.map((chave) {
        final bool sel = chave == selecionado;
        return GestureDetector(
          onTap: () => onSelecionar(chave),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: sel ? AppColors.suave(cor, 0.16) : AppColors.superficie,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? cor : AppColors.borda,
                width: sel ? 1.6 : 1,
              ),
            ),
            child: Icon(
              CategoriaVisual.icone(chave),
              color: sel ? cor : AppColors.textoSuave,
              size: 22,
            ),
          ),
        );
      }).toList(),
    );
  }
}
