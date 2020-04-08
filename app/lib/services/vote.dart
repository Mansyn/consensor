import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/vote.dart';

final CollectionReference voteCollection =
    Firestore.instance.collection('votes');

class VoteService {
  static final VoteService _instance = new VoteService.internal();

  factory VoteService() => _instance;

  VoteService.internal();

  Future<Vote> createVote(
      String ownerId,
      String topic,
      String groupId,
      List<String> options,
      DateTime expires,
      bool enbabled,
      DateTime now) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(voteCollection.document());

      final Vote vote = new Vote(ds.documentID, ownerId, topic, groupId,
          options, expires, enbabled, now);
      final Map<String, dynamic> data = vote.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Vote.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Stream<QuerySnapshot> getVoteList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = voteCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<dynamic> updateVote(Vote vote) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(voteCollection.document(vote.id));

      await tx.update(ds.reference, vote.toMap());
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

  Future<dynamic> deleteVote(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(voteCollection.document(id));

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
