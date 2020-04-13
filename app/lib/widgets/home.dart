import 'package:flutter/material.dart';

import 'package:consensor/theme/colors.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
          Icon(Icons.people, color: accentColor, size: 200),
          Text('to begin create a group')
        ])));
  }
}
