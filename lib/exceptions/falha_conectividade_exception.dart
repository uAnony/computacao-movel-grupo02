/// Exceção de domínio disparada quando um dispositivo residencial não
/// consegue processar um comando por restrição de conectividade
/// intermitente ou por nível crítico de bateria (sensores sem fio).
///
/// Implementa [Exception] (em vez de estender [Error]) porque representa
/// uma condição de operação previsível e recuperável — o app deve poder
/// capturá-la, enfileirar o comando e tentar novamente — e não um defeito
/// de programação.
class FalhaConectividadeException implements Exception {
  final String dispositivoId;
  final String mensagem;
  final int? nivelBateria;

  FalhaConectividadeException(
    this.dispositivoId,
    this.mensagem, {
    this.nivelBateria,
  });

  @override
  String toString() {
    final sufixoBateria =
        nivelBateria != null ? ' (Bateria: $nivelBateria%)' : '';
    return 'FalhaConectividadeException [Dispositivo: $dispositivoId]: '
        '$mensagem$sufixoBateria';
  }
}
