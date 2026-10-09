import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:loja_virtual_pro/screens/login/login_screen.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:provider/provider.dart';

/// Abre a LoginScreen por cima de uma tela inicial, como no app (pushNamed).
Future<void> abrirLogin(WidgetTester tester, UserManager userManager) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UserManager>.value(
      value: userManager,
      child: MaterialApp(
        routes: {'/login': (_) => const LoginScreen()},
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Início'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Início'));
  await tester.pumpAndSettle();
}

Future<void> preencherEEntrar(
    WidgetTester tester, String email, String senha) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), senha);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late UserManager userManager;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await firestore.doc('users/u1').set({'name': 'Fulano de Tal'});
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'u1', email: 'fulano@gmail.com'),
    );
    userManager = UserManager(auth: auth, firestore: firestore);
  });

  testWidgets('valida e-mail e senha antes de tentar entrar', (tester) async {
    await abrirLogin(tester, userManager);

    await preencherEEntrar(tester, 'fulano', '123');

    expect(find.text('E-mail Inválido'), findsOneWidget);
    expect(find.text('Senha inválida'), findsOneWidget);
    expect(userManager.isLoggedIn, isFalse);
  });

  testWidgets('login com sucesso fecha a tela', (tester) async {
    await abrirLogin(tester, userManager);

    await preencherEEntrar(tester, 'fulano@gmail.com', '123456');

    expect(userManager.user!.name, 'Fulano de Tal');
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets('falha no login mostra SnackBar com o erro traduzido',
      (tester) async {
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    await abrirLogin(tester, userManager);

    await preencherEEntrar(tester, 'fulano@gmail.com', 'errada');

    expect(find.text('Falha ao entrar: E-mail ou senha incorretos.'),
        findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('durante o carregamento desabilita campos e botão',
      (tester) async {
    await abrirLogin(tester, userManager);

    userManager.loading = true;
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final ElevatedButton botao =
        tester.widget(find.byType(ElevatedButton));
    expect(botao.onPressed, isNull);
    final Iterable<TextField> campos =
        tester.widgetList(find.byType(TextField));
    expect(campos.every((c) => c.enabled == false), isTrue);
  });

  testWidgets('"Criar Conta" troca para a tela de cadastro', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<UserManager>.value(
        value: userManager,
        child: MaterialApp(
          routes: {
            '/signup': (_) => const Scaffold(body: Text('Tela de cadastro')),
          },
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Tela de cadastro'), findsOneWidget);
  });
}
