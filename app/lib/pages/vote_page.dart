import 'package:consensor/models/vote.dart';
import 'package:consensor/services/groups.dart';
import 'package:consensor/services/votes.dart';
import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  String _selectedGroupId;

  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];

  @override
  void initState() {
    _isLoaded = true;

    super.initState();

    _ownerId = widget.user.uid;
    _errorMsg = "";

    _topicController = TextEditingController(text: widget.vote.topic);
    _selectedGroupId = widget.vote.groupId;
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
                      controller: _topicController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please name your vote';
                        }
                      }),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.chat),
                      hintText: 'What do you want to vote on',
                      labelText: 'Topic',
                    ),
                  ),
                  FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.color_lens),
                          labelText: 'Group',
                        ),
                        isEmpty: _selectedGroupId == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            value: _selectedGroupId,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                _selectedGroupId = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _colors.map((String value) {
                              return new DropdownMenuItem(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  Text(_errorMsg, style: TextStyle(color: kErrorRed)),
                  Padding(padding: EdgeInsets.all(5.0)),
                  RaisedButton(
                    child: (widget.vote.id != null)
                        ? Text('Update', style: TextStyle(color: kSurfaceWhite))
                        : Text('Add', style: TextStyle(color: kSurfaceWhite)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (widget.vote.id != null) {
                          _voteSvc
                              .updateVote(Vote(
                                  widget.vote.id,
                                  this._ownerId,
                                  _topicController.text,
                                  widget.vote.groupId,
                                  widget.vote.options,
                                  DateTime.now(),
                                  DateTime.now()))
                              .then((_) {
                            Navigator.pop(context);
                          });
                        } else {
                          _voteSvc
                              .createVote(
                                  this._ownerId,
                                  _topicController.text,
                                  widget.vote.groupId,
                                  widget.vote.options,
                                  DateTime.now(),
                                  DateTime.now())
                              .then((_) {
                            Navigator.pop(context);
                          });
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
