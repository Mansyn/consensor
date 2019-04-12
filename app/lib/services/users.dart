import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseUsers {
  Future<QuerySnapshot> getUsers();
}

class Users implements BaseUsers {
  final Firestore _db = Firestore.instance;

  Future<QuerySnapshot> getUsers() async {
    return await _db.collection('users').getDocuments();
  }
}
