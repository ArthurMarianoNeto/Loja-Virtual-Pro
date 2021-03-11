import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual_pro/helpers/firebase_erros.dart';
import 'package:loja_virtual_pro/models/user.dart';

class UserManager extends ChangeNotifier {

  UserManager(){
    print('Construtor');
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;


//  FirebaseUser user;
    User user;

  bool _loading = false;
  bool get loading => _loading;

  bool get isLoggedIn => user != null;

  Future<void> signIn({User user, Function onFail, Function onSuccess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);

      await _loadCurrentUser(firebaseUser: result.user);
 //     this.user = result.user;

      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void signOut(){
    auth.signOut();
    user = null;
    notifyListeners();
  }


  Future<void> signUp({User user, Function onFail, Function onSuccess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

//      this.user = result.user;
      user.id = result.user.uid;
      this.user = user;

     await  user.saveData();

    } on PlatformException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
    onSuccess();
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({FirebaseUser firebaseUser}) async {
    final FirebaseUser currentUser = firebaseUser ?? await auth.currentUser();
    if(currentUser != null){
/*      user = currentUser;
      print(user.uid); */
       final DocumentSnapshot docUser = await firestore.collection('users').document(currentUser.uid).get();
      user =  User.fromDoument(docUser);
 //     print(user.name);
       notifyListeners();
    }
  }
}
