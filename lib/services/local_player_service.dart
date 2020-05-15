import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/recording.dart';

class LocalPlayerService {
  //private variables
  final _player = AudioPlayer();

  //pass in audioChunk to be played
  initializePlayer({@required Recording recording}) async {
    await _player.setFilePath(recording.path);
  }

  disposePlayer() {
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
  Stream<FullAudioPlaybackState> getPlaybackStateStream() {
    return _player.fullPlaybackStateStream;
  }

  Stream<Duration> getPositionStream() {
    return _player.getPositionStream();
  }

  //this doesn't seem to work if we upload the file without metadata
  Stream<Duration> getLengthOfAudioStream() {
    return _player.durationStream;
  }
}
