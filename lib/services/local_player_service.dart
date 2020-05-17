import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/recording.dart';

class LocalPlayerService {
  //private variables
  final _player = AudioPlayer();

  //pass in audioChunk to be played
  initialize({@required Recording recording}) async {
    await _player.setFilePath(recording.path);
  }

  dispose() {
    _player.dispose();
  }

  //current speed has to be passed because if it is not equal to 1 we have to call setSpeed
  play({@required double currentSpeed}) async {
    if (currentSpeed == 1) {
      await _player.play();
    } else {
      //_player.setSpeed is the only way to play a stopped audio in the right speed
      await _player.setSpeed(currentSpeed);
    }
  }

  pause() async {
    await _player.pause();
  }

  stop() async {
    await _player.stop();
  }

  seek({@required Duration position}) async {
    await _player.seek(position);
  }

  ///since setspeed starts playing the audio we need to pause it immediately after
  ///changing the speed if it was paused. So we need to know if we should pause afterwards
  setSpeed(
      {@required double speed,
      @required bool shouldBePlayingAfterSpeedIsSet}) async {
    await _player.setSpeed(speed);
    if (!shouldBePlayingAfterSpeedIsSet) {
      _player.pause();
    }
  }

  //get notified of changes
  Stream<PlayerStatus> getPlaybackStateStream() {
    return _player.playbackStateStream.map((audioPlaybackState) {
      switch (audioPlaybackState) {
        case AudioPlaybackState.none:
          return PlayerStatus.uninitialized;
        case AudioPlaybackState.connecting:
          return PlayerStatus.uninitialized;
        case AudioPlaybackState.playing:
          return PlayerStatus.playing;
        case AudioPlaybackState.stopped:
          return PlayerStatus.idle;
        case AudioPlaybackState.paused:
          return PlayerStatus.paused;
        case AudioPlaybackState.completed:
          return PlayerStatus.idle;
        default:
          return PlayerStatus.uninitialized;
      }
    });
  }

  Stream<Duration> getPositionStream() {
    return _player.getPositionStream();
  }

  Stream<Duration> getLengthOfAudioStream() {
    return _player.durationStream;
  }
}

enum PlayerStatus { uninitialized, idle, playing, paused, completed }
