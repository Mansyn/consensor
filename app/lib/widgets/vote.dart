import 'dart:async';

import 'package:consensor/widgets/vote_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:consensor/models/vote.dart';
import 'package:consensor/services/vote.dart';

class VoteWidget extends StatefulWidget {
  VoteWidget(this.user, this.onWaiting);

  final Widget onWaiting;
  final FirebaseUser user;

  @override
  _VoteWidgetState createState() => new _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  VoteService _voteSvc = new VoteService();
  List<Vote> _votes;

  StreamSubscription<QuerySnapshot> _voteSub;

  bool _isLoaded;

  @override
  void initState() {
    _isLoaded = false;
    super.initState();

    _votes = new List();

    _voteSub?.cancel();
    _voteSub = _voteSvc.getVoteList().listen((QuerySnapshot snapshot) {
      final List<Vote> votes = snapshot.documents
          .map((documentSnapshot) => Vote.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this._votes = votes;
        this._isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      if (_votes.length > 0) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(
              child: ListView.builder(
                  itemCount: _votes.length,
                  padding: const EdgeInsets.all(15.0),
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                  leading: Icon(Icons.done),
                                  title: Text(
                                    '${_votes[position].topic}',
                                    style: TextStyle(fontSize: 22.0),
                                  ),
                                  subtitle: Text(
                                      'expires on ${_votes[position].expiresOn()}'),
                                  trailing: IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => _deleteVote(
                                          context, _votes[position], position)),
                                  onTap: () {/* set topic */}),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('OPTIONS'),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              MyDialog(
                                                title: "Success",
                                                description:
                                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                                buttonText: "Okay",
                                              ));
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('GROUP'),
                                    onPressed: () {/* ... */},
                                  ),
                                  FlatButton(
                                    child: Text('EXPIRATION'),
                                    onPressed: () {/* ... */},
                                  ),
                                  FlatButton(
                                    child: Text(_votes[position].enabled
                                        ? 'STOP'
                                        : 'START'),
                                    onPressed: () {/* ... */},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5.0)),
                      ],
                    );
                  }),
            ));
      } else {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(child: Text('Create a vote to get started')));
      }
    } else {
      return Center(
          child: SizedBox(
        child: CircularProgressIndicator(),
        height: 100.0,
        width: 100.0,
      ));
    }
  }

  void _deleteVote(BuildContext context, Vote vote, int position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete Confirmation"),
          content: new Text("Are you sure you want to delete this vote?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Confirm"),
              onPressed: () {
                _voteSvc.deleteVote(vote.id).then((votes) {
                  Navigator.of(context).pop();
                });
              },
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _voteSub?.cancel();
    super.dispose();
  }
}
