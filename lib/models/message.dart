class Message {
  String senderUid;
  String text;
  DateTime timestamp;

  Message({
    this.senderUid,
    this.text,
    this.timestamp,
  });

  // TODO: Wieso brauchen wir diesen constructor?
  Message.fromMap({Map<String, dynamic> map}) {
    this.senderUid = map['senderUid'];
    this.text = map['text'];
    this.timestamp = map['timestamp']?.toDate() ?? DateTime.now();
  }

  // TODO: Warum ist hier nicht der timestamp?
  toMap() {
    return {
      'text': text,
      'senderUid': senderUid,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ text: $text, ';
    toPrint += 'senderUid: $senderUid, ';
    toPrint += 'timestamp: ${timestamp.toString()} }\n';
    return toPrint;
  }
}
