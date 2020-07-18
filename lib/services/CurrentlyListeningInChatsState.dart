//import 'package:flutter/cupertino.dart';
//import 'package:voices/models/recording.dart';
//
//class CurrentlyListeningInChatState with ChangeNotifier {
//  Map<String, Recording> chatsWithActivePlayer = {};
//
//  playAudioInChat(String chatId, Recording recording) {
//    if (!chatsWithActivePlayer.containsKey(chatId)) {
//      chatsWithActivePlayer.addAll({chatId: recording});
//    } else {
//      chatsWithActivePlayer.update(chatId, (value) => recording);
//    }
//    print(chatsWithActivePlayer.toString());
//
//    notifyListeners();
//  }
//}
