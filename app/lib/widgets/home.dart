import 'package:flutter/material.dart';
import 'package:consensor/theme/styles.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Build Some Consensus', style: heroTextStyle),
          Image.asset('assets/group.png', width: 200),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Center(child: Text('to begin create a group')))
        ]);
  }
}
