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
          Container(
            child: ListOfBars(
              height: 50,
            ),
            color: Colors.red,
          ),
          //RecordingAndPlayingInfo(),
          //RecorderControls(),
        ],
      ),
    );
  }
}
