import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../audio_player.dart';
import '../audio_recorder.dart';

class RecorderView extends StatefulWidget {
  const RecorderView({Key? key}) : super(key: key);

  @override
  State<RecorderView> createState() => _RecorderView();
}

class _RecorderView extends State<RecorderView> {
  bool showPlayer = false;
  String? audioPath;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: showPlayer
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AudioPlayer(
                    source: audioPath!,
                    onDelete: () {
                      setState(() => showPlayer = false);
                    },
                  ),
                )
              : Recorder(
                  onStop: (path) {
                    if (kDebugMode) print('Recorded file path: $path');
                    setState(() {
                      audioPath = path;
                      showPlayer = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
}
