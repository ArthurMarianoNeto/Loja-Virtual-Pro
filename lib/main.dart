import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main()  async {
  runApp(MyApp());

 /* Firestore.instance.collection('Pedidos').document('#0001').setData(
      {'preco': 199.99, 'usuário' : 'Arthur Mariano'}
      ); */

/*  Firestore.instance.collection('Pedidos').document('#0002').setData(
   {'Preco': 299.00, 'usuario': 'Joaquina'}
    ); */

/* Firestore.instance.collection('Pedidos').document('#0002').updateData(
   {'Preco': 99.00, 'usuario': 'Chiquinha da Silva'}
    ); */

/*   Firestore.instance.document('Pedidos/#0002').updateData(
   {'Preco': 99.00, 'usuario': 'Chiquinha da Silva 2'} // o nome das colunas levam em conta Sensitive Key
    ); */

/*  DocumentSnapshot document = await Firestore.instance.collection('Pedidos').document('#0002').get();
  print(document.data['usuario']); */

/*  Firestore.instance.collection('Pedidos').document('#0002').snapshots().listen((document) {
  print(document.data);
  }); */

/*  QuerySnapshot snapshot = await Firestore.instance.collection('Pedidos').getDocuments();
  for(DocumentSnapshot document in snapshot.documents){
    print(document.data);
  } */

  Firestore.instance.collection('Pedidos').snapshots().listen((snapshot) {
    for(DocumentSnapshot document in snapshot.documents) {
      print(document.data);
    }
  });

  }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      if(true) {
        print("Testando Software");
      }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Container(),
     );
  }
}
