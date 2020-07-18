import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/recording.dart';
import 'dart:io';

class LocalPlayerService with ChangeNotifier {
  /// Private properties
  final _player = AudioPlayer();

  double _currentSpeed = 1;

  PlayerStatus localPlayerStatus;

  Duration duration = Duration(seconds: 69);

  void listenToState() async {
    Stream playerStatusStream = _getPlaybackStateStream();
    playerStatusStream.listen((event) {
      localPlayerStatus = event;
      print('playerStatus changed to: $localPlayerStatus');
      notifyListeners();
    });
  }

  void listenToLength() async {
    Stream audioLengthStream = _getLengthOfAudioStream();
    audioLengthStream.listen((event) {
      duration = event;
      print('Length of audio: $event');
      notifyListeners();
    });
  }

  LocalPlayerService() {
    listenToState();
    listenToLength();
  }

  initialize({@required File audioFile}) async {
    try {
      await _player.setFilePath(audioFile.path);
      print('Player initialized to: ${audioFile.path}');
      print(localPlayerStatus);
    } catch (e) {
      print(
          "Local audio player could not be initialized because of error = $e");
    }
  }

  dispose() {
    try {
      _player.dispose();
    } catch (e) {
      print("Local audio player could not be disposed because of error = $e");
    }
  }

  Future<void> play() async {
    print(_currentSpeed);
    try {
      if (Platform.isIOS) {
        /// On iOS [_player.setSpeed] is the only way to play a stopped audio in the right speed
        if (_currentSpeed == 1) {
          await _player.play();
        } else {
          await _player.setSpeed(_currentSpeed);
        }
      } else {
        await _player.play();
      }
      print("play is executed from local player");
    } catch (e) {
      print("Local audio player could not start playing because of error = $e");
    }
  }

  pause() async {
    try {
      await _player.pause();
    } catch (e) {
      print("Local audio player could not pause because of error = $e");
    }
  }

  stop() async {
    try {
      print('stopped');
      await _player.stop();
    } catch (e) {
      print("Local audio player could not stop because of error = $e");
    }
  }

  seek({@required Duration position}) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print(
          "Local audio player could not seek to position = $position because of error = $e");
    }
  }

  /// On iOS [_player.setspeed()] starts playing the audio so it needs to be paused immediately after, if it wasn't playing before
  setSpeed({@required double speed}) async {
    try {
      bool shouldPauseAfterSpeedSet =
          _player.playbackState != AudioPlaybackState.playing && Platform.isIOS;
      await _player.setSpeed(speed);
      _currentSpeed = speed;
      if (shouldPauseAfterSpeedSet) {
        _player.pause();
      }
    } catch (e) {
      print(
          "Local audio player could not set speed to $speed because of error = $e");
    }
  }

  Stream<PlayerStatus> _getPlaybackStateStream() {
    try {
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
    } catch (e) {
      print(
          "Local audio player could not get playback state stream because of error = $e");
      return Stream.value(PlayerStatus.uninitialized);
    }
  }

  Stream<Duration> getPositionStream() {
    try {
      return _player.getPositionStream();
    } catch (e) {
      print(
          "Local audio player could not get position stream because of error = $e");
      return Stream.error(
          "Local audio player could not get position stream because of error = $e");
    }
  }

  Stream<Duration> _getLengthOfAudioStream() {
    try {
      return _player.durationStream;
    } catch (e) {
      print(
          "Local audio player could not get length of audio stream because of error = $e");
      return Stream.error(
          "Local audio player could not get length of audio stream because of error = $e");
    }
  }
}

enum PlayerStatus { uninitialized, idle, playing, paused, completed }
