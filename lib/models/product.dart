import 'package:cloud_firestore/cloud_firestore.dart';

class Product {

  Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> document){

    // Campos ausentes (ou com nome digitado errado no console) não derrubam
    // o carregamento da lista inteira.
    final Map<String, dynamic> data = document.data() ?? {};
    id = document.id;
    name = data['name'] as String? ?? '';
    description = data['description'] as String? ?? '';
    images = List<String>.from(data['images'] as List<dynamic>? ?? const []);


  }
  late String id;
  late String name;
  late String description;
  late List<String> images;
}