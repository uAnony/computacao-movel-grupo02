import '../exceptions/falha_conectividade_exception.dart';
import '../mixins/monitoramento_mixin.dart';
import 'dispositivo_residencial.dart';

/// Especialização concreta de [DispositivoResidencial] representando um
/// termostato inteligente. Aplica herança (`extends`) e composição de
/// comportamento transversal via mixin (`with`).
class Termostato extends DispositivoResidencial with MonitoramentoMixin {
  double _temperaturaAtual;
  double _temperaturaAlvo;
  final bool modoEconomico;

  static const double _temperaturaMinima = 10.0;
  static const double _temperaturaMaxima = 32.0;

  /// Construtor padrão gerativo, com açúcar sintático (`this.atributo`)
  /// para os campos herdados via `super.<param>` e inicializador para os
  /// campos privados desta classe.
  Termostato({
    required super.id,
    required super.nome,
    required super.comodo,
    required double temperaturaInicial,
    double? temperaturaAlvoInicial,
    this.modoEconomico = false,
    super.apelido,
  })  : _temperaturaAtual = temperaturaInicial,
        // Operador de coalescência de nulo: usa a temperatura inicial como
        // alvo quando nenhum valor de alvo é informado.
        _temperaturaAlvo = temperaturaAlvoInicial ?? temperaturaInicial;

  /// Construtor nomeado: cria um termostato já configurado em modo
  /// econômico, com alvo conservador de 19°C.
  Termostato.modoEconomico({
    required super.id,
    required super.comodo,
  })  : _temperaturaAtual = 22.0,
        _temperaturaAlvo = 19.0,
        modoEconomico = true,
        super(nome: 'Termostato Eco');

  /// Construtor de fábrica: valida e converte dados vindos de uma fonte
  /// externa (ex.: payload MQTT/REST persistido em cache local), lançando
  /// exceção customizada quando os dados estão fora dos limites físicos
  /// aceitáveis do domínio.
  factory Termostato.fromMap(Map<String, dynamic> map) {
    final temperaturaInicial =
        (map['temperaturaAtual'] as num?)?.toDouble() ?? _temperaturaMinima;

    if (temperaturaInicial < _temperaturaMinima ||
        temperaturaInicial > _temperaturaMaxima) {
      throw FalhaConectividadeException(
        map['id'] as String? ?? 'DESCONHECIDO',
        'Leitura de temperatura fora da faixa operacional '
        '($_temperaturaMinima°C a $_temperaturaMaxima°C).',
      );
    }

    return Termostato(
      id: map['id'] as String? ?? 'TERM-UNKNOWN',
      nome: map['nome'] as String? ?? 'Termostato',
      comodo: map['comodo'] as String? ?? 'Não informado',
      temperaturaInicial: temperaturaInicial,
      temperaturaAlvoInicial: (map['temperaturaAlvo'] as num?)?.toDouble(),
      modoEconomico: map['modoEconomico'] as bool? ?? false,
    );
  }

  double get temperaturaAtual => _temperaturaAtual;
  double get temperaturaAlvo => _temperaturaAlvo;

  /// Setter customizado com regra de validação de domínio: a temperatura
  /// alvo precisa respeitar os limites físicos do equipamento.
  set temperaturaAlvo(double novoValor) {
    if (novoValor < _temperaturaMinima || novoValor > _temperaturaMaxima) {
      throw ArgumentError(
        'Temperatura alvo inválida ($novoValor°C). '
        'Deve estar entre $_temperaturaMinima°C e $_temperaturaMaxima°C.',
      );
    }
    _temperaturaAlvo = novoValor;
  }

  @override
  void aplicarComando(String comando, [Map<String, dynamic>? parametros]) {
    validarConectividadeParaComando();
    switch (comando) {
      case 'ligar':
        ligar();
        registrarEvento('Termostato $nomeExibicao ligado.');
        break;
      case 'desligar':
        desligar();
        registrarEvento('Termostato $nomeExibicao desligado.');
        break;
      case 'ajustar_temperatura':
        final alvo = (parametros?['temperatura'] as num?)?.toDouble();
        if (alvo == null) {
          throw ArgumentError(
            'Comando ajustar_temperatura requer o parâmetro "temperatura".',
          );
        }
        temperaturaAlvo = alvo;
        registrarEvento(
          'Temperatura alvo de $nomeExibicao ajustada para $alvo°C.',
        );
        break;
      default:
        throw ArgumentError('Comando não reconhecido: $comando');
    }
  }

  /// Simula a variação natural de temperatura em direção ao alvo,
  /// representando o "tick" de um loop de sensoriamento do app móvel.
  void simularCicloDeAjuste() {
    if (!ligado) return;
    if (_temperaturaAtual < _temperaturaAlvo) {
      _temperaturaAtual += 0.5;
    } else if (_temperaturaAtual > _temperaturaAlvo) {
      _temperaturaAtual -= 0.5;
    }
  }

  @override
  double get consumoEstimadoWatts {
    if (!ligado) return 0.0;
    final delta = (_temperaturaAlvo - _temperaturaAtual).abs();
    final base = modoEconomico ? 40.0 : 90.0;
    return base + (delta * 15);
  }

  @override
  String toString() =>
      '${super.toString()} - Tipo: Termostato | Atual: $_temperaturaAtual°C '
      '-> Alvo: $_temperaturaAlvo°C | Eco: $modoEconomico';
}
