import 'package:consensor/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:consensor/services/authentication.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  String _errorMessage;

  // Initial form is login form
  bool _isIos;
  bool _isLoading;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _googleSignIn() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      var user = await widget.auth.googleSignIn();
      setState(() {
        _isLoading = false;
      });
      if (user != null) {
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
          title: new Text('Login...'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Hero(
                tag: 'hero',
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 70.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 48.0,
                    child: Image.asset('assets/ic_launcher.png'),
                  ),
                ),
              ),
              _showGoogleButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new SizedBox(height: 20),
            Text(_errorMessage,
                style: TextStyle(
                    fontSize: 15.0,
                    color: kErrorRed,
                    height: 1.0,
                    fontWeight: FontWeight.w300)),
          ]);
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showGoogleButton() {
    return new Center(
        child: FlatButton.icon(
      color: Color.fromARGB(255, 245, 245, 245),
      icon: Image.asset(
        'assets/google-logo-g.png',
        height: 20,
      ),
      label: Text('Sign in with Google'),
      onPressed: () => _googleSignIn(),
    ));
  }
}
