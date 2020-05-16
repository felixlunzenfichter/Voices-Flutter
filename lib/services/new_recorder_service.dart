import 'dart:async';
import 'package:voices/models/recording.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:intl/intl.dart' show DateFormat;

class NewRecorderService {
  FlutterSoundRecorder recorderModule;

  initialize() async {}
}

enum RecordingStatus { initialized, recording, paused, stopped }
