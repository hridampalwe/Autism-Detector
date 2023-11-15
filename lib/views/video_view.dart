import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/encode/encode.dart';
import 'package:flutter_application_1/widgets/appbar.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../encode/firebase_provider.dart';
import '../models/video_info.dart';
import 'package:path/path.dart' as p;
import 'package:timeago/timeago.dart' as timeago;

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoView();
}

class _VideoView extends State<VideoView> {
  int currentPageIndex = 0;
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final thumbWidth = 100;
  final thumbHeight = 150;
  List<VideoInfo> _videos = <VideoInfo>[];
  bool _imagePickerActive = false;
  bool _processing = false;
  // bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;
  final db = FirebaseFirestore.instance;

  void statisticsCallback(Statistics statistics) {
    setState(() {
      _progress = statistics.time / _videoDuration;
    });
  }

  @override
  void initState() {
    // FirebaseProvider.listenToVideos((newVideos) {
    //   setState(() {
    //     _videos = newVideos;
    //   });
    // });
    EncodingProvider.config.enableStatisticsCallback(statisticsCallback);
    super.initState();
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

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = <String>[];

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') {
        _updatePlaylistUrls((file as File), videoName);
      }
      setState(() {
        _processPhase = 'Uploading video file $i out of ${files.length}';
        _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<void> _processVideo(File rawVideoFile) async {
    devtools.log("PROCESSING VIDEOOOOOO");
    final String rand = '${Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio = EncodingProvider.getAspectRatio(info);

    setState(() {
      devtools.log("insideState");
      _processPhase = 'Generating thumbnail';
      final int blah = double.parse(info['streams'][0]['duration']).round();
      _videoDuration = blah;
      _progress = 0.0;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);
    devtools.log(thumbFilePath.toString());
    setState(() {
      _processPhase = 'Encoding video';
      _progress = 0.0;
    });

    // final encodedFilesDir =
    // await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to firebase storage';
      _progress = 0.0;
    });
    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    // final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);
    final videoUrl = await _uploadFile(rawVideoPath, videoName);

    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud firestore';
      _progress = 0.0;
    });

    await FirebaseProvider.saveVideo(videoInfo, uid);

    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });
  }

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
                        return const Text("done");
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
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: thumbWidth.toDouble(),
                                  height: thumbHeight.toDouble(),
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: video.thumbUrl,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(video.videoName),
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
      future: FirebaseProvider.fillVideos(uid).then(
        (value) {
          _videos = value;
        },
      ),
    );
  }

  void _takeVideo() async {
    final ImagePicker picker = ImagePicker();
    var videoFile;
    if (_debugMode) {
      videoFile = File(
          '/storage/emulated/0/Android/data/com.learningsomethingnew.fluttervideo.flutter_video_sharing/files/Pictures/ebbafabc-dcbe-433b-93dd-80e7777ee4704451355941378265171.mp4');
    } else {
      if (_imagePickerActive) return;

      _imagePickerActive = true;
      videoFile = await picker.pickVideo(source: ImageSource.camera);
      _imagePickerActive = false;

      if (videoFile == null) return;
    }
    setState(() {
      _processing = true;
    });
    File file = File(videoFile.path);

    try {
      await _processVideo(file);
    } catch (e) {
      devtools.log(e.toString());
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Center(child: _processing ? _getProgressBar() : _getListView()),
        floatingActionButton: FloatingActionButton(
          onPressed: _takeVideo,
          child: _processing
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Icon(Icons.add),
        ));
  }
}
