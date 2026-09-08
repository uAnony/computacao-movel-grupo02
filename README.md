# Automação e Monitoramento de Dispositivos Residenciais (Tema 09)

Avaliação Processual 1B — Computação Móvel — Sistemas de Informação (7º/8º período)
Marco 1 do Projeto Prático Integrado (PBL): Módulo Central de Domínio e Lógica de
Negócios em **Dart puro**, sem acoplamento com camada de UI/Widgets.

## Integrantes — Grupo 02

- Maria Eduarda Louzada Girardi
- Tiago Cezar Silva e Silva
- Thales Menini Ferrari
- Felipe Motta Neves
- Filipe Antônio Lins Noé

## Tema escolhido

**Tema 09 — Automação e Monitoramento de Dispositivos Residenciais**: controle de
estados de sensores, termostatos e luzes de uma residência inteligente, incluindo
simulação de restrições reais de computação móvel/IoT (queda de conectividade e
nível crítico de bateria de sensores sem fio).

## Estrutura do projeto

```
lib/
  exceptions/
    falha_conectividade_exception.dart   # Exceção de domínio customizada
  mixins/
    monitoramento_mixin.dart             # Mixin de auditoria/log (with)
  models/
    dispositivo_residencial.dart         # Classe abstrata (contrato)
    termostato.dart                      # extends + mixin + construtores
    lampada.dart                         # extends + mixin + construtores
    sensor_presenca.dart                 # extends + mixin + construtores
  services/
    central_automacao_residencial.dart   # Coleções, funcional, cache
bin/
  main.dart                              # Executável de demonstração (CLI)
```

## Como rodar o projeto

Pré-requisito: Dart SDK 3.x instalado (incluído no Flutter SDK). Veja
`ENVIRONMENT_REPORT.md` para o diagnóstico completo do ambiente do grupo.

```bash
# 1. Baixar as dependências do projeto
dart pub get

# 2. Rodar a rotina de demonstração no console
dart run bin/main.dart

# 3. (Opcional) Formatar o código no padrão oficial
dart format .

# 4. (Opcional) Rodar a análise estática
dart analyze
```

## Requisitos técnicos atendidos

- **Requisito 2 (Modelagem OO Avançada)**: classe abstrata `DispositivoResidencial`;
  herança com `extends` + `super.<param>`; mixin `MonitoramentoMixin` aplicado com
  `with`; construtor padrão gerativo, construtor nomeado (`.modoEconomico`,
  `.noturna`, `.novo`) e construtor factory (`.fromMap`) em cada classe concreta;
  encapsulamento com campos privados (`_`) expostos por getters/setters validados.
- **Requisito 3 (Null Safety, Coleções e Exceções)**: uso de `String?`, `??`, `??=`
  e `?.`; métodos funcionais (`.where()`, `.fold()`, `.any()`, `.every()`, `.map()`);
  Spread Operators (`...`) e Collection-If/Collection-For em
  `CentralAutomacaoResidencial`; exceção customizada `FalhaConectividadeException`
  com `try/on/catch/finally` e `rethrow`.
- **Requisito 4 (CLI de Demonstração)**: `bin/main.dart` cadastra dispositivos,
  filtra e agrupa dados, simula queda de conectividade e bateria crítica, e imprime
  relatórios formatados no terminal.

## Declaração de Uso de Inteligência Artificial

Conforme a Política Institucional de Uso de IA do Plano de Ensino 2026/2:

- **Ferramenta utilizada:** Claude (Anthropic).
- **Como foi utilizada:** apoio no brainstorming da modelagem de domínio (definição
  das classes, do mixin e da exceção customizada), geração de um scaffolding
  inicial de código seguindo os requisitos do enunciado, e sugestões de
  refatoração/organização de pastas, e apoio na configuração e resolução de
  problemas do Git/GitHub (inicialização do repositório, ajuste do `.gitignore`
  e remoção de arquivos que foram versionados por engano).
- **O que o grupo fez a partir dai: Montagem e configuração do ambiente, execução de todos os testes, verificação dos resultados  identificação e reporte das falhas encontradas em execução, e validação de cada etapa antes de avançar.


## Referências bibliográficas

- Documentação oficial da linguagem Dart: <https://dart.dev/language>
- Documentação oficial do Flutter: <https://docs.flutter.dev>
- Material de aula da disciplina Computação Móvel (Semanas 01 a 05), Prof. Edgard
  da Cunha Pontes — Multivix.
