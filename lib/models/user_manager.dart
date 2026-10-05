import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:loja_virtual_pro/helpers/firebase_erros.dart';
import 'package:loja_virtual_pro/models/app_user.dart';

class UserManager extends ChangeNotifier {

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


//  FirebaseUser user;
    AppUser? user;

  bool _loading = false;
  bool get loading => _loading;

  bool get isLoggedIn => user != null;

  Future<void> signIn({
    required AppUser user,
    required void Function(String) onFail,
    required VoidCallback onSuccess,
  }) async {
    loading = true;
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);

      await _loadCurrentUser(firebaseUser: result.user);
 //     this.user = result.user;

      onSuccess();
    } on FirebaseException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void signOut(){
    auth.signOut();
    user = null;
    notifyListeners();
  }


  Future<void> signUp({
    required AppUser user,
    required void Function(String) onFail,
    required VoidCallback onSuccess,
  }) async {
    loading = true;
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);

//      this.user = result.user;
      user.id = result.user!.uid;
      this.user = user;

     await  user.saveData();

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    final User? currentUser = firebaseUser ?? auth.currentUser;
    if(currentUser != null){
/*      user = currentUser;
      print(user.uid); */
       final DocumentSnapshot<Map<String, dynamic>> docUser =
           await firestore.collection('users').doc(currentUser.uid).get();
      user =  AppUser.fromDocument(docUser);
 //     print(user.name);
       notifyListeners();
    }
  }
}
