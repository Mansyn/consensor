import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/group.dart';
import 'package:consensor/pages/group_page.dart';
import 'package:consensor/services/groups.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupWidget extends StatefulWidget {
  GroupWidget(this.user);

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
    _groupSub = _groupSvc.getGroupList().listen((QuerySnapshot snapshot) {
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
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      subtitle: Text(
                        '# of people ${_items[position].members.length}',
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      leading: Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(10.0)),
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
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
                  ],
                );
              }),
        ));
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
      MaterialPageRoute(builder: (context) => GroupPage(group, widget.user)),
    );
  }

  @override
  void dispose() {
    _groupSub?.cancel();
    super.dispose();
  }
}
