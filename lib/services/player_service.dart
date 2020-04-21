import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService {
  final player = AudioPlayer();

  initializePlayer({@required String filePath}) async {
    await player.setFilePath(filePath);
  }

  playAudio() async {
    await player.play();
  }

  pauseAudio() async {
    await player.pause();
  }

  stopAudio() async {
    await player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    await player.seek(position);
  }
}
