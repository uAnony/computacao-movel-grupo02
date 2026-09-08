# Relatório de Ambiente — Requisito 1 (0,25 ponto)

> **Instruções para o grupo:** este arquivo é um **template**. Cada integrante (ou
> ao menos quem fará a entrega) deve rodar os comandos abaixo na própria máquina e
> colar a saída **real e completa** nos lugares indicados. Não entregue este
> arquivo com os placeholders — a rubrica exige a saída íntegra do
> `flutter doctor -v` evidenciando o toolchain funcional.

## 0. Duas formas de gerar o ambiente (ver Semana 03 da disciplina)

Conforme visto na Semana 03 (Tooling, SDKs e Laboratório de Compilação
Desacoplada), o grupo pode obter o `flutter doctor -v` de duas formas:

- **SDK instalado localmente**: instalar Flutter/Dart SDK na própria máquina e
  rodar os comandos da seção 1 diretamente.
- **Container Docker do laboratório**: usar o `Dockerfile` da disciplina (Ubuntu
  22.04 + OpenJDK 17 + Android cmdline-tools + Flutter SDK stable), útil em
  máquinas de laboratório sem Android Studio instalado. Nesse caso, rode
  `flutter doctor -v` **dentro do container** e cole a saída na seção 2 — deixe
  claro no relatório que o ambiente é containerizado.

## 1. Como gerar este relatório

```bash
# 1. Confirme que o Flutter/Dart SDK está instalado e no PATH
flutter --version

# 2. Rode o diagnóstico completo do ambiente
flutter doctor -v

# 3. Copie a saída do terminal e cole na seção "Saída do flutter doctor -v" abaixo
```

Se `flutter doctor -v` reportar itens ausentes (ex.: Android toolchain, licenças do
Android SDK não aceitas, dispositivo/emulador não configurado), resolva-os antes de
gerar a versão final deste relatório — a rubrica pede o ambiente **100% limpo**
(coluna "Excelente" da matriz de correção).



## 2. Saída do `flutter doctor -v`

```
 flutter doctor -v
[1/10] Material Fonts                     (2.2MB in 0,4s)
[2/10] Gradle Wrapper                     (0.1MB in 0,0s)
[3/10] Flutter SDK
  ├─ [1/5] sky_engine                     (1.5MB in 0,3s)
  ├─ [2/5] flutter_gpu                    (0.1MB in 0,2s)
  ├─ [3/5] flutter_patched_sdk            (3.9MB in 0,5s)
  ├─ [4/5] flutter_patched_sdk_product    (3.9MB in 0,5s)
  └─ [5/5] windows-x64                   (29.1MB in 3,5s)
[10/10] windows-x64/font-subset           (2.1MB in 0,4s)
[√] Flutter (Channel stable, 3.47.2, on Microsoft Windows
    [versÆo 10.0.26100.9168], locale pt-BR) [2,6s]
    • Flutter version 3.47.2 on channel stable at
      C:\flutter
    • Upstream repository
      https://github.com/flutter/flutter.git
    • Framework revision d3b14c8769 (13 days ago),
      2026-08-26 16:07:51 -0700
    • Engine revision a804b26164
    • Dart version 3.13.2
    • DevTools version 2.60.0
    • Feature flags: enable-web, enable-linux-desktop,
      enable-macos-desktop, enable-windows-desktop,
      enable-android, enable-ios, cli-animations,
      enable-native-assets, enable-record-use,
      enable-swift-package-manager,
      omit-legacy-version-file, enable-lldb-debugging,
      enable-uiscene-migration

[√] Windows Version (11 Pro 64-bit, 24H2, 2009) [5,4s]

[X] Android toolchain - develop for Android devices
    [74ms]
    • Android SDK at C:\
    • Emulator version unknown
    X cmdline-tools component is missing.
      Try installing or updating Android Studio.
      Alternatively, download the tools from
      https://developer.android.com/studio#command-line-t
      ools-only and make sure to set the ANDROID_HOME
      environment variable.
      See
      https://developer.android.com/studio/command-line
      for more details.

[√] Chrome - develop for the web [24ms]
    • Chrome at C:\Program
      Files\Google\Chrome\Application\chrome.exe

[X] Visual Studio - develop Windows apps [21ms]
    X Visual Studio not installed; this is necessary to
      develop Windows apps.
      Download at
      https://visualstudio.microsoft.com/downloads/.
      Please install the "Desktop development with C++"
      workload, including all of its default components

[√] Connected device (3 available) [4,9s]
    • Windows (desktop) • windows • windows-x64    •
      Microsoft Windows [versÆo 10.0.26100.9168]
    • Chrome (web)      • chrome  • web-javascript •
      Google Chrome 150.0.7871.187
    • Edge (web)        • edge    • web-javascript •
      Microsoft Edge 152.0.4191.53

[√] Network resources [1.227ms]
    • All expected network resources are available.

! Doctor found issues in 2 categories.
```

## 3. Organização do repositório Git

- [x] Repositório inicializado com `git init` (ou criado diretamente no GitHub).
- [x] Arquivo `.gitignore` presente na raiz, ignorando `.dart_tool/`, `.packages`,
      `build/` e arquivos temporários de compilação (já incluído neste projeto).
- [x] Nenhum arquivo temporário/gerado (`.dart_tool/`, `build/`) versionado por
      engano — confirme com `git status` antes de cada commit.
- [x] Código formatado com `dart format .` antes do commit final.
- [x] Histórico de commits com mensagens que reflitam a evolução do trabalho (evitar
      um único commit gigante "projeto completo").