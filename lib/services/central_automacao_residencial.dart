import '../exceptions/falha_conectividade_exception.dart';
import '../models/dispositivo_residencial.dart';

/// Serviço central que gerencia o conjunto de dispositivos residenciais
/// cadastrados, oferecendo consultas e operações em lote sobre a coleção
/// — o núcleo de "domínio e lógica de negócios" exigido pelo Requisito 2,
/// sem qualquer acoplamento com camada visual (UI/Widgets).
class CentralAutomacaoResidencial {
  final List<DispositivoResidencial> _dispositivos = [];

  /// Cache opcional de contagem por cômodo (demonstra tipo anulável e
  /// atribuição condicional `??=` para memoização simples).
  Map<String, int>? _cacheContagemPorComodo;

  /// Lista somente-leitura dos dispositivos cadastrados.
  List<DispositivoResidencial> get dispositivos =>
      List.unmodifiable(_dispositivos);

  void cadastrar(DispositivoResidencial dispositivo) {
    _dispositivos.add(dispositivo);
    _invalidarCache();
  }

  /// Cadastra vários dispositivos de uma vez, usando Spread Operator para
  /// compor a nova lista a partir da lista existente + dos novos itens.
  void cadastrarTodos(List<DispositivoResidencial> novos) {
    final atualizados = [..._dispositivos, ...novos];
    _dispositivos
      ..clear()
      ..addAll(atualizados);
    _invalidarCache();
  }

  /// Uso de `.where()` (programação funcional) para filtrar por estado.
  List<DispositivoResidencial> obterDispositivosLigados() {
    return _dispositivos.where((d) => d.ligado).toList();
  }

  /// Uso de `.where()` combinado a acesso seguro (`?.`) — `comodoBusca`
  /// pode chegar nulo de uma tela de filtro ainda não preenchida.
  List<DispositivoResidencial> obterDispositivosPorComodo(
    String? comodoBusca,
  ) {
    final alvo = comodoBusca?.trim().toLowerCase();
    if (alvo == null || alvo.isEmpty) return dispositivos;
    return _dispositivos
        .where((d) => d.comodo.trim().toLowerCase() == alvo)
        .toList();
  }

  /// Uso de `.fold()` para agregação numérica sobre a coleção.
  double consumoTotalEstimadoWatts() {
    return _dispositivos.fold<double>(
      0.0,
      (soma, dispositivo) => soma + dispositivo.consumoEstimadoWatts,
    );
  }

  /// Uso de `.any()`: verifica se existe ao menos um dispositivo offline
  /// (restrição de conectividade intermitente do cenário móvel).
  bool existeDispositivoOffline() => _dispositivos.any((d) => !d.online);

  /// Uso de `.every()`: verifica se todos os dispositivos estão online.
  bool todosDispositivosOnline() => _dispositivos.every((d) => d.online);

  /// Uso de `.map()` (via `Map.map`) + Collection-For para agrupar
  /// dispositivos por cômodo.
  Map<String, List<DispositivoResidencial>> agruparPorComodo() {
    final mapa = <String, List<DispositivoResidencial>>{};
    for (final dispositivo in _dispositivos) {
      final listaAtual = mapa[dispositivo.comodo] ?? const [];
      mapa[dispositivo.comodo] = [...listaAtual, dispositivo];
    }
    return mapa;
  }

  /// Memoização simples da contagem de dispositivos por cômodo.
  /// `??=` só recalcula quando o cache ainda não existe; o `!` seguinte é
  /// seguro porque o valor acabou de ser garantido não-nulo na linha
  /// anterior (uso consciente, não forçado sem tratamento).
  Map<String, int> contagemPorComodo() {
    _cacheContagemPorComodo ??= agruparPorComodo()
        .map((comodo, lista) => MapEntry(comodo, lista.length));
    return _cacheContagemPorComodo!;
  }

  void _invalidarCache() => _cacheContagemPorComodo = null;

  /// Tenta ligar todos os dispositivos de um cômodo, tratando falhas de
  /// conectividade/estado individualmente (um dispositivo com problema não
  /// deve interromper o comando dos demais).
  int ligarTodosDoComodo(String comodo) {
    var sucesso = 0;
    for (final dispositivo in obterDispositivosPorComodo(comodo)) {
      try {
        dispositivo.aplicarComando('ligar');
        sucesso++;
      } on StateError catch (e) {
        print('Falha ao ligar ${dispositivo.id}: $e');
      } on FalhaConectividadeException catch (e) {
        print('Falha ao ligar ${dispositivo.id}: $e');
      } finally {
        // Ponto único de auditoria da tentativa, ligue ela tendo sucesso
        // ou não — demonstra o bloco `finally`.
        print('Tentativa de ligar ${dispositivo.id} processada.');
      }
    }
    return sucesso;
  }

  /// Monta um relatório textual formatado, combinando Collection-If
  /// (só inclui a linha de consumo quando há dispositivos) e
  /// Collection-For (uma linha por dispositivo).
  List<String> relatorioResumido() {
    return [
      'Total de dispositivos cadastrados: ${_dispositivos.length}',
      if (_dispositivos.isNotEmpty)
        'Consumo total estimado: '
            '${consumoTotalEstimadoWatts().toStringAsFixed(2)} W',
      if (existeDispositivoOffline()) 'Atenção: há dispositivos offline!',
      for (final dispositivo in _dispositivos) ' - $dispositivo',
    ];
  }
}
