import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consensor/models/vote.dart';
import 'package:consensor/services/votes.dart';
import 'package:consensor/services/users.dart';
import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VotePage extends StatefulWidget {
  VotePage(this.vote, this.user);

  final Vote vote;
  final FirebaseUser user;

  @override
  State<StatefulWidget> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  VoteService _voteSvc = VoteService();
  UserService _userSvc = UserService();

  bool _isLoaded;
  String _ownerId;
  String _errorMsg;

  StreamSubscription<QuerySnapshot> _userSub;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _topicController;

  @override
  void initState() {
    _isLoaded = false;

    super.initState();

    _ownerId = widget.user.uid;
    _errorMsg = "";

    _topicController = TextEditingController(text: widget.vote.topic);

    _userSub?.cancel();
    _userSub = _userSvc.getUserList().listen((QuerySnapshot snapshot) {
      setState(() {
        this._ownerId = widget.user.uid;
      });
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SizedBox(
          child: CircularProgressIndicator(),
          height: 150.0,
          width: 150.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Scaffold(
        appBar:
            AppBar(title: Text('Vote', style: TextStyle(color: kSurfaceWhite))),
        body: Container(
          margin: EdgeInsets.all(15.0),
          alignment: Alignment.center,
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: _topicController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please name your vote';
                        }
                      }),
                ],
              )),
        ),
      );
    } else {
      return _buildWaitingScreen();
    }
  }
}
