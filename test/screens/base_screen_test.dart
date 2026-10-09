import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/product_manager.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:loja_virtual_pro/screens/base/base_screen.dart';
import 'package:provider/provider.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await firestore.doc('users/u1').set({'name': 'Fulano de Tal'});
  });

  Future<UserManager> abrirBase(WidgetTester tester,
      {required bool logado}) async {
    final UserManager userManager = UserManager(
      auth: MockFirebaseAuth(
        signedIn: logado,
        mockUser: MockUser(uid: 'u1', email: 'fulano@gmail.com'),
      ),
      firestore: firestore,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserManager>.value(value: userManager),
          ChangeNotifierProvider<ProductManager>(
            create: (_) => ProductManager(firestore: firestore),
          ),
        ],
        child: MaterialApp(
          routes: {
            '/login': (_) => const Scaffold(body: Text('Tela de login')),
          },
          home: const BaseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return userManager;
  }

  Future<void> abrirDrawer(WidgetTester tester) async {
    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('drawer navega entre as páginas', (tester) async {
    await abrirBase(tester, logado: false);
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    await abrirDrawer(tester);
    await tester.tap(find.text('Produtos'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Produtos'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Home'), findsNothing);

    await abrirDrawer(tester);
    await tester.tap(find.text('Lojas'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Lojas'), findsOneWidget);
  });

  testWidgets('deslogado: header convida a entrar e abre o login',
      (tester) async {
    await abrirBase(tester, logado: false);
    await abrirDrawer(tester);

    expect(find.text('Olá, '), findsOneWidget);
    await tester.tap(find.text('Entre ou cadastre-se >'));
    await tester.pumpAndSettle();

    expect(find.text('Tela de login'), findsOneWidget);
  });

  testWidgets('logado: header mostra o nome e "Sair" desloga', (tester) async {
    final UserManager userManager = await abrirBase(tester, logado: true);
    await abrirDrawer(tester);

    expect(find.text('Olá, Fulano de Tal'), findsOneWidget);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(userManager.isLoggedIn, isFalse);
    expect(find.text('Entre ou cadastre-se >'), findsOneWidget);
  });
}
