class User {
  String uid;
  String username;
  String imageUrl;

  User.fromMap({Map<String, dynamic> map}) {
    this.uid = map['uid'];
    this.username = map['username'];
    this.imageUrl = map['imageUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ uid: $uid, ';
    toPrint += 'username: $username, ';
    toPrint += 'imageUrl: $imageUrl }\n';
    return toPrint;
  }
}
