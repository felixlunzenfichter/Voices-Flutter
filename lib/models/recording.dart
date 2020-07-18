import 'package:flutter/foundation.dart';

class Recording {
  String path;
  Duration duration;

  Recording({
    @required this.path,
    @required this.duration,
  });

  @override
  String toString() {
    String toPrint = '\n{ path: $path, ';
    toPrint += 'duration: $duration }\n';
    return toPrint;
  }
}
