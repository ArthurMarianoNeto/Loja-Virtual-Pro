import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:loja_virtual_pro/screens/signup/signup_screen.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:provider/provider.dart';

/// Abre a SignUpScreen por cima de uma tela inicial, como no app (pushNamed).
Future<void> abrirCadastro(WidgetTester tester, UserManager userManager) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UserManager>.value(
      value: userManager,
      child: MaterialApp(
        routes: {'/signup': (_) => const SignUpScreen()},
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
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

Future<void> preencherECadastrar(
  WidgetTester tester, {
  String nome = '',
  String email = '',
  String senha = '',
  String repetirSenha = '',
}) async {
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome Completo'), nome);
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), senha);
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Repita a Senha'), repetirSenha);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Conta'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late UserManager userManager;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    userManager = UserManager(auth: auth, firestore: firestore);
  });

  testWidgets('campos vazios são obrigatórios', (tester) async {
    await abrirCadastro(tester, userManager);

    await preencherECadastrar(tester);

    expect(find.text('Campo obrigatório'), findsNWidgets(4));
  });

  testWidgets('valida nome completo, e-mail e tamanho da senha',
      (tester) async {
    await abrirCadastro(tester, userManager);

    await preencherECadastrar(
      tester,
      nome: 'Fulano',
      email: 'fulano@',
      senha: '123',
      repetirSenha: '123',
    );

    expect(find.text('Preencha seu Nome completo'), findsOneWidget);
    expect(find.text('E-mail inválido'), findsOneWidget);
    expect(find.text('Senha muito curta'), findsNWidgets(2));
  });

  testWidgets('senhas diferentes mostram SnackBar e não cadastram',
      (tester) async {
    await abrirCadastro(tester, userManager);

    await preencherECadastrar(
      tester,
      nome: 'Fulano de Tal',
      email: 'fulano@gmail.com',
      senha: '123456',
      repetirSenha: '654321',
    );

    expect(find.text('Senhas não coincidem!'), findsOneWidget);
    expect(auth.currentUser, isNull);
  });

  testWidgets('cadastro com sucesso salva o usuário e fecha a tela',
      (tester) async {
    await abrirCadastro(tester, userManager);

    await preencherECadastrar(
      tester,
      nome: 'Fulano de Tal',
      email: 'fulano@gmail.com',
      senha: '123456',
      repetirSenha: '123456',
    );

    expect(find.byType(SignUpScreen), findsNothing);
    expect(userManager.user!.name, 'Fulano de Tal');
    final doc = await firestore.doc('users/${auth.currentUser!.uid}').get();
    expect(doc.data(), {'name': 'Fulano de Tal', 'email': 'fulano@gmail.com'});
  });

  testWidgets('falha no cadastro mostra SnackBar com o erro traduzido',
      (tester) async {
    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
    await abrirCadastro(tester, userManager);

    await preencherECadastrar(
      tester,
      nome: 'Fulano de Tal',
      email: 'fulano@gmail.com',
      senha: '123456',
      repetirSenha: '123456',
    );

    expect(
      find.text(
          'Falha ao cadastrar: E-mail já está sendo utilizado em outra conta.'),
      findsOneWidget,
    );
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
