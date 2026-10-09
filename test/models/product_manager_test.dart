import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/product_manager.dart';

void main() {
  test('carrega todos os produtos da coleção products', () async {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    await firestore.collection('products').doc('p1').set({
      'name': 'Camiseta',
      'description': 'Camiseta de algodão',
      'images': ['https://exemplo.com/camiseta.png'],
    });
    await firestore.collection('products').doc('p2').set({
      'name': 'Calça',
      'description': 'Calça jeans',
      'images': ['https://exemplo.com/calca1.png', 'https://exemplo.com/calca2.png'],
    });

    final ProductManager productManager = ProductManager(firestore: firestore);
    int notificacoes = 0;
    productManager.addListener(() => notificacoes++);
    await pumpEventQueue();

    expect(notificacoes, 1);
    expect(productManager.allProducts, hasLength(2));
    final camiseta =
        productManager.allProducts.firstWhere((p) => p.id == 'p1');
    expect(camiseta.name, 'Camiseta');
    expect(camiseta.description, 'Camiseta de algodão');
    expect(camiseta.images, ['https://exemplo.com/camiseta.png']);
    final calca = productManager.allProducts.firstWhere((p) => p.id == 'p2');
    expect(calca.images, hasLength(2));
  });

  test('campos ausentes ou mal digitados não derrubam a lista', () async {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    // Caso real do console: nomes de campo com espaço no final.
    await firestore.collection('products').doc('p1').set({
      'name': 'Camiseta Branca',
      'description ': 'Camiseta de alta qualidade',
      'images ': ['https://exemplo.com/camiseta.png'],
    });
    await firestore.collection('products').doc('p2').set({
      'name': 'Calça',
      'description': 'Calça jeans',
      'images': ['https://exemplo.com/calca.png'],
    });

    final ProductManager productManager = ProductManager(firestore: firestore);
    await pumpEventQueue();

    expect(productManager.allProducts, hasLength(2));
    final camiseta =
        productManager.allProducts.firstWhere((p) => p.id == 'p1');
    expect(camiseta.name, 'Camiseta Branca');
    expect(camiseta.description, '');
    expect(camiseta.images, isEmpty);
  });

  test('coleção vazia resulta em lista vazia', () async {
    final ProductManager productManager =
        ProductManager(firestore: FakeFirebaseFirestore());
    await pumpEventQueue();

    expect(productManager.allProducts, isEmpty);
  });
}
