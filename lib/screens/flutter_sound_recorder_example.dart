import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices/screens/chat_screen/widgets.dart';

class FlutterSoundRecorderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sound'),
      ),
      body: ListView(
        children: <Widget>[
          RecordingAndPlayingInfo(),
          RecorderControls(),
        ],
      ),
    );
  }
}
//
//class DurationCounter extends StatefulWidget {
//  @override
//  _DurationCounterState createState() => _DurationCounterState();
//}
//
//class _DurationCounterState extends State<DurationCounter> {
//  Stream<Duration> positionStream;
//
//  @override
//  void initState() {
//    final newRecorderService =
//        Provider.of<NewRecorderService>(context, listen: false);
//    positionStream = newRecorderService.getPositionStream();
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      children: <Widget>[
//        StreamBuilder(
//          stream: positionStream,
//          builder: (context, snapshot) {
//            Duration position = snapshot.data;
//            return Text(
//              position?.toString() ?? '0s',
//              style: TextStyle(
//                fontSize: 35.0,
//                color: Colors.black,
//              ),
//            );
//          },
//        ),
//      ],
//    );
//  }
//}
//
//class DBLevelDisplay extends StatefulWidget {
//  @override
//  _DBLevelDisplayState createState() => _DBLevelDisplayState();
//}
//
//class _DBLevelDisplayState extends State<DBLevelDisplay> {
//  Stream<double> dbLevelStream;
//
//  @override
//  void initState() {
//    final newRecorderService =
//        Provider.of<NewRecorderService>(context, listen: false);
//    dbLevelStream = newRecorderService.getDbLevelStream();
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return StreamBuilder(
//      stream: dbLevelStream,
//      builder: (context, snapshot) {
//        double dbLevel = snapshot.data;
//        return LinearProgressIndicator(
//            value: 100.0 / 160.0 * (dbLevel ?? 1) / 100,
//            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//            backgroundColor: Colors.red);
//      },
//    );
//  }
//}
