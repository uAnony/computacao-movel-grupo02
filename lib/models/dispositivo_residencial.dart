/// Contrato abstrato de qualquer entidade monitorada/controlada pelo
/// ecossistema de automação residencial (Tema 09).
///
/// Define o comportamento mínimo que toda especialização concreta
/// (Termostato, Lâmpada, Sensor de Presença, ...) deve implementar,
/// desacoplando a Central de Automação de detalhes de cada dispositivo.
abstract class DispositivoResidencial {
  final String id;
  final String nome;
  final String comodo;

  /// Apelido opcional definido pelo usuário (ex.: "Luz da mesa").
  /// Demonstra uso de tipo anulável (String?).
  String? apelido;

  bool _ligado;
  bool _online;

  DispositivoResidencial({
    required this.id,
    required this.nome,
    required this.comodo,
    bool ligadoInicial = false,
    bool onlineInicial = true,
    this.apelido,
  })  : _ligado = ligadoInicial,
        _online = onlineInicial;

  bool get ligado => _ligado;
  bool get online => _online;

  /// Nome de exibição: usa o apelido quando definido, senão o nome padrão.
  /// Demonstra o operador de coalescência de nulo (??).
  String get nomeExibicao => apelido ?? nome;

  /// Simula queda/retorno de conectividade do dispositivo na rede local
  /// (Wi-Fi/Zigbee), restrição típica de cenários de computação móvel/IoT.
  void definirConectividade(bool online) {
    _online = online;
  }

  /// Liga o dispositivo, validando conectividade antes de qualquer ação.
  void ligar() {
    _validarOnline();
    _ligado = true;
  }

  /// Desliga o dispositivo. Desligar é sempre permitido, mesmo offline,
  /// pois representa uma ação de segurança local (edge/on-device).
  void desligar() {
    _ligado = false;
  }

  /// Valida se o dispositivo está acessível antes de aceitar um comando.
  /// Lança [FalhaConectividadeException] via implementação concreta —
  /// mantido como método protegido de uso interno pelas subclasses.
  void _validarOnline() {
    if (!_online) {
      throw StateError(
        'Dispositivo $id ($nomeExibicao) está offline. Comando ignorado.',
      );
    }
  }

  /// Expõe a validação de conectividade para as subclasses, sem quebrar o
  /// encapsulamento do campo privado `_online`.
  void validarConectividadeParaComando() => _validarOnline();

  /// Contrato: cada dispositivo interpreta comandos de forma própria
  /// (ex.: "ajustar_temperatura", "ajustar_brilho", "calibrar").
  void aplicarComando(String comando, [Map<String, dynamic>? parametros]);

  /// Contrato: estimativa de consumo energético instantâneo em Watts,
  /// usada pela Central de Automação para relatórios agregados.
  double get consumoEstimadoWatts;

  @override
  String toString() =>
      'Dispositivo [ID: $id, Nome: $nomeExibicao, Cômodo: $comodo, '
      'Ligado: $_ligado, Online: $_online]';
}
