import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';

class PlayerService with ChangeNotifier {
  //properties that the outside needs access to
  double currentSpeed = 1.0;
  Duration currentPosition = Duration(seconds: 0);
  PlayerStatus currentStatus = PlayerStatus.idle;
  AudioChunk audioChunk;

  //private variables
  final _player = AudioPlayer();
  StreamSubscription<Duration> _positionStreamSubscription;
  StreamSubscription<AudioPlaybackState> _statusStreamSubscription;
  //if we change the speed of the player it starts playing shortly and we want to ignore that.
  bool _shouldIgnorePlaying = false;

  //audioChunks is the list of chunks that will be played in order
  initializePlayer({@required AudioChunk audioChunk}) async {
    this.audioChunk = audioChunk;
    _positionStreamSubscription =
        _player.getPositionStream().listen((newPosition) {
      currentPosition = newPosition;
      notifyListeners();
    });
    _statusStreamSubscription = _player.playbackStateStream.listen((newState) {
      switch (newState) {
        case AudioPlaybackState.paused:
          currentStatus = PlayerStatus.paused;
          break;
        case AudioPlaybackState.playing:
          if (!_shouldIgnorePlaying) {
            currentStatus = PlayerStatus.playing;
          }
          break;
        default:
          currentStatus = PlayerStatus.idle;
          break;
      }
      notifyListeners();
    });
    await _player.setFilePath(audioChunk.path);
  }

  disposePlayer() {
    _positionStreamSubscription.cancel();
    _statusStreamSubscription.cancel();
    _player.dispose();
  }

  play() {
    if (currentSpeed == 1) {
      _player.play();
    } else {
      //_player.setSpeed automatically plays the audio
      _player.setSpeed(currentSpeed);
    }
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

  setSpeed({@required double speed}) async {
    currentSpeed = speed;
    notifyListeners();
    if (currentStatus == PlayerStatus.paused) {
      //if the player is paused changing the speed will make it play so we need to pause it again
      _shouldIgnorePlaying = true;
      await _player.setSpeed(speed);
      _player.pause();
    } else if (currentStatus == PlayerStatus.idle) {
      //if the player is stopped changing the speed will make it play so we need to stop it again
      _shouldIgnorePlaying = true;
      await _player.setSpeed(speed);
      _player.stop();
    } else {
      await _player.setSpeed(speed);
    }
    _shouldIgnorePlaying = false;
  }
}

enum PlayerStatus { playing, paused, idle }
