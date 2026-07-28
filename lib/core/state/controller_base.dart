import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';

/// Base para os controllers (padrão Notifier via [ChangeNotifier]).
///
/// Centraliza o estado de carregamento/erro e oferece utilitários para
/// executar operações assíncronas notificando a UI de forma consistente.
abstract class ControllerBase extends ChangeNotifier {
  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  bool _descartado = false;

  /// Executa um carregamento de dados atualizando o estado de loading/erro.
  @protected
  Future<void> carregarComEstado(Future<void> Function() acao) async {
    _carregando = true;
    _erro = null;
    _notificar();
    try {
      await acao();
    } catch (e) {
      _erro = _mensagemDe(e);
    } finally {
      _carregando = false;
      _notificar();
    }
  }

  /// Executa uma ação de escrita. Retorna `true` em caso de sucesso; em caso de
  /// falha, preenche [erro] e retorna `false` (para a UI exibir a mensagem).
  @protected
  Future<bool> executarAcao(Future<void> Function() acao) async {
    _erro = null;
    try {
      await acao();
      return true;
    } catch (e) {
      _erro = _mensagemDe(e);
      _notificar();
      return false;
    }
  }

  String _mensagemDe(Object e) =>
      e is AppException ? e.mensagem : 'Ocorreu um erro inesperado.';

  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
