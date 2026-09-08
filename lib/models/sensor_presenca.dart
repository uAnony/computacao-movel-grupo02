import '../exceptions/falha_conectividade_exception.dart';
import '../mixins/monitoramento_mixin.dart';
import 'dispositivo_residencial.dart';

/// Especialização concreta representando um sensor de presença/movimento
/// alimentado por bateria — ilustra a restrição de hardware "energia"
/// típica de dispositivos móveis/IoT, além de conectividade.
class SensorPresenca extends DispositivoResidencial with MonitoramentoMixin {
  int _nivelBateria;
  bool _presencaDetectada;

  static const int _limiarBateriaCritica = 15;

  // Observação: como o valor de `ligadoInicial` é fixo (sensores de
  // presença ficam sempre monitorando), este construtor usa parâmetros
  // comuns + chamada explícita a `super(...)`, em vez de super-parâmetros
  // (`super.id`), pois as duas formas não podem ser combinadas na mesma
  // lista de inicialização.
  SensorPresenca({
    required super.id,
    required super.nome,
    required super.comodo,
    required int nivelBateriaInicial,
    super.apelido,
  })  : _nivelBateria = nivelBateriaInicial,
        _presencaDetectada = false,
        super(
          ligadoInicial: true,
        );

  /// Construtor nomeado: sensor recém-instalado, com bateria em 100%.
  SensorPresenca.novo({
    required super.id,
    required super.comodo,
  })  : _nivelBateria = 100,
        _presencaDetectada = false,
        super(nome: 'Sensor de Presença', ligadoInicial: true);

  /// Construtor de fábrica: valida a leitura recebida do hardware antes de
  /// instanciar o objeto de domínio, lançando exceção customizada quando o
  /// dispositivo já chega com bateria criticamente baixa.
  factory SensorPresenca.fromMap(Map<String, dynamic> map) {
    final bateria = map['bateria'] as int? ?? 100;
    final id = map['id'] as String? ?? 'SENS-UNKNOWN';

    if (bateria <= 0) {
      throw FalhaConectividadeException(
        id,
        'Sensor sem carga operacional, impossível inicializar.',
        nivelBateria: bateria,
      );
    }

    return SensorPresenca(
      id: id,
      nome: map['nome'] as String? ?? 'Sensor de Presença',
      comodo: map['comodo'] as String? ?? 'Não informado',
      nivelBateriaInicial: bateria,
    );
  }

  int get nivelBateria => _nivelBateria;
  bool get presencaDetectada => _presencaDetectada;

  /// Simula uma leitura periódica do sensor. Lança
  /// [FalhaConectividadeException] quando a bateria está em nível crítico
  /// ou o dispositivo está offline, exigindo tratamento pelo chamador.
  bool simularLeitura({required bool presencaSimulada}) {
    validarConectividadeParaComando();

    if (_nivelBateria <= _limiarBateriaCritica) {
      registrarEvento(
        'ALERTA: bateria crítica ($_nivelBateria%) durante leitura.',
      );
      throw FalhaConectividadeException(
        id,
        'Bateria crítica — leitura não confiável.',
        nivelBateria: _nivelBateria,
      );
    }

    // Cada leitura drena um pouco da bateria (simulação simplificada).
    _nivelBateria = (_nivelBateria - 1).clamp(0, 100).toInt();
    _presencaDetectada = presencaSimulada;
    registrarEvento(
      'Leitura realizada: presença=$presencaSimulada, bateria=$_nivelBateria%.',
    );
    return _presencaDetectada;
  }

  @override
  void aplicarComando(String comando, [Map<String, dynamic>? parametros]) {
    validarConectividadeParaComando();
    switch (comando) {
      case 'recalibrar':
        registrarEvento('Sensor $nomeExibicao recalibrado.');
        break;
      case 'desligar':
        desligar();
        registrarEvento('Sensor $nomeExibicao desligado manualmente.');
        break;
      case 'ligar':
        ligar();
        registrarEvento('Sensor $nomeExibicao reativado.');
        break;
      default:
        throw ArgumentError('Comando não reconhecido: $comando');
    }
  }

  @override
  double get consumoEstimadoWatts => ligado ? 0.5 : 0.0;

  @override
  String toString() =>
      '${super.toString()} - Tipo: Sensor de Presença | Bateria: '
      '$_nivelBateria% | Última leitura: $_presencaDetectada';
}
