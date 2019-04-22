import 'package:flutter/material.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(children: <Widget>[
          Text('build some consensus', style: TextStyle(fontSize: 32)),
          Image.asset('assets/group.png', width: 200),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Center(child: Text('to begin create a group')))
        ]));
  }
}
