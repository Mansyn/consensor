import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/group.dart';

final CollectionReference groupCollection =
    Firestore.instance.collection('groups');

class GroupService {
  static final GroupService _instance = new GroupService.internal();

  factory GroupService() => _instance;

  GroupService.internal();

  Future<Group> createGroup(
      String title, String ownerId, List<String> members) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(groupCollection.document());

      final Group group = new Group(ds.documentID, title, ownerId, members);
      final Map<String, dynamic> data = group.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Group.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Stream<QuerySnapshot> getGroupList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = groupCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<dynamic> updateGroup(Group group) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(groupCollection.document(group.id));

      await tx.update(ds.reference, group.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteGroup(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(groupCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}
