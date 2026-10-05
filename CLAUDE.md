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
| 6 | Widgets / tema (Material 3) | 🔶 feito na branch `dia-6-material3`, aguardando aprovação |
| 7 | Testes | — |
| 8 | Regenerar pasta Android + gerar APK | — |
| depois | Painel admin web, iOS | — |

## Estado atual

- Último passo concluído: **Dia 6** (widgets/tema Material 3) na branch
  `dia-6-material3` — **aguardando aprovação** do usuário para merge em
  `modernizacao` (2026-10-05).
  - Tema: `useMaterial3: true`, `ColorScheme.fromSeed` com a cor primária
    `MyApp.primaryColor` (teal `0xFF047D8D`); AppBar teal com texto branco;
    `elevatedButtonTheme` centraliza cores do botão (inclusive desabilitado).
  - `FlatButton` → `TextButton`, `RaisedButton` → `ElevatedButton`,
    `scaffoldKey.currentState.showSnackBar` → `ScaffoldMessenger.of(context)`.
  - `LoginScreen`, `SignUpScreen` e `BaseScreen` agora são `StatefulWidget`
    (controllers com `dispose()`; checagem de `mounted` nos callbacks async).
  - Removido `print('Construtor')` do `UserManager`; imports `cupertino` →
    `foundation`/`widgets` nos models.
- `flutter analyze`: **0 issues**.
- `flutter test`: o único teste (`test/widget_test.dart`) é o "Counter" do
  template e falha (já falhava antes; não tem relação com o app) → Dia 7.
- **Próximo passo:** usuário testar/aprovar o Dia 6 → merge em `modernizacao`;
  depois Dia 7 (testes) na branch `dia-7-testes`.
- Pendências conhecidas:
  - arquivo solto `antigo bild_gradle_setings.txt` na raiz (tratar no Dia 8);
  - Dia 8: ao regenerar `android/`, garantir que o `google-services.json`
    continue em `android/app/` (o app usa `firebase_options.dart`, então o
    plugin Gradle `google-services` é opcional);
  - Dia 7: substituir `test/widget_test.dart` (template) por testes reais
    (validators, `getErrorString`, widgets sem Firebase / com mocks).
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
