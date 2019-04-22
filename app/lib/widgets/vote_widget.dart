import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/vote.dart';
import 'package:consensor/pages/vote_page.dart';
import 'package:consensor/services/votes.dart';
import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VoteWidget extends StatefulWidget {
  VoteWidget(this.user);

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
                      Divider(height: 5.0),
                      ListTile(
                        title: Text(
                          '${_items[position].topic}',
                          style: TextStyle(fontSize: 26.0),
                        ),
                        subtitle: Text(
                          '# of people ${_items[position].ownerId}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        leading: Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(10.0)),
                            CircleAvatar(
                              backgroundColor: kPrimary50,
                              radius: 15.0,
                              child: Text(
                                '${position + 1}',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _deleteVote(
                                    context, _items[position], position)),
                          ],
                        ),
                        onTap: () => _navigateToVote(context, _items[position]),
                      ),
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
      MaterialPageRoute(builder: (context) => VotePage(vote, widget.user)),
    );
  }

  @override
  void dispose() {
    _voteSub?.cancel();
    super.dispose();
  }
}
