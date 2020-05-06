import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';

class PlayerServiceSingle with ChangeNotifier {
  //properties that the outside needs access to
  double currentSpeed = 1.0;
  Duration currentPosition = Duration(seconds: 0);
  PlayerStatus status = PlayerStatus.idle;
  AudioChunk audioChunk;

  //private variables
  final _player = AudioPlayer();
  StreamSubscription<Duration> _positionStreamSubscription;

  //audioChunks is the list of chunks that will be played in order
  initializePlayer({@required AudioChunk audioChunk}) async {
    this.audioChunk = audioChunk;
    currentPosition = Duration(seconds: 0);
    _positionStreamSubscription =
        _player.getPositionStream().listen((newPosition) {
      currentPosition = newPosition;
      notifyListeners();
    });
    await _player.setFilePath(audioChunk.path);
    notifyListeners();
  }

  //find the current chunk based on the current position and play from there
  play() async {
    status = PlayerStatus.playing;
    notifyListeners();
    _positionStreamSubscription.resume();
    await _player.play();
  }

  pause() {
    status = PlayerStatus.paused;
    notifyListeners();
    _positionStreamSubscription.pause();
    _player.pause();
  }

  stop() {
    status = PlayerStatus.idle;
    currentPosition = Duration(seconds: 0);
    notifyListeners();
    _player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    await _player.seek(position);
  }

  setSpeed({@required double speed}) async {
    currentSpeed = speed;
    notifyListeners();
    await _player.setSpeed(speed);
  }
}

enum PlayerStatus { playing, paused, idle }
