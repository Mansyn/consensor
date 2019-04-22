class Vote {
  String _id;
  String _ownerId;
  String _topic;
  String _groupId;
  List<String> _options;

  Vote(this._id, this._ownerId, this._topic, this._groupId, this._options);

  Vote.map(dynamic obj) {
    this._id = obj['id'];
    this._ownerId = obj['ownerId'];
    this._topic = obj['topic'];
    this._groupId = obj['groupId'];
  }

  String get id => _id;
  String get ownerId => _ownerId;
  String get topic => _topic;
  String get groupId => _groupId;
  List<String> get options => _options;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['ownerId'] = _ownerId;
    map['topic'] = _topic;
    map['groupId'] = _groupId;
    map['options'] = _options;
    return map;
  }

  Vote.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._ownerId = map['ownerId'];
    this._topic = map['topic'];
    this._groupId = map['groupId'];
    this._options = List.from(map['options']);
  }
}
