/// Mixin transversal que adiciona capacidade de auditoria/log a qualquer
/// dispositivo residencial, sem exigir uma hierarquia de herança comum.
///
/// Aplicado via `with` nas classes concretas (ex.: [Termostato], [Lampada],
/// [SensorPresenca]), o que evita duplicação de código entre entidades que
/// não compartilham um ancestral direto além de [DispositivoResidencial].
mixin MonitoramentoMixin {
  /// Histórico interno de eventos registrados por este dispositivo.
  final List<String> _historicoEventos = [];

  /// Expõe o histórico como lista somente-leitura (evita mutação externa).
  List<String> get historicoEventos => List.unmodifiable(_historicoEventos);

  /// Registra um evento de auditoria com timestamp ISO-8601, simulando o
  /// log local que, em um app real, alimentaria uma fila de sincronização
  /// (relevante para o cenário de conectividade intermitente).
  void registrarEvento(String mensagem) {
    final timestamp = DateTime.now().toIso8601String();
    final entrada = '[AUDITORIA - $timestamp]: $mensagem';
    _historicoEventos.add(entrada);
    print(entrada);
  }
}
