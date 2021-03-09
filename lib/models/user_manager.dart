import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual_pro/helpers/firebase_erros.dart';
import 'package:loja_virtual_pro/models/user.dart';

class UserManager extends ChangeNotifier {

  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = false;

  Future<void> signIn({User user, Function onFail, Function onSuccess}) async {
    setLoading(true);

    try {
      final AuthResult result = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
//          print(result.user.uid);

      //await Future.delayed(Duration(seconds: 4));
      onSuccess();
    } on PlatformException catch (e) {
      //     print(getErrorString(e.code));
      onFail(getErrorString(e.code));
    }
    setLoading(false);
  }
  void setLoading(bool value){
    loading = value;
    notifyListeners();
  }
}