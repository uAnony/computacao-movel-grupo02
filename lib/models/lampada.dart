import '../mixins/monitoramento_mixin.dart';
import 'dispositivo_residencial.dart';

/// Especialização concreta representando uma lâmpada inteligente (RGB +
/// brilho ajustável), aplicando herança e o mesmo mixin de auditoria.
class Lampada extends DispositivoResidencial with MonitoramentoMixin {
  int _brilhoPercentual;
  String cor;

  Lampada({
    required super.id,
    required super.nome,
    required super.comodo,
    int brilhoInicial = 100,
    this.cor = '#FFFFFF',
    super.apelido,
  }) : _brilhoPercentual = brilhoInicial.clamp(0, 100).toInt();

  /// Construtor nomeado: cria uma lâmpada já pré-configurada para o modo
  /// noturno (brilho baixo, tom quente).
  Lampada.noturna({
    required super.id,
    required super.comodo,
  })  : _brilhoPercentual = 15,
        cor = '#FFB347',
        super(nome: 'Lâmpada Noturna');

  /// Construtor de fábrica a partir de um Map (ex.: estado persistido em
  /// cache local / resposta de API do hub residencial).
  factory Lampada.fromMap(Map<String, dynamic> map) {
    return Lampada(
      id: map['id'] as String? ?? 'LAMP-UNKNOWN',
      nome: map['nome'] as String? ?? 'Lâmpada',
      comodo: map['comodo'] as String? ?? 'Não informado',
      brilhoInicial: map['brilho'] as int? ?? 100,
      cor: map['cor'] as String? ?? '#FFFFFF',
    );
  }

  int get brilhoPercentual => _brilhoPercentual;

  set brilhoPercentual(int valor) {
    if (valor < 0 || valor > 100) {
      throw ArgumentError('Brilho inválido ($valor%). Deve ser entre 0 e 100.');
    }
    _brilhoPercentual = valor;
  }

  @override
  void aplicarComando(String comando, [Map<String, dynamic>? parametros]) {
    validarConectividadeParaComando();
    switch (comando) {
      case 'ligar':
        ligar();
        registrarEvento('Lâmpada $nomeExibicao ligada.');
        break;
      case 'desligar':
        desligar();
        registrarEvento('Lâmpada $nomeExibicao desligada.');
        break;
      case 'ajustar_brilho':
        final novoBrilho = parametros?['brilho'] as int?;
        if (novoBrilho == null) {
          throw ArgumentError(
            'Comando ajustar_brilho requer o parâmetro "brilho".',
          );
        }
        brilhoPercentual = novoBrilho;
        registrarEvento('Brilho de $nomeExibicao ajustado para $novoBrilho%.');
        break;
      case 'ajustar_cor':
        final novaCor = parametros?['cor'] as String?;
        if (novaCor == null) {
          throw ArgumentError('Comando ajustar_cor requer o parâmetro "cor".');
        }
        cor = novaCor;
        registrarEvento('Cor de $nomeExibicao ajustada para $novaCor.');
        break;
      default:
        throw ArgumentError('Comando não reconhecido: $comando');
    }
  }

  @override
  double get consumoEstimadoWatts {
    if (!ligado) return 0.0;
    // Lâmpada LED: consumo máximo de 9W, proporcional ao brilho.
    return 9.0 * (_brilhoPercentual / 100);
  }

  @override
  String toString() =>
      '${super.toString()} - Tipo: Lâmpada | Brilho: $_brilhoPercentual% | '
      'Cor: $cor';
}
