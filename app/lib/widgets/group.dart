import 'dart:async';

import 'package:consensor/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:consensor/theme/styles.dart';
import 'package:consensor/models/group.dart';
import 'package:consensor/routes/group.dart';
import 'package:consensor/services/group.dart';

class GroupWidget extends StatefulWidget {
  GroupWidget(this.user, this.onWaiting);

  final Widget onWaiting;
  final FirebaseUser user;

  @override
  _GroupWidgetState createState() => new _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  GroupService _groupSvc = new GroupService();
  List<Group> _groups;

  StreamSubscription<QuerySnapshot> _groupSub;

  List _elements = [
    {'name': 'John', 'group': 'Team A'},
    {'name': 'Will', 'group': 'Team B'},
    {'name': 'Beth', 'group': 'Team A'},
    {'name': 'Miranda', 'group': 'Team B'},
    {'name': 'Mike', 'group': 'Team C'},
    {'name': 'Danny', 'group': 'Team C'},
  ];

  @override
  void initState() {
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
      });
    });
  }

  Widget build(BuildContext context) {
    if (_groups.length > 0) {
      return Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: getGroupPageBody(context));
    } else {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Center(child: Text('Create a group to get started')));
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
        )
      ],
    ));
  }

  void _deleteNote(BuildContext context, Group group, int position) async {
    _groupSvc.deleteGroup(group.id).then((groups) {
      setState(() {
        _groups.removeAt(position);
      });
    });
  }

  void _navigateToGroup(BuildContext context, Group group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              GroupPage(group, widget.user, widget.onWaiting)),
    );
  }

  @override
  void dispose() {
    _groupSub?.cancel();
    super.dispose();
  }
}
