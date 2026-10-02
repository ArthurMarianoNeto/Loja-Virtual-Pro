import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual_pro/firebase_options.dart';
import 'package:loja_virtual_pro/models/product_manager.dart';
import 'package:loja_virtual_pro/models/user_manager.dart';
import 'package:loja_virtual_pro/screens/base/base_screen.dart';
import 'package:loja_virtual_pro/screens/login/login_screen.dart';
import 'package:loja_virtual_pro/screens/signup/signup_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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