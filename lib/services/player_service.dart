import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService {
  playAudio({@required String audiofilePath}) async {
    final player = AudioPlayer();
    var duration = await player.setFilePath(audiofilePath);
  }
}
