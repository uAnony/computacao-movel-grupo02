import 'package:automacao_residencial/exceptions/falha_conectividade_exception.dart';
import 'package:automacao_residencial/models/dispositivo_residencial.dart';
import 'package:automacao_residencial/models/lampada.dart';
import 'package:automacao_residencial/models/sensor_presenca.dart';
import 'package:automacao_residencial/models/termostato.dart';
import 'package:automacao_residencial/services/central_automacao_residencial.dart';

/// Executável de demonstração (Requisito 4) do módulo de domínio de
/// Automação e Monitoramento de Dispositivos Residenciais (Tema 09).
///
/// Não depende de nenhuma camada de UI/Widgets: toda a interação acontece
/// via console, evidenciando que a lógica de negócio está corretamente
/// desacoplada da futura árvore de widgets do Flutter (Unidade 3).
void main() {
  _secao('1. CADASTRO DE DISPOSITIVOS');
  final central = CentralAutomacaoResidencial();

  final termostatoSala = Termostato(
    id: 'TERM-001',
    nome: 'Termostato',
    comodo: 'Sala',
    temperaturaInicial: 26.0,
    temperaturaAlvoInicial: 22.0,
    apelido: 'Termostato da Sala',
  );

  final termostatoQuarto = Termostato.modoEconomico(
    id: 'TERM-002',
    comodo: 'Quarto',
  );

  final lampadaCozinha = Lampada(
    id: 'LAMP-001',
    nome: 'Lâmpada',
    comodo: 'Cozinha',
    brilhoInicial: 80,
    cor: '#FFDD99',
  );

  final lampadaQuarto = Lampada.noturna(id: 'LAMP-002', comodo: 'Quarto');

  final sensorCorredor = SensorPresenca(
    id: 'SENS-001',
    nome: 'Sensor de Presença',
    comodo: 'Corredor',
    nivelBateriaInicial: 18, // já perto do limiar crítico, de propósito
  );

  final sensorGaragem = SensorPresenca.novo(id: 'SENS-002', comodo: 'Garagem');

  // Uso de Construtor Factory a partir de um Map (ex.: payload do hub).
  final lampadaVarandaMap = <String, dynamic>{
    'id': 'LAMP-003',
    'nome': 'Lâmpada',
    'comodo': 'Varanda',
    'brilho': 60,
    'cor': '#88CCFF',
  };
  final lampadaVaranda = Lampada.fromMap(lampadaVarandaMap);

  // cadastrarTodos() usa Spread Operator internamente.
  central.cadastrarTodos([
    termostatoSala,
    termostatoQuarto,
    lampadaCozinha,
    lampadaQuarto,
    sensorCorredor,
    sensorGaragem,
    lampadaVaranda,
  ]);

  for (final linha in central.relatorioResumido()) {
    print(linha);
  }

  _secao('2. FILTRAGEM E TRANSFORMAÇÃO FUNCIONAL DE DADOS');
  termostatoSala.ligar();
  lampadaCozinha.ligar();
  lampadaQuarto.ligar();

  final ligados = central.obterDispositivosLigados();
  print('Dispositivos ligados agora (${ligados.length}):');
  for (final d in ligados) {
    print(' - ${d.nomeExibicao}');
  }

  final porComodo = central.agruparPorComodo();
  print('\nAgrupamento por cômodo:');
  porComodo.forEach((comodo, lista) {
    final nomes = lista.map((d) => d.nomeExibicao).join(', ');
    print(' - $comodo (${lista.length}): $nomes');
  });

  print('\nContagem por cômodo (com cache/memoização via ??=):');
  print(central.contagemPorComodo());

  print(
    '\nConsumo total estimado: '
    '${central.consumoTotalEstimadoWatts().toStringAsFixed(2)} W',
  );

  _secao('3. SIMULAÇÃO DE RESTRIÇÃO MÓVEL: QUEDA DE CONECTIVIDADE');
  // Simula o sensor da garagem perdendo o sinal Wi-Fi/Zigbee.
  sensorGaragem.definirConectividade(false);
  try {
    _executarComandoComAuditoria(sensorGaragem, 'recalibrar');
  } on StateError catch (e) {
    print('Comando não aplicado: $e');
  } finally {
    print('Tentativa de comando em ${sensorGaragem.id} finalizada.\n');
  }

  // Dispositivo volta a ficar online.
  sensorGaragem.definirConectividade(true);
  _executarComandoComAuditoria(sensorGaragem, 'recalibrar');

  _secao('4. SIMULAÇÃO DE RESTRIÇÃO MÓVEL: BATERIA CRÍTICA');
  try {
    // Sensor do corredor foi cadastrado com bateria em 18%; cada leitura
    // consome 1%, então rapidamente cruza o limiar crítico (15%) e a
    // exceção customizada é disparada.
    for (var i = 0; i < 10; i++) {
      sensorCorredor.simularLeitura(presencaSimulada: i.isEven);
    }
  } on FalhaConectividadeException catch (e) {
    print('Falha capturada na simulação de leitura: $e');
  } finally {
    print('Ciclo de leituras do sensor ${sensorCorredor.id} encerrado.\n');
  }

  _secao('5. TRATAMENTO DE EXCEÇÃO NA INSTANCIAÇÃO (FACTORY)');
  final payloadInvalido = <String, dynamic>{
    'id': 'TERM-999',
    'nome': 'Termostato',
    'comodo': 'Área Externa',
    'temperaturaAtual': 55.0, // fora da faixa operacional (10–32°C)
  };
  try {
    Termostato.fromMap(payloadInvalido);
  } on FalhaConectividadeException catch (e) {
    print('Instanciação rejeitada pelo factory: $e');
  }

  _secao('6. VALIDAÇÃO DE REGRA DE NEGÓCIO (SETTER)');
  try {
    termostatoSala.temperaturaAlvo = 5.0; // abaixo do mínimo permitido
  } on ArgumentError catch (e) {
    print('Ajuste rejeitado: ${e.message}');
  }

  _secao('7. RELATÓRIO FINAL');
  print('Todos os dispositivos online? ${central.todosDispositivosOnline()}');
  print('Existe dispositivo offline? ${central.existeDispositivoOffline()}');
  for (final linha in central.relatorioResumido()) {
    print(linha);
  }
}

/// Executa um comando em um dispositivo, registra o resultado e relança
/// (`rethrow`) qualquer exceção de conectividade para que o chamador
/// decida como tratá-la — demonstra o padrão try-on-catch-finally-rethrow.
void _executarComandoComAuditoria(
  DispositivoResidencial dispositivo,
  String comando,
) {
  try {
    dispositivo.aplicarComando(comando);
    print('Comando "$comando" aplicado com sucesso em ${dispositivo.id}.');
  } on StateError catch (e) {
    print('[AUDITORIA] Falha de conectividade detectada em '
        '${dispositivo.id}: $e');
    rethrow;
  } on FalhaConectividadeException catch (e) {
    print('[AUDITORIA] Falha de domínio detectada em ${dispositivo.id}: $e');
    rethrow;
  }
}

void _secao(String titulo) {
  print('\n=== $titulo ===');
}
