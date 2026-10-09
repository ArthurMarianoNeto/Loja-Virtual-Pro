import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/product.dart';
import 'package:loja_virtual_pro/screens/products/components/products_list_tile.dart';

Future<Product> criarProduto(Map<String, dynamic> dados) async {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  await firestore.doc('products/p1').set(dados);
  return Product.fromDocument(await firestore.doc('products/p1').get());
}

Future<void> mostrarTile(WidgetTester tester, Product product) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: ProductListTile(product)),
  ));
}

void main() {
  testWidgets('produto sem imagens mostra ícone no lugar da foto',
      (tester) async {
    final Product product = await tester.runAsync(
        () => criarProduto({'name': 'Camiseta Branca'})) as Product;

    await mostrarTile(tester, product);

    expect(find.text('Camiseta Branca'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('imagem que falha ao carregar mostra ícone de imagem quebrada',
      (tester) async {
    final Product product = await tester.runAsync(() => criarProduto({
          'name': 'Calça',
          'images': ['https://exemplo.com/nao-existe.png'],
        })) as Product;

    // Em testes, toda requisição de rede responde com erro HTTP 400.
    await mostrarTile(tester, product);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();

    expect(find.text('Calça'), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}
