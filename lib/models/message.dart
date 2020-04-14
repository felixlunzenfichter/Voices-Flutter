class Message {
  String senderUid;
  String text;
  DateTime timestamp;

  Message({
    this.senderUid,
    this.text,
    this.timestamp,
  });

  Message.fromMap({Map<String, dynamic> map}) {
    this.senderUid = map['senderUid'];
    this.text = map['text'];
    this.timestamp = map['timestamp'].toDate();
  }

  toMap() {
    return {
      'text': text,
      'senderUid': senderUid,
    };
  }
}
