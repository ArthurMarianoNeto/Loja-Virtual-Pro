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
  (build-tools 36.0.0), JDK 17, usuário `dev` com UID/GID do host.
- `docker-compose.yml`: serviço `flutter` (comandos avulsos) e `web`
  (porta 8080); volumes `pub-cache` e `gradle-cache`.

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

- `main.dart`
- `common/custom_drawer/` — drawer, header, tiles
- `helpers/` — `firebase_erros.dart`, `validators.dart`
- `models/` — `page_manager`, `product`, `product_manager`, `user`, `user_manager`
- `screens/` — `base`, `login`, `signup`, `products` (+ `components/products_list_tile.dart`)

## Roteiro da modernização

| Dia | Tarefa | Status |
|-----|--------|--------|
| 1 | Ambiente Docker (Flutter 3.47.5 + Android SDK 36) | ✅ concluído |
| 2 | Dependências / `pubspec.yaml` atualizados | ✅ concluído |
| 3 | Migração para null safety | ✅ concluído (branch `dia-3-null-safety`, aguardando merge) |
| 4 | Renomeações da API do Firebase (`FirebaseAuth`, `FirebaseFirestore`, etc.) | ⏳ próximo |
| 5 | Inicialização do Firebase (`flutterfire configure` dentro do Docker) | — |
| 6 | Widgets / tema (Material 3) | — |
| 7 | Testes | — |
| 8 | Regenerar pasta Android + gerar APK | — |
| depois | Painel admin web, iOS | — |

## Estado atual

- Último passo concluído: **Dia 3** (null safety) na branch `dia-3-null-safety`
  — **aguardando aprovação do usuário para merge em `modernizacao`**.
  - Models: campos `late` em `Product`; campos `String?` em `User`;
    `UserManager.user` é `User?`; `signIn`/`signUp` com `required` e callbacks
    tipados (`void Function(String)`, `VoidCallback`).
  - Widgets: `super.key` em todos, `required` no `DrawerTile`, validators de
    formulário tratando `null`, `currentState!`, `child!` no `Consumer`.
  - Removidos imports não usados.
- `flutter analyze`: **31 issues (28 errors)** (antes 97/68). Nenhum erro de
  null safety restante. Sobram:
  - Dia 4 (Firebase): `Firestore`, `documentID`, `document.data[...]`,
    `documents`, `setData`, `AuthResult`, `FirebaseUser`, `auth.currentUser()`,
    conflito de nome `User` (firebase_auth × models/user.dart).
  - Dia 6 (widgets): `FlatButton`, `RaisedButton`, `ScaffoldState.showSnackBar`
    (usar `TextButton`/`ElevatedButton`/`ScaffoldMessenger`).
- **Próximo passo:** após merge do Dia 3, criar `dia-4-firebase-api` e fazer as
  renomeações da API do Firebase.
- Pendências conhecidas:
  - arquivo solto `antigo bild_gradle_setings.txt` na raiz (tratar no Dia 8);
  - bug herdado em `UserManager.signUp`: `onSuccess()` é chamado mesmo quando o
    cadastro falha (fica fora do `try`) — corrigir no Dia 4;
  - `LoginScreen`/`SignUpScreen`/`BaseScreen` criam controllers/keys em
    `StatelessWidget` — converter para `StatefulWidget` no Dia 6.
- Sugerido ao usuário: revisar regras do Firestore/Storage (fora do modo teste)
  e restringir a API key Android no Google Cloud Console (pacote + SHA-1).

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
