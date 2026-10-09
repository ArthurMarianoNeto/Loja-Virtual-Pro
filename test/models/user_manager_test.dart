import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/app_user.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  final MockUser mockUser = MockUser(uid: 'u1', email: 'fulano@gmail.com');

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await firestore.doc('users/u1').set({
      'name': 'Fulano de Tal',
      'email': 'fulano@gmail.com',
    });
  });

  group('carregamento inicial', () {
    test('sem usuário logado, user fica nulo', () async {
      final UserManager userManager = UserManager(
        auth: MockFirebaseAuth(mockUser: mockUser),
        firestore: firestore,
      );
      await pumpEventQueue();

      expect(userManager.user, isNull);
      expect(userManager.isLoggedIn, isFalse);
    });

    test('com usuário logado, carrega os dados do Firestore', () async {
      final UserManager userManager = UserManager(
        auth: MockFirebaseAuth(signedIn: true, mockUser: mockUser),
        firestore: firestore,
      );
      await pumpEventQueue();

      expect(userManager.isLoggedIn, isTrue);
      expect(userManager.user!.id, 'u1');
      expect(userManager.user!.name, 'Fulano de Tal');
    });
  });

  group('signIn', () {
    test('sucesso: carrega o usuário e chama onSuccess', () async {
      final UserManager userManager = UserManager(
        auth: MockFirebaseAuth(mockUser: mockUser),
        firestore: firestore,
      );
      final List<bool> estadosLoading = [];
      userManager.addListener(() => estadosLoading.add(userManager.loading));
      bool sucesso = false;
      String? falha;

      await userManager.signIn(
        user: AppUser(email: 'fulano@gmail.com', password: '123456'),
        onFail: (e) => falha = e,
        onSuccess: () => sucesso = true,
      );

      expect(sucesso, isTrue);
      expect(falha, isNull);
      expect(userManager.user!.name, 'Fulano de Tal');
      expect(userManager.loading, isFalse);
      expect(estadosLoading.first, isTrue);
      expect(estadosLoading.last, isFalse);
    });

    test('falha: traduz o erro e não loga', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(mockUser: mockUser);
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      final UserManager userManager =
          UserManager(auth: auth, firestore: firestore);
      bool sucesso = false;
      String? falha;

      await userManager.signIn(
        user: AppUser(email: 'fulano@gmail.com', password: 'errada'),
        onFail: (e) => falha = e,
        onSuccess: () => sucesso = true,
      );

      expect(sucesso, isFalse);
      expect(falha, 'Sua senha está incorreta.');
      expect(userManager.isLoggedIn, isFalse);
      expect(userManager.loading, isFalse);
    });
  });

  group('signUp', () {
    test('sucesso: cria a conta e salva os dados em users/{uid}', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();
      final UserManager userManager =
          UserManager(auth: auth, firestore: firestore);
      bool sucesso = false;

      await userManager.signUp(
        user: AppUser(
          name: 'Ciclano Souza',
          email: 'ciclano@gmail.com',
          password: '123456',
        ),
        onFail: (e) => fail('não deveria falhar: $e'),
        onSuccess: () => sucesso = true,
      );

      expect(sucesso, isTrue);
      final String uid = auth.currentUser!.uid;
      expect(userManager.user!.id, uid);
      final doc = await firestore.doc('users/$uid').get();
      expect(doc.data(), {'name': 'Ciclano Souza', 'email': 'ciclano@gmail.com'});
      expect(userManager.loading, isFalse);
    });

    test('falha: traduz o erro e não salva nada', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final UserManager userManager =
          UserManager(auth: auth, firestore: firestore);
      String? falha;

      await userManager.signUp(
        user: AppUser(
          name: 'Ciclano Souza',
          email: 'fulano@gmail.com',
          password: '123456',
        ),
        onFail: (e) => falha = e,
        onSuccess: () => fail('não deveria ter sucesso'),
      );

      expect(falha, 'E-mail já está sendo utilizado em outra conta.');
      expect(userManager.isLoggedIn, isFalse);
      expect((await firestore.collection('users').get()).docs, hasLength(1));
      expect(userManager.loading, isFalse);
    });
  });

  test('signOut desloga no FirebaseAuth e limpa o usuário', () async {
    final MockFirebaseAuth auth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final UserManager userManager =
        UserManager(auth: auth, firestore: firestore);
    await pumpEventQueue();
    expect(userManager.isLoggedIn, isTrue);

    userManager.signOut();
    await pumpEventQueue();

    expect(userManager.isLoggedIn, isFalse);
    expect(auth.currentUser, isNull);
  });
}
