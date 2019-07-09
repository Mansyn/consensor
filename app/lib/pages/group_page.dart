import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/group.dart';
import 'package:consensor/models/user.dart';
import 'package:consensor/services/groups.dart';
import 'package:consensor/services/users.dart';
import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class GroupPage extends StatefulWidget {
  GroupPage(this.group, this.user, this.onWaiting);

  final Widget onWaiting;
  final Group group;
  final FirebaseUser user;

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final _formKey = GlobalKey<FormState>();

  GroupService _groupSvc = GroupService();
  UserService _userSvc = UserService();

  bool _isLoaded;
  List<User> _allUsers;
  List<User> _currentUsers;
  List<String> _selectedUsers;
  String _ownerId;
  String _errorMsg;

  TextEditingController _titleController;

  StreamSubscription<QuerySnapshot> _userSub;

  @override
  void initState() {
    _isLoaded = false;

    super.initState();

    _allUsers = List();
    _currentUsers = List();
    _selectedUsers = List();
    _ownerId = widget.user.uid;
    _titleController = TextEditingController(text: widget.group.title);
    _errorMsg = "";

    _userSub?.cancel();
    _userSub = _userSvc.getUserList().listen((QuerySnapshot snapshot) {
      List<User> allUsers = snapshot.documents
          .map((documentSnapshot) => User.fromMap(documentSnapshot.data))
          .toList();

      var owner = allUsers.firstWhere((_user) => _user.id == widget.user.uid);
      allUsers.remove(owner);

      setState(() {
        this._ownerId = owner.id;
        this._allUsers = allUsers;
      });

      this._syncUsers(widget.group.members);
    });
  }

  void _syncUsers(List<String> userids) {
    List<User> currentUsers = List();

    userids.forEach((userId) {
      var foundUser = this
          ._allUsers
          .firstWhere((_user) => _user.id == userId, orElse: () => null);
      if (foundUser != null) {
        currentUsers.add(foundUser);
      }
    });

    setState(() {
      this._currentUsers = currentUsers;
      this._selectedUsers = currentUsers.map((n) => n.id).toList();
      this._errorMsg = "";
      this._isLoaded = true;
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Scaffold(
        appBar: AppBar(
            title:
                Text('Create Group', style: TextStyle(color: kSurfaceWhite))),
        body: Container(
          margin: EdgeInsets.all(15.0),
          alignment: Alignment.center,
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.chat, color: kAccent400),
                        hintText: 'Please name your group',
                        labelText: 'Name',
                      ),
                      controller: _titleController,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      validator: (val) =>
                          val.isEmpty ? 'Name is required' : null),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.people, color: kAccent400),
                      Padding(padding: EdgeInsets.all(8.0)),
                      Expanded(
                        child: ChipsInput(
                            initialValue: _currentUsers,
                            decoration: InputDecoration(
                              labelText: "People",
                            ),
                            findSuggestions: (String query) {
                              if (query.length != 0) {
                                var lowercaseQuery = query.toLowerCase();
                                return _allUsers.where((user) {
                                  return user.displayName
                                      .toLowerCase()
                                      .contains(query.toLowerCase());
                                }).toList(growable: false)
                                  ..sort((a, b) => a.displayName
                                      .toLowerCase()
                                      .indexOf(lowercaseQuery)
                                      .compareTo(b.displayName
                                          .toLowerCase()
                                          .indexOf(lowercaseQuery)));
                              } else {
                                return const <User>[];
                              }
                            },
                            onChanged: (data) {
                              // sync selected and available users
                              var selectedUsers = List<User>.from(data);
                              this._syncUsers(
                                  selectedUsers.map((n) => n.id).toList());
                            },
                            chipBuilder: (context, state, user) {
                              return InputChip(
                                key: ObjectKey(user),
                                label: Text(user.displayName),
                                avatar: CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL),
                                ),
                                onDeleted: () => state.deleteChip(user),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            },
                            suggestionBuilder: (context, state, user) {
                              return ListTile(
                                key: ObjectKey(user),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL),
                                ),
                                title: Text(user.displayName),
                                subtitle: Text(user.email),
                                onTap: () => state.selectSuggestion(user),
                              );
                            }),
                      ),
                    ],
                  ),
                  Text(_errorMsg, style: TextStyle(color: kErrorRed)),
                  Padding(padding: EdgeInsets.all(5.0)),
                  RaisedButton(
                    child: (widget.group.id != null)
                        ? Text('Update', style: TextStyle(color: kSurfaceWhite))
                        : Text('Add', style: TextStyle(color: kSurfaceWhite)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (_selectedUsers.length == 0) {
                          setState(() {
                            _errorMsg = "Please add users to your group";
                          });
                        } else {
                          if (widget.group.id != null) {
                            _groupSvc
                                .updateGroup(Group(
                                    widget.group.id,
                                    _titleController.text,
                                    this._ownerId,
                                    _selectedUsers,
                                    new DateTime.now()))
                                .then((_) {
                              Navigator.pop(context);
                            });
                          } else {
                            _groupSvc
                                .createGroup(
                                    _titleController.text,
                                    this._ownerId,
                                    _selectedUsers,
                                    new DateTime.now())
                                .then((_) {
                              Navigator.pop(context);
                            });
                          }
                        }
                      }
                    },
                  ),
                ],
              )),
        ),
      );
    } else {
      return widget.onWaiting;
    }
  }
}
