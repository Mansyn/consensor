import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:consensor/utils/extensions.dart';

class Vote {
  String _id;
  String _ownerId;
  String _topic;
  String _groupId;
  List<String> _options;
  DateTime _expirationDate;
  bool _enabled;
  DateTime _createdDate;

  Vote(this._id, this._ownerId, this._topic, this._groupId, this._options,
      this._expirationDate, this._enabled, this._createdDate);

  Vote.map(dynamic obj) {
    this._id = obj['id'];
    this._ownerId = obj['ownerId'];
    this._topic = obj['topic'];
    this._groupId = obj['groupId'];
    this._expirationDate = obj['expirationDate'];
    this._enabled = obj['enabled'];
    this._createdDate = obj['createdDate'];
  }

  String get id => _id;
  String get ownerId => _ownerId;
  String get topic => _topic;
  String get groupId => _groupId;
  List<String> get options => _options;
  DateTime get expirationDate => _expirationDate;
  bool get enabled => _enabled;
  DateTime get createdDate => _createdDate;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['ownerId'] = _ownerId;
    map['topic'] = _topic;
    map['groupId'] = _groupId;
    map['options'] = _options;
    map['expirationDate'] = _expirationDate;
    map['enabled'] = _enabled;
    map['createdDate'] = _createdDate;
    return map;
  }

  Map<String, dynamic> toMapGroup(String groupId) {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['ownerId'] = _ownerId;
    map['topic'] = _topic;
    map['groupId'] = groupId;
    map['options'] = _options;
    map['expirationDate'] = _expirationDate;
    map['enabled'] = _enabled;
    map['createdDate'] = _createdDate;
    return map;
  }

  Map<String, dynamic> toMapExpiration(DateTime expiration) {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['ownerId'] = _ownerId;
    map['topic'] = _topic;
    map['groupId'] = _groupId;
    map['options'] = _options;
    map['expirationDate'] = expiration;
    map['enabled'] = _enabled;
    map['createdDate'] = _createdDate;
    return map;
  }

  Vote.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._ownerId = map['ownerId'];
    this._topic = map['topic'];
    this._groupId = map['groupId'];
    this._options = List.from(map['options']);
    Timestamp expirationDate = map['expirationDate'];
    this._expirationDate = expirationDate.toDate();
    Timestamp createdDate = map['createdDate'];
    this._enabled = map['enabled'];
    this._createdDate = createdDate.toDate();
  }

  createdOn() {
    return DateFormat.yMMMd().format(this._createdDate);
  }

  expiresOn() {
    final now = DateTime.now();
    if (this.expirationDate.isSameDate(now)) {
      return DateFormat.jm().format(this._expirationDate);
    } else {
      return DateFormat.yMd().format(this._expirationDate);
    }
  }
}
