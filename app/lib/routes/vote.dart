import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:consensor/models/group.dart';
import 'package:consensor/models/vote.dart';
import 'package:consensor/services/group.dart';
import 'package:consensor/services/vote.dart';
import 'package:consensor/theme/colors.dart';

class VotePage extends StatefulWidget {
  VotePage(this.vote, this.user, this.onWaiting);

  final Widget onWaiting;
  final Vote vote;
  final FirebaseUser user;

  @override
  State<StatefulWidget> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  VoteService _voteSvc = VoteService();
  GroupService _groupSvc = GroupService();

  bool _isLoaded;
  String _ownerId;
  String _errorMsg;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _topicController;
  TextEditingController _expireController;

  StreamSubscription<QuerySnapshot> _groupSub;
  List<Group> _userGroups;
  String _selectedGroupId;

  @override
  void initState() {
    this._isLoaded = false;
    this._userGroups = List();
    super.initState();

    _topicController = TextEditingController(text: widget.vote.topic);
    _expireController = TextEditingController(
        text: DateFormat.yMd().add_jm().format(widget.vote.expirationDate));
    _errorMsg = "";

    _groupSub?.cancel();
    _groupSub = _groupSvc
        .getGroupList(widget.user.uid)
        .listen((QuerySnapshot snapshot) {
      final List<Group> groups = snapshot.documents
          .map((documentSnapshot) => Group.fromMap(documentSnapshot.data))
          .toList();

      var foundGroup = groups.firstWhere(
          (_group) => _group.id == widget.vote.groupId,
          orElse: () => null);

      setState(() {
        this._ownerId = widget.user.uid;
        this._userGroups = groups;
        this._selectedGroupId = foundGroup?.id;
        this._isLoaded = true;
      });
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateFormat.yMd().add_jm().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  bool isValidExpiration(String dob) {
    if (dob.isEmpty) return true;
    var d = convertToDate(dob);
    return d != null && d.isAfter(DateTime.now());
  }

  Future _chooseExpirationDate(
      BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year <= 2099 && initialDate.isAfter(now)
        ? initialDate
        : now);

    var dateResult = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: DateTime(2099));

    if (dateResult == null) return;

    var timeResult = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (timeResult == null) return;

    var newDate = DateTime(dateResult.year, dateResult.month, dateResult.day,
        timeResult.hour, timeResult.minute);
    setState(() {
      _expireController.text = DateFormat.yMd().add_jm().format(newDate);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Create Vote', style: TextStyle(color: kSurfaceWhite))),
        body: Container(
          margin: EdgeInsets.all(15.0),
          alignment: Alignment.center,
          child: Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.chat, color: kAccent400),
                      hintText: 'What do you want to vote on',
                      labelText: 'Topic',
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(30)],
                    validator: (val) =>
                        val.isEmpty ? 'Topic is required' : null,
                    controller: _topicController,
                  ),
                  FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.color_lens, color: kAccent400),
                          labelText: 'Group',
                        ),
                        isEmpty: _selectedGroupId == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _selectedGroupId,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                _selectedGroupId = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _userGroups.map((Group _group) {
                              return DropdownMenuItem(
                                value: _group.id,
                                child: Text(_group.title),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(children: <Widget>[
                    Expanded(
                        child: TextFormField(
                      decoration: InputDecoration(
                        icon:
                            const Icon(Icons.calendar_today, color: kAccent400),
                        hintText: 'Enter your when vote expires',
                        labelText: 'End of vote',
                      ),
                      enabled: false,
                      controller: _expireController,
                      keyboardType: TextInputType.datetime,
                      validator: (val) => isValidExpiration(val)
                          ? null
                          : 'Not a valid, future date',
                    )),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: kText),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseExpirationDate(context, _expireController.text);
                      }),
                    )
                  ]),
                  Text(_errorMsg, style: TextStyle(color: kErrorRed)),
                  Padding(padding: EdgeInsets.all(5.0)),
                  RaisedButton(
                    child: (widget.vote.id != null)
                        ? Text('Update', style: TextStyle(color: kSurfaceWhite))
                        : Text('Add', style: TextStyle(color: kSurfaceWhite)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (widget.vote.id != null) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
                  )
                ],
              )),
        ),
      );
    } else {
      return widget.onWaiting;
    }
  }
}
