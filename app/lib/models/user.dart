class User {
  final String key;
  final String displayName;

  const User({this.key, this.displayName});

  User.fromMap(Map<String, dynamic> data, String id)
      : this(
          key: id,
          displayName: data['displayName'],
        );
}
