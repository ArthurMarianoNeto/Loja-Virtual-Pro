import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual_pro/models/product_manager.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:loja_virtual_pro/screens/base/base_screen.dart';
import 'package:loja_virtual_pro/screens/login/login_screen.dart';
import 'package:loja_virtual_pro/screens/signup/signup_screen.dart';
import 'package:provider/provider.dart';

void main()   {
  runApp(MyApp());

/*  Firestore.instance.collection('Pedidos').document('#0004').setData(
      {'preco': 93.99, 'usuário' : 'Maria Rita'}
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

/*  Firestore.instance.collection('Pedidos').snapshots().listen((snapshot) {
    for(DocumentSnapshot document in snapshot.documents) {
      print(document.data);
    }
  }); */

  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UserManager(),
          lazy: false,
        ),
        ChangeNotifierProvider(
            create: (_) => ProductManager(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
          title: 'Loja MegaModa',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 4, 125, 141),
            scaffoldBackgroundColor: const Color.fromARGB(255, 4, 125, 141),
            appBarTheme: const AppBarTheme(
                elevation: 0
            ),
            //primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //home: BaseScreen(),
          initialRoute: '/base',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(
                    builder: (_) => LoginScreen()
                );
              case '/signup':
                return MaterialPageRoute(
                    builder: (_) => SignUpScreen()
                );
              case '/base':
              default:
                return MaterialPageRoute(
                    builder: (_) => BaseScreen()
                );
            }
          },
      ),
    );
  }
}