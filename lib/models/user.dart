class User {
  String uid;
  String phoneNumber;
  String username;
  String imageUrl;

  User({
    this.uid,
    this.phoneNumber,
    this.username,
    this.imageUrl,
  });

  User.fromMap({Map<String, dynamic> map}) {
    this.uid = map['uid'];
    this.phoneNumber = map['phoneNumber'];
    this.username = map['username'];
    this.imageUrl = map['imageUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'username': username,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ uid: $uid, ';
    toPrint += 'phoneNumber: $phoneNumber, ';
    toPrint += 'username: $username, ';
    toPrint += 'imageUrl: $imageUrl }\n';
    return toPrint;
  }
}
