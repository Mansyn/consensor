import 'dart:io';

import 'package:consensor/models/group.dart';
import 'package:consensor/pages/group_page.dart';
import 'package:consensor/theme/colors.dart';
import 'package:consensor/widgets/group_widget.dart';
import 'package:consensor/widgets/home_widget.dart';
import 'package:consensor/widgets/vote_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:consensor/services/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.user, this.onSignedOut, this.onWaiting})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final FirebaseUser user;
  final Widget onWaiting;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

enum PageStatus {
  HOME,
  GROUPS,
  VOTES,
}

class _HomePageState extends State<HomePage> {
  PageStatus pageStatus;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  get _userInitial =>
      widget.user != null ? widget.user.displayName.substring(0, 1) : "";

  @override
  void initState() {
    super.initState();
    pageStatus = PageStatus.HOME;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _resolveSubTitle() {
    switch (pageStatus) {
      case PageStatus.HOME:
        return " - Home";
        break;
      case PageStatus.GROUPS:
        return " - Your Groups";
        break;
      case PageStatus.VOTES:
        return " - Vote";
        break;
    }
    return null;
  }

  Future<bool> _onBackPress() {
    _askExit();
    return Future.value(false);
  }

  Future _askExit() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: new Text('Are you sure to exit app?'),
              children: <Widget>[
                new SimpleDialogOption(
                  child: new Text('OK'),
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                ),
                new SimpleDialogOption(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                )
              ]);
        })) {
      case 1:
        exit(0);
        break;
      case 0:
        break;
    }
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget _showBody() {
    switch (pageStatus) {
      case PageStatus.HOME:
        return HomeWidget();
        break;
      case PageStatus.GROUPS:
        return GroupWidget(widget.user);
        break;
      case PageStatus.VOTES:
        return VoteWidget(widget.user);
        break;
      default:
        return widget.onWaiting;
    }
  }

  void _createNewGroup(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              GroupPage(Group(null, '', widget.user.uid, List()), widget.user)),
    );
  }

  Widget _showFloatingAction() {
    switch (pageStatus) {
      case PageStatus.HOME:
        return null;
        break;
      case PageStatus.GROUPS:
        return FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Create New Group",
          onPressed: () => _createNewGroup(context),
        );
        break;
      case PageStatus.VOTES:
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => {},
        );
        break;
      default:
        return null;
    }
  }

  Widget _getAccountPIcture() {
    if (widget.user.photoUrl != null && widget.user.photoUrl.length > 0) {
      return CircleAvatar(
          backgroundColor: kPrimary100,
          backgroundImage: NetworkImage(widget.user.photoUrl));
    } else {
      return CircleAvatar(
        backgroundColor: kPrimary100,
        child: Text(
          _userInitial,
          style: TextStyle(fontSize: 40.0),
        ),
      );
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: Text(widget.user.displayName,
                  style: TextStyle(color: kSurfaceWhite)),
              accountEmail: Text(widget.user.email,
                  style: TextStyle(color: kSurfaceWhite)),
              currentAccountPicture: _getAccountPIcture()),
          ListTile(
              title: Text("Home"),
              trailing: Icon(Icons.home),
              onTap: () {
                setState(() {
                  pageStatus = PageStatus.HOME;
                });
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text("Your Groups"),
              trailing: Icon(Icons.group_work),
              onTap: () {
                setState(() {
                  pageStatus = PageStatus.GROUPS;
                });
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text("Your Votes"),
              trailing: Icon(Icons.done),
              onTap: () {
                setState(() {
                  pageStatus = PageStatus.VOTES;
                });
                Navigator.of(context).pop();
              }),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: ListTile(
                  title: Text("Logout"),
                  trailing: Icon(Icons.exit_to_app),
                  onTap: () {
                    Navigator.of(context).pop();
                    _signOut();
                  }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                title: Text('Consensor' + _resolveSubTitle(),
                    style: TextStyle(color: kSurfaceWhite))),
            body: _showBody(),
            drawer: _buildDrawer(),
            floatingActionButton: _showFloatingAction()),
        onWillPop: _onBackPress);
  }
}
