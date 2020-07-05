import 'package:flutter/cupertino.dart';
import 'package:voices/models/recording.dart';

class CurrentlyListeningInChatState with ChangeNotifier {
  Map<String, Recording> ChatsWithActivePlayer = {};

  playAudioInChat(String chatId, Recording recording) {
    if (!ChatsWithActivePlayer.containsKey(chatId)) {
      ChatsWithActivePlayer.addAll({chatId: recording});
    } else {
      ChatsWithActivePlayer.update(chatId, (value) => recording);
    }
    print(ChatsWithActivePlayer.toString());
    notifyListeners();
  }
}
