import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voices/models/audio_chunk.dart';
import 'recorder_service.dart';

class PlayerService with ChangeNotifier {
  //properties that the outside needs access to
  Duration totalLengthOfAllChunks;
  double currentSpeed = 1.0;
  PlayerStatus status = PlayerStatus.idle;

  //private variables
  final _player = AudioPlayer();
  List<AudioChunk> _audioChunks = [];
  int _currentChunkIndex = 0;
  Duration get _lengthOfChunksBeforeCurrent {
    Duration result = Duration(seconds: 0);
    for (int i = 0; i < _currentChunkIndex; i++) {
      result += _audioChunks[i].length;
    }
    return result;
  }

  //audioChunks is the list of chunks that will be played in order
  initializePlayer({@required List<AudioChunk> audioChunks}) {
    _currentChunkIndex = 0;
    _audioChunks = audioChunks;
    status = PlayerStatus.idle;
    totalLengthOfAllChunks = Duration(seconds: 0);
    for (var chunk in audioChunks) {
      totalLengthOfAllChunks += chunk.length;
    }
    notifyListeners();
  }

  //add a chunk to be played after the chunks that have already been added
  appendChunk({@required AudioChunk audioChunk}) {
    _audioChunks.add(audioChunk);
    totalLengthOfAllChunks += audioChunk.length;
  }

  //find the current chunk based on the current position and play from there
  play() async {
    status = PlayerStatus.playing;
    notifyListeners();
    for (int i = _currentChunkIndex; i < _audioChunks.length; i++) {
      if (status == PlayerStatus.idle || status == PlayerStatus.paused) {
        //if the player is paused or stopped we don't want to play the remaining chunks
        return;
      }
      _currentChunkIndex = i;
      String path = _audioChunks[i].path;
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
    _currentChunkIndex = 0;
    notifyListeners();
    await _player.stop();
  }

  jumpToPosition({@required Duration position}) async {
    status = PlayerStatus
        .paused; //set the status to paused because we need to prevent the for loop in the play function to keep going
    if (_audioChunks.length == 1) {
      //there is only one chunk which might be longer than the default chunk size
      await _player.seek(position);
      play();
    } else {
      //the chunks in the list are all the default chunk size
      //find the current chunk where the position is located and start playing from there
      _currentChunkIndex = position.inMilliseconds ~/
          RecorderService.DEFAULT_CHUNK_SIZE.inMilliseconds;
      _player.setFilePath(_audioChunks[_currentChunkIndex].path);
      Duration positionRelativeToChunkStart = Duration(
          milliseconds: position.inMilliseconds %
              RecorderService.DEFAULT_CHUNK_SIZE.inMilliseconds);
      await _player.seek(positionRelativeToChunkStart);
      play();
    }
  }

  setSpeed({@required double speed}) async {
    currentSpeed = speed;
    notifyListeners();
    await _player.setSpeed(speed);
  }

  Stream<Duration> getPositionStream() async* {
    Stream<Duration> relativePositionStream = _player.getPositionStream();
    await for (Duration relativePosition in relativePositionStream) {
      yield _lengthOfChunksBeforeCurrent + relativePosition;
    }
  }
}

enum PlayerStatus { playing, paused, idle }
