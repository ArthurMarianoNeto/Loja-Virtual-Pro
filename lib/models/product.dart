import 'package:cloud_firestore/cloud_firestore.dart';

class Product {

  Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> document){

    id = document.id;
    name = document['name'] as String;
    description = document['description'] as String;
    images = List<String>.from(document['images'] as List<dynamic>);


  }
  late String id;
  late String name;
  late String description;
  late List<String> images;
}