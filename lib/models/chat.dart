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
    this.users = _convertFirebaseList(firebaseUsersList: map['users']);
    this.lastMessageText = map['lastMessageText'];
    this.lastMessageTimestamp = map['lastMessageTimestamp']?.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'users': users?.map((User u) => u.toMap())?.toList(),
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

  List<User> _convertFirebaseList({List<dynamic> firebaseUsersList}) {
    List<User> users = firebaseUsersList.map((d) => User.fromMap(map: d));
    return users;
  }
}
