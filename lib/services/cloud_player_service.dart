import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class CloudPlayerService {
  Map<String, AudioPlayer> _playerDict = Map();

  initializePlayerWithUrl(
      {@required String url, @required String playerId}) async {
    try {
      AudioPlayer newPlayer = AudioPlayer();
      Future<Duration> futureDuration = newPlayer.setUrl(url);
      futureDuration.catchError((error) {
        print("Error occured when fetching audio from url: $error");
      });
      _playerDict.addEntries([MapEntry(playerId, newPlayer)]);
    }catch(e){
      print("Cloud player service could not initialize player with playerId = $playerId from url = $url because of error =$e");
    }
  }

  disposePlayer({@required String playerId}) async {
    try{
    await _playerDict[playerId].dispose();
    _playerDict.remove(playerId);
    }catch(e){
      print("Cloud player service could not dispose player with playerId = $playerId because of error =$e");
    }
  }

  play({@required String playerId}) async {
    try {
      await _playerDict[playerId].play();
    }catch(e){
      print("Cloud player service could not play player with playerId = $playerId because of error =$e");
    }
  }

  pause({@required String playerId}) async {
    try{
    await _playerDict[playerId].pause();
    }catch(e){
      print("Cloud player service could not pause player with playerId = $playerId because of error =$e");
    }
  }

  seek({@required Duration position, @required String playerId}) async {
    try {
      await _playerDict[playerId].seek(position);
    }catch(e){
      print("Cloud player service could not seek player with playerId = $playerId to position = $position because of error =$e");
    }
  }

  setSpeed({@required double speed, @required String playerId}) async {
    try{
    await _playerDict[playerId].setSpeed(speed);
    }catch(e){
      print("Cloud player service could not set speed to speed = $speed for player with playerId = $playerId because of error =$e");
    }
  }

  //get notified of changes
  Stream<FullAudioPlaybackState> getPlaybackStateStream(
      {@required String playerId}) {
    try {
      return _playerDict[playerId].fullPlaybackStateStream;
    }catch(e){
      print("Cloud player service could not get playback Stream for player with playerId = $playerId because of error =$e");
      return Stream.error("Cloud player service could not get playback Stream for player with playerId = $playerId because of error =$e");
    }
  }

  Stream<Duration> getPositionStream({@required String playerId}) {
    try {
      return _playerDict[playerId].getPositionStream();
    }catch(e){
      print("Cloud player service could not get position Stream for player with playerId = $playerId because of error =$e");
      return Stream.error("Cloud player service could not get position Stream for player with playerId = $playerId because of error =$e");
    }
  }

  /// The duration stream from the player doesn't seem to work as is
  /// Maybe the file in the cloud must be uploaded with the right metadata or the problem disappears when using .mp3 as the audio file type
  Stream<Duration> getLengthOfAudioStream({@required String playerId}) {
    try{
    return _playerDict[playerId].durationStream;
    }catch(e){
      print("Cloud player service could not get length of audio stream for player with playerId = $playerId because of error =$e");
      return Stream.error("Cloud player service could not get length of audio stream for player with playerId = $playerId because of error =$e");
    }
  }
}
