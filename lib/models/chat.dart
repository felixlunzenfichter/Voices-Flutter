import 'user.dart';

class Chat {
  String chatId;
  List<User> users;
  String lastMessageText;
  var lastMessageTimestamp;

  Chat(
      {this.chatId,
      this.users,
      this.lastMessageText,
      this.lastMessageTimestamp});

  Chat.fromMap({Map<String, dynamic> map}) {
    this.chatId = map['chatId'];
    this.users = map['users'];
    this.lastMessageText = map['lastMessageText'];
    this.lastMessageTimestamp = map['lastMessageTimestamp']?.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'users': users,
      'lastMessageText': lastMessageText,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }

  @override
  String toString() {
    String toPrint = '\n{ chatId: $chatId, ';
    toPrint += 'users: $users, ';
    toPrint += 'lastMessageText: $lastMessageText, ';
    toPrint += 'lastMessageTimestamp: ${lastMessageTimestamp.toString()} }\n';
    return toPrint;
  }
}
