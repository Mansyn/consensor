import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:consensor/theme/colors.dart';
import 'package:consensor/models/group.dart';
import 'package:consensor/routes/group.dart';
import 'package:consensor/services/group.dart';
import 'package:consensor/services/vote.dart';

class GroupWidget extends StatefulWidget {
  GroupWidget(this.user, this.onWaiting);

  final Widget onWaiting;
  final FirebaseUser user;

  @override
  _GroupWidgetState createState() => new _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  GroupService _groupSvc = new GroupService();
  VoteService _voteSvc = new VoteService();

  List<Group> _groups;

  StreamSubscription<QuerySnapshot> _groupSub;

  bool _isLoaded;

  @override
  void initState() {
    _isLoaded = false;
    super.initState();

    _groups = new List();

    _groupSub?.cancel();
    _groupSub = _groupSvc
        .getGroupList(widget.user.uid)
        .listen((QuerySnapshot snapshot) {
      final List<Group> groups = snapshot.documents
          .map((documentSnapshot) => Group.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this._groups = groups;
        this._isLoaded = true;
      });
    });
  }

  Widget build(BuildContext context) {
    if (_isLoaded) {
      if (_groups.length > 0) {
        return Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: getGroupPageBody(context));
      } else {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(child: Text('Create a group to get started')));
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

  getGroupPageBody(BuildContext context) {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: _getGroupUI,
      padding: EdgeInsets.all(0.0),
    );
  }

  Widget _getGroupUI(BuildContext context, int index) {
    return new Card(
        child: new Column(
      children: <Widget>[
        new ListTile(
          leading: CircleAvatar(
            backgroundColor: accentColor,
            child: Text(
              '${index + 1}',
            ),
          ),
          title: new Text(
            _groups[index].title,
            style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(_groups[index].createdOn(),
                    style: new TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.normal))
              ]),
          onTap: () {
            _navigateToGroup(context, _groups[index]);
          },
          onLongPress: () {
            _deleteDialog(context, _groups[index], index);
          },
        )
      ],
    ));
  }

  void _navigateToGroup(BuildContext context, Group group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              GroupPage(group, widget.user, widget.onWaiting)),
    );
  }

  void _deleteDialog(BuildContext context, Group group, int position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete Confirmation"),
          content: new Text("Are you sure you want to delete this group?"),
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
                _voteSvc.deleteGroupVotes(group.id);
                _groupSvc.deleteGroup(group.id).then((groups) {
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
    _groupSub?.cancel();
    super.dispose();
  }
}
