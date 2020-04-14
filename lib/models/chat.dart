class Chat {
  String chatId;
  List<String> uidsOfMembers;
  String lastMessageText;
  DateTime lastMessageTimestamp;

  Chat(
      {this.chatId,
      this.uidsOfMembers,
      this.lastMessageText,
      this.lastMessageTimestamp});

  Chat.fromMap({Map<String, dynamic> map}) {
    this.chatId = map['chatId'];
    this.uidsOfMembers =
        _convertFirebaseListToDartList(list: map['uidsOfMembers']);
    this.lastMessageText = map['lastMessageText'];
    this.lastMessageTimestamp = map['lastMessageTimestamp'].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'uidsOfMembers': uidsOfMembers,
      'lastMessageText': lastMessageText,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ chatId: $chatId, ';
    toPrint += 'uidsOfMembers: $uidsOfMembers, ';
    toPrint += 'lastMessageText: $lastMessageText, ';
    toPrint += 'lastMessageTimestamp: ${lastMessageTimestamp.toString()} }\n';
    return toPrint;
  }

  List<String> _convertFirebaseListToDartList({List<dynamic> list}) {
    List<String> dartList = list.map((d) => d.toString()).toList();
    return dartList;
  }
}
