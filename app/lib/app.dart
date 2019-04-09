import 'package:flutter/material.dart';

// internal
import 'package:consensor/theme/build_theme.dart';
import 'package:consensor/services/authentication.dart';
import 'package:consensor/pages/root_page.dart';

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

final ThemeData _kConsensorTheme = FartThemeBuilder.build();
