import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';

class PlayerService with ChangeNotifier {
  List<AudioChunk> audioChunks = [];
  Duration currentPosition;
  Duration totalLengthOfAllChunks;
  double currentSpeed = 1.0;
  PlayerStatus status = PlayerStatus.idle;
  final _player = AudioPlayer();
  int _currentChunkIndex = 0;
  Duration get _lengthOfChunksBeforeCurrent {
    Duration result = Duration(seconds: 0);
    for (int i = 0; i < _currentChunkIndex; i++) {
      result += audioChunks[i].length;
    }
    return result;
  }

  initializePlayer({@required List<AudioChunk> audioChunks}) {
    currentPosition = Duration(seconds: 0);
    _currentChunkIndex = 0;
    audioChunks = audioChunks;
    status = PlayerStatus.idle;
    //todo update totalLength
    notifyListeners();
  }

  appendChunk({@required AudioChunk audioChunk}) {
    audioChunks.add(audioChunk);
    //todo update totalLength
  }

  //find the current chunk based on the current position and play from there
  play() async {
    status = PlayerStatus.playing;
    notifyListeners();
    for (int i = _currentChunkIndex; i < audioChunks.length; i++) {
      if (status == PlayerStatus.idle || status == PlayerStatus.paused) {
        //if the player is paused or stopped we don't want to play the remaining chunks
        return;
      }
      _currentChunkIndex = i;
      String path = audioChunks[i].path;
      assert(path != null);
      await _player.setFilePath(path);
      await _player.play();
    }
  }

  pause() async {
    status = PlayerStatus.paused;
    notifyListeners();
    await _player.pause();
  }

  stop() async {
    status = PlayerStatus.idle;
    currentPosition = Duration(days: 0);
    _currentChunkIndex = 0;
    notifyListeners();
    await _player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    status = PlayerStatus
        .paused; //set the status to paused because we need to prevent the for loop in the play function to keep going
    //todo find the current chunk where the position is located and start playing from there
    String foundChunk = "";
    _currentChunkIndex = 2;
    _player.setFilePath(foundChunk);
    Duration positionRelativeToChunkStart = position - Duration(days: 10);
    await _player.seek(positionRelativeToChunkStart);
    await play();
  }

  setSpeed({@required double speed}) async {
    currentSpeed = speed;
    notifyListeners();
    await _player.setSpeed(speed);
  }
}

enum PlayerStatus { playing, paused, idle }
