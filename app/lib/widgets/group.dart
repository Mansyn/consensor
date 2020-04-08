import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:consensor/theme/colors.dart';
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
  List<Group> _items;

  StreamSubscription<QuerySnapshot> _groupSub;

  @override
  void initState() {
    super.initState();

    _items = new List();

    _groupSub?.cancel();
    _groupSub = _groupSvc
        .getGroupList(widget.user.uid)
        .listen((QuerySnapshot snapshot) {
      final List<Group> groups = snapshot.documents
          .map((documentSnapshot) => Group.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this._items = groups;
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
                          '${_items[position].title}',
                          style: TextStyle(fontSize: 28.0),
                        ),
                        subtitle: Text(
                          'created on ${_items[position].createdOn()}',
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
                                onPressed: () => _deleteNote(
                                    context, _items[position], position)),
                          ],
                        ),
                        onTap: () => _navigateToNote(context, _items[position]),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                    ],
                  );
                }),
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Center(child: Text('Create a group to get started')));
    }
  }

  void _deleteNote(BuildContext context, Group group, int position) async {
    _groupSvc.deleteGroup(group.id).then((groups) {
      setState(() {
        _items.removeAt(position);
      });
    });
  }

  void _navigateToNote(BuildContext context, Group group) async {
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
