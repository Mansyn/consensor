import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/vote.dart';
import 'package:consensor/pages/vote_page.dart';
import 'package:consensor/services/votes.dart';
import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VoteWidget extends StatefulWidget {
  VoteWidget(this.user, this.onWaiting);

  final Widget onWaiting;
  final FirebaseUser user;

  @override
  _VoteWidgetState createState() => new _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  VoteService _voteSvc = new VoteService();
  List<Vote> _items;

  StreamSubscription<QuerySnapshot> _voteSub;

  @override
  void initState() {
    super.initState();

    _items = new List();

    _voteSub?.cancel();
    _voteSub = _voteSvc.getVoteList().listen((QuerySnapshot snapshot) {
      final List<Vote> votes = snapshot.documents
          .map((documentSnapshot) => Vote.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this._items = votes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.length > 0) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Center(
            child: ListView.builder(
                itemCount: _items.length,
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
                                  '${_items[position].topic}',
                                  style: TextStyle(fontSize: 22.0),
                                ),
                                subtitle: Text(
                                    'expires on ${_items[position].expiresOn()}'),
                                trailing: IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _deleteVote(
                                        context, _items[position], position)),
                                onTap: () {/* set topic */}),
                            ButtonTheme.bar(
                              child: ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('OPTIONS'),
                                    onPressed: () {/* ... */},
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
                                    child: Text(_items[position].enabled
                                        ? 'STOP'
                                        : 'START'),
                                    onPressed: () {/* ... */},
                                  ),
                                ],
                              ),
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
  }

  void _deleteVote(BuildContext context, Vote vote, int position) async {
    _voteSvc.deleteVote(vote.id).then((votes) {
      setState(() {
        _items.removeAt(position);
      });
    });
  }

  void _navigateToVote(BuildContext context, Vote vote) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VotePage(vote, widget.user, widget.onWaiting)),
    );
  }

  @override
  void dispose() {
    _voteSub?.cancel();
    super.dispose();
  }
}
