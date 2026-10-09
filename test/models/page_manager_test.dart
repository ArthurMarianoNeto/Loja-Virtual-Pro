import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/models/page_manager.dart';

void main() {
  testWidgets('setPage troca a página do PageController', (tester) async {
    final PageController controller = PageController();
    addTearDown(controller.dispose);
    final PageManager pageManager = PageManager(controller);

    await tester.pumpWidget(MaterialApp(
      home: PageView(
        controller: controller,
        children: const [Text('Página 0'), Text('Página 1'), Text('Página 2')],
      ),
    ));
    expect(pageManager.page, 0);
    expect(find.text('Página 0'), findsOneWidget);

    pageManager.setPage(2);
    await tester.pump();

    expect(pageManager.page, 2);
    expect(controller.page, 2);
    expect(find.text('Página 2'), findsOneWidget);
    expect(find.text('Página 0'), findsNothing);
  });

  test('setPage ignora a página atual sem tocar no PageController', () {
    // Controller sem PageView: jumpToPage falharia se fosse chamado.
    final PageController controller = PageController();
    addTearDown(controller.dispose);
    final PageManager pageManager = PageManager(controller);

    pageManager.setPage(0);

    expect(pageManager.page, 0);
  });
}
