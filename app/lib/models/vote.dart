import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Vote {
  String _id;
  String _ownerId;
  String _topic;
  String _groupId;
  List<String> _options;
  DateTime _expirationDate;
  DateTime _createdDate;

  Vote(this._id, this._ownerId, this._topic, this._groupId, this._options,
      this._expirationDate, this._createdDate);

  Vote.map(dynamic obj) {
    this._id = obj['id'];
    this._ownerId = obj['ownerId'];
    this._topic = obj['topic'];
    this._groupId = obj['groupId'];
    this._expirationDate = obj['expirationDate'];
    this._createdDate = obj['createdDate'];
  }

  String get id => _id;
  String get ownerId => _ownerId;
  String get topic => _topic;
  String get groupId => _groupId;
  List<String> get options => _options;
  DateTime get expirationDate => _expirationDate;
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
    this._createdDate = createdDate.toDate();
  }

  createdOn() {
    return DateFormat.yMMMd().format(this._createdDate);
  }

  expiresOn() {
    return DateFormat.yMMMd().format(this._expirationDate);
  }
}
