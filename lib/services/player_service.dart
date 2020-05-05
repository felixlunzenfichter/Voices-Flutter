import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService with ChangeNotifier {
  List<String> audioChunkPaths = [];
  Duration currentPosition;
  Duration totalLengthOfAllChunks;
  double currentSpeed = 1.0;
  PlayerStatus status = PlayerStatus.idle;
  final _player = AudioPlayer();

  initializePlayer({@required List<String> audioChunks}) {
    currentPosition = Duration(seconds: 0);
    audioChunkPaths = audioChunks;
    status = PlayerStatus.idle;
    //todo update totalLength
    notifyListeners();
  }

  appendChunk({@required String audioChunk}) {
    audioChunkPaths.add(audioChunk);
    //todo update totalLength
  }

  //find the current chunk based on the current position and play from there
  play() async {
    status = PlayerStatus.playing;
    notifyListeners();
    //todo find out in which chunk the current position is located and play from there
    int foundChunk = 2;
    for (int i = foundChunk; i < audioChunkPaths.length; i++) {
      if (status == PlayerStatus.idle || status == PlayerStatus.paused) {
        //if the player is paused or stopped we don't want to play the remaining chunks
        return;
      }
      String path = audioChunkPaths[i];
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
    notifyListeners();
    await _player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    status = PlayerStatus
        .paused; //set the status to paused because we need to prevent the for loop in the play function to keep going
    //todo find the current chunk where the position is located and start playing from there
    String foundChunk = "";
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
