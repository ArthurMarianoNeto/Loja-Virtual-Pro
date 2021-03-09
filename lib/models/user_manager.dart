import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual_pro/helpers/firebase_erros.dart';
import 'package:loja_virtual_pro/models/user.dart';

class UserManager{

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signIn({User user, Function onFail, Function onSuccess}) async {
    try {
      final AuthResult result = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
//          print(result.user.uid);
            onSuccess();
    } on PlatformException catch (e){
 //     print(getErrorString(e.code));
      onFail(getErrorString(e.code));

    }
  }
}