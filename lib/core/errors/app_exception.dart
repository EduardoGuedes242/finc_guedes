/// Exceção de domínio com mensagem amigável para exibição ao usuário.
class AppException implements Exception {
  const AppException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}
