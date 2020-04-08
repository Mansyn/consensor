import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {
  Future<FirebaseUser> googleSignIn();

  Future<FirebaseUser> facebookSignIn();

  updateUserData(FirebaseUser user);

  Future<FirebaseUser> getCurrentUser();

  Future<void> signOut();
}

class Auth implements BaseAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Future<FirebaseUser> googleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;

    updateUserData(user = result.user);

    print("signed in " + user.displayName);
    return user;
  }

  Future<FirebaseUser> facebookSignIn() async {
    FacebookLoginResult fbUser = await _facebookLogin.logIn(['email']);

    if (fbUser.status == FacebookLoginStatus.loggedIn) {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: fbUser.accessToken.token);

      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;

      updateUserData(user);

      print("signed in " + user.displayName);
      return user;
    }
    return null;
  }

  Future<void> updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);

    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': DateTime.now()
    }, merge: true);
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    if (_googleSignIn.currentUser != null) {
      await _googleSignIn.signOut();
    } else if (await _facebookLogin.isLoggedIn) {
      await _facebookLogin.logOut();
    }
    return _auth.signOut();
  }
}
