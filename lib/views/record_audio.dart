import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/audio_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:path/path.dart' as p;

import 'dart:developer' as devtools show log;

import '../audio_player.dart';
import '../audio_recorder.dart';
import '../encode/firebase_provider.dart';

class RecorderView extends StatefulWidget {
  const RecorderView({Key? key}) : super(key: key);

  @override
  State<RecorderView> createState() => _RecorderView();
}

class _RecorderView extends State<RecorderView> {
  bool showPlayer = false;
  String? audioPath;
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final db = FirebaseFirestore.instance;
  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Audio"),
      ),
      body: Center(
        child: showPlayer
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: AudioPlayer(
                  source: audioPath!,
                  onDelete: () {
                    setState(() => showPlayer = false);
                    _processVideo(File(audioPath!));
                    Navigator.pop(context);
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
    );
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = File(filePath);
    final basename = p.basename(filePath);
    final ref = FirebaseStorage.instance
        .ref()
        .child(uid)
        .child(folderName)
        .child(basename);
    await ref.putFile(file);
    final videoUrl = await ref.getDownloadURL();
    return videoUrl;
  }

  Future<void> _processVideo(File rawAudioFile) async {
    devtools.log("PROCESSING Audio");
    final String rand = '${Random().nextInt(10000)}';
    final audioName = 'audio$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Audio/$audioName';
    final videosDir = Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawAudioFile.path;
    final audioUrl = await _uploadFile(rawVideoPath, audioName);

    final audioInfo = AudioInfo(
      audioUrl: audioUrl,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      audioName: audioName,
    );

    await FirebaseProvider.saveAudio(audioInfo, uid);
  }
}

class RecordList extends StatefulWidget {
  const RecordList({super.key});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  int currentPageIndex = 0;
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  List<AudioInfo> _videos = <AudioInfo>[];
  bool _processing = false;
  // bool _canceled = false;
  double _progress = 0.0;
  String _processPhase = '';
  // final bool _debugMode = false;
  final db = FirebaseFirestore.instance;

  _getListView() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _videos.length,
            itemBuilder: (BuildContext context, int index) {
              final video = _videos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          appBar: AppBar(
                            title: const Text("Player"),
                          ),
                          body: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: AudioPlayer(
                                source: video.audioUrl,
                                onDelete: () {},
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(Icons.music_note, size: 32),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(video.audioName),
                                    Container(
                                      margin: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                          'Uploaded ${timeago.format(DateTime.fromMillisecondsSinceEpoch(video.uploadedAt))}'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      future: FirebaseProvider.fillAudios(uid).then(
        (value) {
          _videos = value;
        },
      ),
    );
  }

  _getProgressBar() {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _processing ? _getProgressBar() : _getListView()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecorderView()),
          );
        },
        child: _processing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
