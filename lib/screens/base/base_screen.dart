import 'package:flutter/material.dart';
import 'package:loja_virtual_pro/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual_pro/models/page_manager.dart';
import 'package:loja_virtual_pro/screens/products/products.screen.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => PageManager(pageController),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              title: const Text('Home'),
            ),
          ),
          const ProductsScreen(),
          Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              title: const Text('Meus Pedidos'),
            ),
          ),
          Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              title: const Text('Lojas'),
            ),
          ),
        ],
      ),
    );
  }
}
