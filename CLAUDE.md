# Contexto do projeto — Loja-Virtual-Pro

> Arquivo de continuidade entre computadores (trabalho ↔ pessoal).
> **Regra:** toda alteração no projeto deve atualizar este arquivo (seções
> "Estado atual" e "Histórico") no mesmo commit. Ao iniciar em outra máquina:
> `git pull`, ler este arquivo e continuar do "Próximo passo".

## Visão geral

- App Flutter de loja virtual (curso), originalmente em **Flutter 1.22**,
  Firebase 0.x (`cloud_firestore ^0.13.5`, `firebase_auth ^0.16.0`,
  `firebase_storage ^3.1.5`), `provider ^4.1.2`, **sem null safety**.
- Objetivo: modernizar para **Flutter 3.47.5**, um passo ("Dia") por vez.
- Branch de trabalho: `modernizacao` (principal: `master`).
- Remoto: https://github.com/ArthurMarianoNeto/Loja-Virtual-Pro

## Regras / preferências do usuário

- **Nada de Flutter/Dart/Android Studio instalado na máquina** — tudo roda via
  Docker: `docker compose run --rm flutter <comando>`.
- Progresso gradual: um "Dia" por vez, cada um com commit `Dia N: ...`.
- **A partir do Dia 3, cada Dia em sua própria branch** criada a partir de
  `modernizacao` (ex.: `dia-3-null-safety`); merge em `modernizacao` só após
  aprovação do usuário.
- Segredos: nunca versionar keystore (`*.jks`, `*.keystore`), `key.properties`,
  `.env` (já no `.gitignore`). Fingerprints SHA-1/SHA-256 não são segredo.
  `android/app/google-services.json` está versionado desde o commit #11 (a
  `api_key` dele não é segredo; proteção vem das regras do Firestore/Storage e
  da restrição da chave no Google Cloud Console).
- Plataformas: **Android primeiro**, iOS depois; web só para um futuro painel admin.
- Material 3 aceito. Projeto Firebase ainda existe (usuário tem acesso ao console).
- Host: WSL2, UID/GID 1000 (se diferente, exportar `UID`/`GID` antes do build).

## Ambiente (Docker)

- `docker/Dockerfile`: Debian bookworm-slim, Flutter 3.47.5, Android SDK 36
  (build-tools 36.0.0), JDK 17, Node 22 + `firebase-tools`, `flutterfire_cli`
  (em `~/.flutterfire-cli` com wrapper `~/bin/flutterfire`, pois o volume
  `pub-cache` encobre o `~/.pub-cache` da imagem), usuário `dev` com UID/GID do host.
- `docker-compose.yml`: serviço `flutter` (comandos avulsos) e `web`
  (porta 8080); volumes `pub-cache`, `gradle-cache` e `firebase-config`
  (login do Firebase CLI; em máquina nova: `docker compose run --rm flutter
  firebase login --no-localhost`).

```bash
docker compose build                                   # primeira vez em cada máquina (~10 min)
docker compose run --rm flutter flutter doctor -v
docker compose run --rm flutter flutter pub get
docker compose run --rm flutter flutter analyze
docker compose run --rm flutter flutter test
docker compose run --rm flutter flutter build apk
docker compose run --rm --service-ports web            # http://localhost:8080
```

## Estrutura do código (`lib/`)

- `main.dart` — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- `firebase_options.dart` — gerado pelo `flutterfire configure` (android, ios, web)
- `common/custom_drawer/` — drawer, header, tiles
- `helpers/` — `firebase_erros.dart`, `validators.dart`
- `models/` — `app_user` (antigo `user`), `page_manager`, `product`, `product_manager`, `user_manager`
- `screens/` — `base`, `login`, `signup`, `products` (+ `components/products_list_tile.dart`)

## Roteiro da modernização

| Dia | Tarefa | Status |
|-----|--------|--------|
| 1 | Ambiente Docker (Flutter 3.47.5 + Android SDK 36) | ✅ concluído |
| 2 | Dependências / `pubspec.yaml` atualizados | ✅ concluído |
| 3 | Migração para null safety | ✅ concluído (merge em `modernizacao`) |
| 4 | Renomeações da API do Firebase (`FirebaseAuth`, `FirebaseFirestore`, etc.) | ✅ concluído (merge em `modernizacao`) |
| 5 | Inicialização do Firebase (`flutterfire configure` dentro do Docker) | ✅ concluído (merge em `modernizacao`) |
| 6 | Widgets / tema (Material 3) | ✅ concluído (merge em `modernizacao`) |
| 7 | Testes | ✅ concluído (merge em `modernizacao`) |
| 8 | Regenerar pasta Android + gerar APK | 🔄 aguardando aprovação (branch `dia-8-android-apk`) |
| depois | Painel admin web, iOS | — |

## Estado atual

- Último passo concluído: **Dia 8** (pasta `android/` regenerada + APK) na
  branch `dia-8-android-apk` — **aguardando aprovação** do usuário para merge
  em `modernizacao`. (Dia 7 mergeado em `modernizacao` em 2026-10-13.)
  - `android/` recriada com `flutter create --platforms=android --org
    br.com.arthurmariano --project-name loja_virtual_pro .` (Gradle Kotlin DSL
    `*.gradle.kts`, AGP 9.1, Kotlin 2.4, Java 17, `namespace` no Gradle).
    Ícones antigos mantidos (idênticos ao template); `google-services.json`
    recolocado em `android/app/` (o plugin Gradle `google-services` não é
    aplicado: o app usa `firebase_options.dart`).
  - Nome exibido no celular: `android:label="Loja Virtual Pro"`.
  - `android/gradle.properties`: o template pede `-Xmx8G` e o daemon do Gradle
    morria por falta de memória no WSL2 (7,6 GB) → `-Xmx3G`,
    `MaxMetaspaceSize=1G`, `kotlin.daemon.jvmargs=-Xmx1G`.
  - `android/.gitignore` ignora `/.kotlin/`; o `test/widget_test.dart` recriado
    pelo `flutter create` foi apagado; arquivo solto
    `antigo bild_gradle_setings.txt` removido.
  - `flutter build apk` → `build/app/outputs/flutter-apk/app-release.apk`
    (52,1 MB, assinado com a chave de debug). O build baixa o Android SDK
    Platform 34 na hora (o SDK não fica em volume → baixa de novo a cada build).
- `flutter analyze`: **0 issues**. `flutter test`: **42/42 passando**.
- **Próximo passo:** usuário instalar o APK no celular e testar (login,
  cadastro, produtos); após aprovação, merge em `modernizacao` e PR
  `modernizacao` → `master`. Depois: painel admin web, iOS.
- Pendências conhecidas:
  - APK de release ainda assinado com a chave de debug (criar keystore de
    release antes de publicar na Play Store — nunca versionar);
  - **Dados do Firestore (usuário, pelo console):** renomear os campos
    `"description "` → `description` e `"images "` → `images` do produto;
    a 2ª URL de imagem (somarmalhas.com.br) dá 404.
  - `web/` gerada localmente (não versionada) só para testar no navegador;
    `flutter run` acrescentou `web/**` ao `analysis_options.yaml` (também
    não commitado) — decidir se versiona (painel admin web no roteiro).
- Sugerido ao usuário: revisar regras do Firestore/Storage (fora do modo teste)
  e restringir as API keys (Android: pacote + SHA-1; iOS: bundle id; web:
  domínios) no Google Cloud Console.

## Histórico

- **2026-09-25** — Dia 1: `docker/Dockerfile`, `docker-compose.yml`, README
  com instruções Docker (commit `1094fa7`).
- **2026-09-25** — Criado este `CLAUDE.md` de contexto para continuar entre máquinas.
- **2026-09-28** — Dia 2: dependências atualizadas (Firebase 4.x/6.x/13.x,
  provider 6, flutter_lints 6), `analysis_options.yaml` novo, `.gitignore` do iOS ephemeral.
- **2026-09-28** — `.gitignore` protege keystores/`key.properties`/`.env`;
  definida estratégia de uma branch por Dia (a partir do Dia 3).
- **2026-09-29** — Dia 3: migração de `lib/` para null safety (branch
  `dia-3-null-safety`); `flutter analyze` de 97/68 para 31/28 issues/erros.
- **2026-10-01** — Dia 3 aprovado e mergeado em `modernizacao`.
- **2026-10-01** — Dia 4: API do Firebase atualizada (branch `dia-4-firebase-api`),
  model `User` → `AppUser`, códigos de erro novos, bug do `signUp` corrigido;
  `flutter analyze` de 31/28 para 8/7 issues/erros.
- **2026-10-01** — Dia 4 aprovado e mergeado em `modernizacao`.
- **2026-10-02** — Dia 5: Firebase inicializado (branch `dia-5-firebase-init`):
  Node/Firebase CLI/FlutterFire CLI no Docker, `firebase_options.dart`
  (android, ios, web), `Firebase.initializeApp()` no `main()`.
- **2026-10-02** — Dia 5 aprovado e mergeado em `modernizacao`.
- **2026-10-05** — Dia 6: Material 3 (branch `dia-6-material3`): tema
  `ColorScheme.fromSeed`, botões/SnackBar novos, telas `StatefulWidget`;
  `flutter analyze` de 8/7 para 0 issues.
- **2026-10-06** — Dia 6 aprovado (PR #6 em `master`) e mergeado em `modernizacao`.
- **2026-10-09** — Dia 7: testes (branch `dia-7-testes`): 39 testes
  (helpers, models com mocks do Firebase, telas de login/cadastro/base),
  injeção de dependência nos managers, correção de overflow no drawer.
- **2026-10-09** — Teste com Firebase real: regras do Firestore novas
  (`firestore.rules`, publicadas); produtos tolerantes a campos ausentes e
  imagens sem CORS/quebradas; 42 testes.
- **2026-10-13** — Dia 7 aprovado e mergeado em `modernizacao`.
- **2026-10-13** — Dia 8: `android/` regenerada pelo template do Flutter
  3.47.5 (branch `dia-8-android-apk`), memória do Gradle ajustada para o WSL2,
  `app-release.apk` gerado; 42 testes passando.
