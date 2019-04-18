class Group {
  String _id;
  String _title;
  String _ownerId;
  List<String> _members;

  Group(this._id, this._title, this._ownerId, this._members);

  Group.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._ownerId = obj['ownerId'];
  }

  String get id => _id;
  String get title => _title;
  String get ownerId => _ownerId;
  List<String> get members => _members;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['ownerId'] = _ownerId;
    map['members'] = _members;
    return map;
  }

  Group.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._ownerId = map['ownerId'];
    this._members = List.from(map['members']);
  }
}
