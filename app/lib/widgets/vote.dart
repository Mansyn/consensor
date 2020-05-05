import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:consensor/models/group.dart';
import 'package:consensor/theme/const.dart';
import 'package:consensor/theme/colors.dart';
import 'package:consensor/theme/styles.dart';
import 'package:consensor/models/vote.dart';
import 'package:consensor/services/vote.dart';
import 'package:consensor/services/group.dart';

class VoteWidget extends StatefulWidget {
  VoteWidget(this.user, this.onWaiting);

  final Widget onWaiting;
  final FirebaseUser user;

  @override
  _VoteWidgetState createState() => new _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  VoteService _voteSvc = new VoteService();
  GroupService _groupSvc = new GroupService();
  List<Vote> _votes;
  List<Group> _groups;
  DateTime _now;

  StreamSubscription<QuerySnapshot> _voteSub;
  StreamSubscription<QuerySnapshot> _groupSub;

  bool _isLoaded;

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _isLoaded = false;
    _now = new DateTime.now();
    super.initState();

    _votes = List();
    _groups = List();

    _voteSub?.cancel();
    _groupSub?.cancel();

    _voteSub = _voteSvc.getVoteList().listen((QuerySnapshot snapshot) {
      final List<Vote> votes = snapshot.documents
          .map((documentSnapshot) => Vote.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this._votes = votes;
        this._isLoaded = true;
      });
    });

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

  void _updateVote(Vote _vote) {
    _voteSvc.updateVote(_vote).then((result) {
      // Update the state:
      if (result == true) {
        print("update success");
      }
    });
  }

  void _deleteVote(BuildContext context, Vote vote, int position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete Confirmation"),
          content: new Text("Are you sure you want to delete this vote?"),
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
                _voteSvc.deleteVote(vote.id).then((votes) {
                  Navigator.of(context).pop();
                });
              },
            )
          ],
        );
      },
    );
  }

  _optionDialog(
      BuildContext context, Vote _vote, int index, String _currentText) async {
    _textEditingController.clear();
    _textEditingController.text = _currentText;
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Consts.padding),
            ),
            content: Row(
              children: <Widget>[
                Expanded(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.add_circle_outline),
                          labelText: 'OPTION',
                        ),
                        controller: _textEditingController))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (_textEditingController.text.length > 0) {
                      if (index > -1) {
                        _vote.options[index] =
                            (_textEditingController.text.toString());
                        _updateVote(_vote);
                      } else {
                        _vote.options
                            .add(_textEditingController.text.toString());
                        _updateVote(_vote);
                      }
                      Navigator.pop(context);
                    }
                  })
            ],
          );
        });
  }

  _groupDialog(BuildContext context, Vote _vote) async {
    return (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('Select group to poll'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Consts.padding),
              ),
              children: List.generate(_groups.length, (index) {
                return SimpleDialogOption(
                    onPressed: () {
                      _voteSvc.updateVoteGroup(_vote, _groups[index].id);
                      Navigator.pop(context, _groups[index].id);
                    },
                    child: Row(children: <Widget>[
                      Icon(Icons.group_work),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(_groups[index].title))
                    ]));
              }));
        }));
  }

  Widget _showOptionsList(Vote _vote) {
    List<String> _options = _vote.options;
    if (_options.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _options.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: primaryLightColor,
              child: ListTile(
                title: FlatButton(
                    child: Text(_options[index],
                        style: primaryTextStyle, textAlign: TextAlign.left),
                    onPressed: () {
                      _optionDialog(context, _vote, index, _options[index]);
                    }),
                trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: accentDarkColor),
                    onPressed: () {
                      _vote.options.remove(_options[index]);
                      _updateVote(_vote);
                    }),
              ),
            );
          });
    } else {
      return Center(child: Text("- Add some options -"));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      if (_votes.length > 0 && _groups.length > 0) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(
              child: ListView.builder(
                  itemCount: _votes.length,
                  padding: const EdgeInsets.all(15.0),
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                  leading:
                                      Icon(Icons.done, color: accentLightColor),
                                  title: Text(
                                    '${_votes[position].topic}',
                                    style: primaryH1TextStyle,
                                  ),
                                  subtitle: Text(_groups
                                          .firstWhere((group) =>
                                              group.id ==
                                              _votes[position].groupId)
                                          .title +
                                      " - expires ${_votes[position].expiresOn()}"),
                                  trailing: Ink(
                                      decoration: const ShapeDecoration(
                                        color: accentDarkColor,
                                        shape: CircleBorder(),
                                      ),
                                      child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: primaryColor),
                                          tooltip: 'Remove this vote',
                                          onPressed: () => _deleteVote(context,
                                              _votes[position], position))),
                                  onTap: () {/* set topic */}),
                              _showOptionsList(_votes[position]),
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('ADD'),
                                    onPressed: () {
                                      _optionDialog(
                                          context, _votes[position], -1, "");
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('GROUP'),
                                    onPressed: () async {
                                      _groupDialog(context, _votes[position]);
                                    },
                                  ),
                                  FlatButton(
                                      child: Text('EXPIRATION'),
                                      onPressed: () {
                                        DatePicker.showDateTimePicker(context,
                                            showTitleActions: true,
                                            onConfirm: (date) {
                                          _voteSvc.updateVoteExpiration(
                                              _votes[position], date);
                                        },
                                            currentTime: _votes[position]
                                                .expirationDate);
                                      }),
                                  FlatButton(
                                    child: Text('START'),
                                    onPressed: () {
                                      if (_votes[position].enabled) {
                                        // start
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5.0)),
                      ],
                    );
                  }),
            ));
      } else if (_groups.length > 0) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(child: Text('Start by creating a group')));
      } else if (_votes.length > 0) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(child: Text('Create a vote to get started')));
      }
    } else {
      return Center(
          child: SizedBox(
        child: SpinKitChasingDots(color: accentColor, size: 100.0),
        height: 100.0,
        width: 100.0,
      ));
    }
    return null;
  }

  @override
  void dispose() {
    _voteSub?.cancel();
    super.dispose();
  }
}
