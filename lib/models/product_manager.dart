import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual_pro/models/product.dart';
import 'package:provider/provider.dart';

class ProductManager extends ChangeNotifier{

  ProductManager(){
    _loadAllProducts();

  }

  final Firestore firestore = Firestore.instance;

  List<Product> allProducts = [];

  Future<void>  _loadAllProducts() async{
    final QuerySnapshot snapProducts = await firestore.collection('products').getDocuments();

/*    for(DocumentSnapshot doc in snapProducts.documents){
      print(doc.data); */

  allProducts = snapProducts.documents.map(
          (d) => Product.fromDocument(d)).toList();

  notifyListeners();

    }
}