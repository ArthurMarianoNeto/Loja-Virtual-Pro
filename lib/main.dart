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

  static const Color primaryColor = Color.fromARGB(255, 4, 125, 141);

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
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
            ),
            primaryColor: primaryColor,
            scaffoldBackgroundColor: primaryColor,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withAlpha(100),
                disabledForegroundColor: Colors.white,
              ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //home: BaseScreen(),
          initialRoute: '/base',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(
                    builder: (_) => const LoginScreen()
                );
              case '/signup':
                return MaterialPageRoute(
                    builder: (_) => const SignUpScreen()
                );
              case '/base':
              default:
                return MaterialPageRoute(
                    builder: (_) => const BaseScreen()
                );
            }
          },
      ),
    );
  }
}