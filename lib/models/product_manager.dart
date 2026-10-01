import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual_pro/models/product.dart';

class ProductManager extends ChangeNotifier{

  ProductManager(){
    _loadAllProducts();

  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Product> allProducts = [];

  Future<void>  _loadAllProducts() async{
    final QuerySnapshot<Map<String, dynamic>> snapProducts =
        await firestore.collection('products').get();

/*    for(DocumentSnapshot doc in snapProducts.docs){
      print(doc.data); */

  allProducts = snapProducts.docs.map(
          (d) => Product.fromDocument(d)).toList();

  notifyListeners();

    }
}