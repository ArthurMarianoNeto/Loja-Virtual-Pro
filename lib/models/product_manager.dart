import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loja_virtual_pro/models/product.dart';

class ProductManager extends ChangeNotifier{

  ProductManager({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance {
    _loadAllProducts();
  }

  final FirebaseFirestore firestore;

  List<Product> allProducts = [];

  Future<void>  _loadAllProducts() async{
    final QuerySnapshot<Map<String, dynamic>> snapProducts;
    try {
      snapProducts = await firestore.collection('products').get();
    } on FirebaseException catch (e) {
      debugPrint('Erro ao carregar produtos: ${e.code} ${e.message}');
      return;
    }

/*    for(DocumentSnapshot doc in snapProducts.docs){
      print(doc.data); */

  allProducts = snapProducts.docs.map(
          (d) => Product.fromDocument(d)).toList();

  notifyListeners();

    }
}