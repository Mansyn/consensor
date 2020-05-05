import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:folding_cell/folding_cell.dart';

import 'package:consensor/services/group.dart';
import 'package:consensor/services/user.dart';
import 'package:consensor/models/user.dart';
import 'package:consensor/models/group.dart';
import 'package:consensor/theme/colors.dart';
import 'package:consensor/theme/styles.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget(this.user);

  final FirebaseUser user;

  @override
  _HomeWidgetState createState() => new _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  GroupService _groupSvc = new GroupService();
  UserService _userSvc = UserService();

  List<Group> _groups;
  List<User> _allUsers;

  StreamSubscription<QuerySnapshot> _groupSub;
  StreamSubscription<QuerySnapshot> _userSub;

  bool _isLoaded;

  @override
  void initState() {
    _isLoaded = false;
    super.initState();

    _groups = new List();
    _allUsers = List();

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

    _userSub?.cancel();
    _userSub = _userSvc.getUserList().listen((QuerySnapshot snapshot) {
      List<User> allUsers = snapshot.documents
          .map((documentSnapshot) => User.fromMap(documentSnapshot.data))
          .toList();

      var owner = allUsers.firstWhere((_user) => _user.id == widget.user.uid);
      allUsers.remove(owner);

      setState(() {
        this._allUsers = allUsers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      if (_groups.length > 0 && _allUsers.length > 0) {
        return Container(
          child: ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                return SimpleFoldingCell(
                    frontWidget: _buildFrontWidget(index),
                    innerTopWidget: _buildInnerTopWidget(index),
                    innerBottomWidget: _buildInnerBottomWidget(index),
                    cellSize: Size(MediaQuery.of(context).size.width, 125),
                    padding: EdgeInsets.all(15),
                    animationDuration: Duration(milliseconds: 300),
                    borderRadius: 10,
                    onOpen: () => print('$index cell opened'),
                    onClose: () => print('$index cell closed'));
              }),
        );
      } else {
        return Center(
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
              Icon(Icons.people, color: accentLightColor, size: 200),
              Text('to begin create a group')
            ])));
      }
    } else {
      return Center(
          child: SizedBox(
        child: SpinKitChasingDots(color: accentColor, size: 100.0),
        height: 100.0,
        width: 100.0,
      ));
    }
  }

  Widget _buildFrontWidget(int index) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
            color: primaryLightColor,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(_groups[index].title, style: primaryH1TextStyle),
                IconButton(
                  icon: Icon(Icons.expand_more),
                  tooltip: 'expand group',
                  onPressed: () {
                    SimpleFoldingCellState foldingCellState = context
                        .findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  },
                )
              ],
            ));
      },
    );
  }

  String getUserName(String userId) {
    return _allUsers.firstWhere((user) => user.id == userId).displayName;
  }

  Widget _buildInnerTopWidget(int index) {
    return Container(
        color: accentDarkColor,
        alignment: Alignment.center,
        child: Text(
            _groups[index]
                .members
                .map((userId) => getUserName(userId))
                .join(', '),
            style: primaryTextStyle));
  }

  Widget _buildInnerBottomWidget(int index) {
    return Builder(builder: (context) {
      return Container(
        color: primaryColor,
        alignment: Alignment.bottomCenter,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Current Votes:"),
              IconButton(
                  icon: Icon(Icons.expand_less),
                  tooltip: 'close group',
                  onPressed: () {
                    SimpleFoldingCellState foldingCellState = context
                        .findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  })
            ]),
      );
    });
  }
}
