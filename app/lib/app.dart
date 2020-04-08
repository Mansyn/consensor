import 'package:flutter/material.dart';

import 'package:consensor/routes/root.dart';
import 'package:consensor/theme/build.dart';
import 'package:consensor/services/auth.dart';

class ConsensusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Consensor',
        debugShowCheckedModeBanner: false,
        theme: _kConsensorTheme,
        home: new RootPage(auth: new Auth()));
  }
}

final ThemeData _kConsensorTheme = ConsensorThemeBuilder.build();
