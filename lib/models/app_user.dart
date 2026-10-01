import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {

  AppUser({this.email, this.password, this.name, this.id});

  AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> document){
    id = document.id;
    name = document.data()?['name'] as String?;
    email = document.data()?['email'] as String?;

  }

  String? id;
  String? name;
  String? email;
  String? password;

  String? confirmPassword;

  DocumentReference<Map<String, dynamic>> get firestoreRef =>
  FirebaseFirestore.instance.doc('users/$id');

  Future<void> saveData() async{

    await firestoreRef.set(toMap());

  }

  Map<String, dynamic> toMap(){

    return{
      'name': name,
      'email': email,
    };

  }

}
