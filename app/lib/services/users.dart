import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference groupCollection =
    Firestore.instance.collection('users');

class UserService {
  static final UserService _instance = new UserService.internal();

  factory UserService() => _instance;

  UserService.internal();

  Stream<QuerySnapshot> getUserList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = groupCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }
}
