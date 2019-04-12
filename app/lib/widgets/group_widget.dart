import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/user.dart';
import 'package:consensor/widgets/user_card.dart';
import 'package:flutter/material.dart';

class GroupWidget extends StatelessWidget {
  Center _buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference collectionReference =
        Firestore.instance.collection('users');
    Stream<QuerySnapshot> stream = collectionReference.snapshots();

    return Padding(
      // Padding before and after the list view:
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                return new ListView(
                  children: snapshot.data.documents.map((document) {
                    return new UserCard(
                        user: User.fromMap(document.data, document.documentID));
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
