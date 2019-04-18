class User {
  String _id;
  String _displayName;
  String _email;
  String _photoURL;

  User(this._id, this._displayName, this._email, this._photoURL);

  User.map(dynamic obj) {
    this._id = obj['id'];
    this._displayName = obj['displayName'];
    this._email = obj['mail'];
    this._photoURL = obj['photoURL'];
  }

  String get id => _id;
  String get displayName => _displayName;
  String get email => _email;
  String get photoURL => _photoURL;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['displayName'] = _displayName;
    map['email'] = _email;
    map['photoURL'] = _photoURL;
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    this._id = map['uid'];
    this._displayName = map['displayName'];
    this._email = map['email'];
    this._photoURL = map['photoURL'];
  }
}
