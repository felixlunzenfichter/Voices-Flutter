import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class CloudPlayerService {
  Map<String, AudioPlayer> _playerDict = Map();

  initializePlayerWithUrl(
      {@required String url, @required String playerId}) async {
    AudioPlayer newPlayer = AudioPlayer();
    Future<Duration> futureDuration = newPlayer.setUrl(url);
    futureDuration.catchError((error) {
      print("Error occured when fetching audio from url: $error");
    });
    _playerDict.addEntries([MapEntry(playerId, newPlayer)]);
  }

  disposePlayer({@required String playerId}) async {
    await _playerDict[playerId].dispose();
    _playerDict.remove(playerId);
  }

  play({@required String playerId}) async {
    await _playerDict[playerId].play();
  }

  pause({@required String playerId}) async {
    await _playerDict[playerId].pause();
  }

  seek({@required Duration position, @required String playerId}) async {
    await _playerDict[playerId].seek(position);
  }

  setSpeed({@required double speed, @required String playerId}) async {
    await _playerDict[playerId].setSpeed(speed);
  }

  //get notified of changes
  Stream<FullAudioPlaybackState> getPlaybackStateStream(
      {@required String playerId}) {
    return _playerDict[playerId].fullPlaybackStateStream;
  }

  Stream<Duration> getPositionStream({@required String playerId}) {
    return _playerDict[playerId].getPositionStream();
  }

  //this doesn't seem to work if we upload the file without metadata
  Stream<Duration> getLengthOfAudioStream({@required String playerId}) {
    return _playerDict[playerId].durationStream;
  }
}
