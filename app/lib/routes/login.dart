import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:consensor/theme/styles.dart';
import 'package:consensor/theme/colors.dart';
import 'package:consensor/services/auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum OauthProvider { GOOGLE, FACEBOOK }

class _LoginPageState extends State<LoginPage> {
  OauthProvider _oauthProvider;
  String _errorMessage;

  bool _isIos;
  bool _isLoading;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _signIn(OauthProvider provider) async {
    setState(() {
      _oauthProvider = provider;
      _errorMessage = "";
      _isLoading = true;
    });

    FirebaseUser _user;

    try {
      switch (_oauthProvider) {
        case OauthProvider.GOOGLE:
          _user = await widget.auth.googleSignIn();
          break;
        case OauthProvider.FACEBOOK:
          _user = await widget.auth.facebookSignIn();
          break;
      }
      setState(() {
        _isLoading = false;
      });
      if (_user != null) {
        widget.onSignedIn();
      }
    } on NoSuchMethodError catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "There was a problem signing you in";
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        if (_isIos) {
          _errorMessage = e.details;
        } else {
          _errorMessage = e.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Login'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Hero(
                tag: 'hero',
                child: Center(
                    child: Container(
                        height: 200,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                  backgroundColor: accentColor,
                                  child: Icon(Icons.thumbs_up_down, size: 75),
                                  radius: 48.0),
                              Text("CONSENSOR", style: heroTextStyle)
                            ])))),
            _showLoginButtons(),
            _showErrorMessage(),
          ],
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Center(
          child: Text(_errorMessage,
              style: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xffd32f2f),
                  height: 1.0,
                  fontWeight: FontWeight.w300)));
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _showLoginButtons() {
    if (_isLoading) {
      return Center(
          child: SizedBox(
        child: CircularProgressIndicator(),
        height: 100.0,
        width: 100.0,
      ));
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SignInButton(
            Buttons.Google,
            onPressed: () => _signIn(OauthProvider.GOOGLE),
          ),
          SignInButton(
            Buttons.Facebook,
            onPressed: () => _signIn(OauthProvider.FACEBOOK),
          ),
        ]);
  }
}
