import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';

class PlayerServiceSingle with ChangeNotifier {
  //properties that the outside needs access to
  double currentSpeed = 1.0;
  PlayerStatus status = PlayerStatus.idle;

  //private variables
  final _player = AudioPlayer();

  //audioChunks is the list of chunks that will be played in order
  initializePlayer({@required AudioChunk audioChunk}) async {
    await _player.setFilePath(audioChunk.path);
    notifyListeners();
  }

  //find the current chunk based on the current position and play from there
  play() async {
    status = PlayerStatus.playing;
    notifyListeners();
    await _player.play();
  }

  pause() async {
    status = PlayerStatus.paused;
    notifyListeners();
    await _player.pause();
  }

  stop() async {
    status = PlayerStatus.idle;
    notifyListeners();
    await _player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    await _player.seek(position);
  }

  setSpeed({@required double speed}) async {
    currentSpeed = speed;
    notifyListeners();
    await _player.setSpeed(speed);
  }

  Stream<Duration> getPositionStream() {
    return _player.getPositionStream();
  }
}

enum PlayerStatus { playing, paused, idle }
