import 'package:consensor/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:consensor/services/authentication.dart';

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
          title: new Text('Login',
              style: TextStyle(fontSize: 17.0, color: kSurfaceWhite)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Hero(
                tag: 'hero',
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: kAccent400,
                          child: Icon(Icons.bubble_chart, size: 75),
                          radius: 48.0),
                      SizedBox(height: 15),
                      Text("CONSENSOR",
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Yatra_One',
                              color: kAccent400))
                    ])),
            _showLoginButtons(),
            _showErrorMessage(),
          ],
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(_errorMessage,
                style: TextStyle(
                    fontSize: 15.0,
                    color: kErrorRed,
                    height: 1.0,
                    fontWeight: FontWeight.w300)),
          ]);
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _showLoginButtons() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton.icon(
            color: Color.fromARGB(255, 245, 245, 245),
            icon: Image.asset(
              'assets/google-logo-g.png',
              height: 20,
            ),
            label: Text('Sign in with Google',
                style: TextStyle(fontFamily: 'Roboto')),
            onPressed: () => _signIn(OauthProvider.GOOGLE),
          ),
          FlatButton.icon(
            color: Color.fromARGB(255, 245, 245, 245),
            icon: Image.asset(
              'assets/facebook-logo-f.png',
              height: 20,
            ),
            label: Text('Sign in with Facebook',
                style: TextStyle(fontFamily: 'Roboto')),
            onPressed: () => _signIn(OauthProvider.FACEBOOK),
          )
        ]);
  }
}
