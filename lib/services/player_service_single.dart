import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';

class PlayerServiceSingle with ChangeNotifier {
  //properties that the outside needs access to
  double currentSpeed = 1.0;
  Duration currentPosition = Duration(seconds: 0);
  PlayerStatus currentStatus = PlayerStatus.idle;
  AudioChunk audioChunk;

  //private variables
  final _player = AudioPlayer();
  StreamSubscription<Duration> _positionStreamSubscription;
  StreamSubscription<AudioPlaybackState> _statusStreamSubscription;

  //audioChunks is the list of chunks that will be played in order
  initializePlayer({@required AudioChunk audioChunk}) async {
    this.audioChunk = audioChunk;
    currentPosition = Duration(seconds: 0);
    _positionStreamSubscription =
        _player.getPositionStream().listen((newPosition) {
      currentPosition = newPosition;
      notifyListeners();
    });
    _statusStreamSubscription = _player.playbackStateStream.listen((newState) {
      switch (newState) {
        case AudioPlaybackState.completed:
          currentStatus = PlayerStatus.idle;
          break;
        case AudioPlaybackState.paused:
          currentStatus = PlayerStatus.paused;
          break;
        case AudioPlaybackState.playing:
          currentStatus = PlayerStatus.playing;
          break;
        default:
          currentStatus = PlayerStatus.idle;
          break;
      }
      notifyListeners();
    });
    await _player.setFilePath(audioChunk.path);
    notifyListeners();
  }

  disposePlayer() {
    _positionStreamSubscription.cancel();
    _statusStreamSubscription.cancel();
    _player.dispose();
  }

  //find the current chunk based on the current position and play from there
  play() {
    _player.play();
  }

  pause() {
    _player.pause();
  }

  stop() {
    _player.stop();
  }

  jumpToPosition({@required Duration position}) {
    _player.seek(position);
  }

  setSpeed({@required double speed}) {
    currentSpeed = speed;
    notifyListeners();
    _player.setSpeed(speed);
  }
}

enum PlayerStatus { playing, paused, idle }
