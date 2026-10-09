import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/app_user.dart';

void main() {
  test('toMap contém apenas nome e e-mail (nunca a senha)', () {
    final AppUser user = AppUser(
      name: 'Fulano de Tal',
      email: 'fulano@gmail.com',
      password: '123456',
    )..confirmPassword = '123456';

    expect(user.toMap(), {'name': 'Fulano de Tal', 'email': 'fulano@gmail.com'});
  });

  test('saveData grava em users/{id} e fromDocument lê de volta', () async {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final AppUser user = AppUser(
      id: 'abc123',
      name: 'Fulano de Tal',
      email: 'fulano@gmail.com',
    );

    await user.saveData(firestore);

    final doc = await firestore.doc('users/abc123').get();
    final AppUser lido = AppUser.fromDocument(doc);
    expect(lido.id, 'abc123');
    expect(lido.name, 'Fulano de Tal');
    expect(lido.email, 'fulano@gmail.com');
  });

  test('fromDocument de documento inexistente deixa nome e e-mail nulos', () async {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

    final AppUser user =
        AppUser.fromDocument(await firestore.doc('users/nao-existe').get());

    expect(user.id, 'nao-existe');
    expect(user.name, isNull);
    expect(user.email, isNull);
  });
}
