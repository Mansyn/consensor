import 'package:consensor/theme/colors.dart';
import 'package:flutter/material.dart';

class ConsensorThemeBuilder {
  static ThemeData build() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      accentColor: kAccent400,
      primaryColor: kPrimary400,
      scaffoldBackgroundColor: kBackgroundWhite,
      cardColor: kPrimary50,
      textSelectionColor: kPrimary400,
      errorColor: kErrorRed,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kPrimary400,
        textTheme: ButtonTextTheme.normal,
      ),
      primaryIconTheme: base.iconTheme.copyWith(color: kBackground),
      textTheme: _buildTextTheme(base.primaryTextTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      iconTheme: _customIconTheme(base.iconTheme),
    );
  }

  static IconThemeData _customIconTheme(IconThemeData original) {
    return original.copyWith(color: kBackground);
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.apply(
      fontFamily: 'Nunito',
      displayColor: kText,
      bodyColor: kText,
    );
  }
}
