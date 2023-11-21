import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/audio_info.dart';
import '../models/video_info.dart';

class FirebaseProvider {
  static saveVideo(VideoInfo video, String uid) async {
    await FirebaseFirestore.instance
        .collection('videos')
        .doc('users')
        .collection(uid)
        .doc()
        .set({
      'videoUrl': video.videoUrl,
      'thumbUrl': video.thumbUrl,
      'coverUrl': video.coverUrl,
      'aspectRatio': video.aspectRatio,
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    });
  }

  static saveAudio(AudioInfo audioInfo, String uid) async {
    await FirebaseFirestore.instance
        .collection('audios')
        .doc('users')
        .collection(uid)
        .doc()
        .set({
      'audioUrl': audioInfo.audioUrl,
      'uploadedAt': audioInfo.uploadedAt,
      'audioName': audioInfo.audioName,
    });
  }

  static Future<List<VideoInfo>> fillVideos(String uid) async {
    List<VideoInfo> videos = <VideoInfo>[];

    final data = await FirebaseFirestore.instance
        .collection("videos")
        .doc('users')
        .collection(uid)
        .get();
    for (var docSnapshot in data.docs) {
      print('${docSnapshot.id} => ${docSnapshot.data()}');
      final data = docSnapshot.data();
      videos.add(VideoInfo(
        videoUrl: data['videoUrl'],
        thumbUrl: data['thumbUrl'],
        coverUrl: data['coverUrl'],
        aspectRatio: data['aspectRatio'],
        videoName: data['videoName'],
        uploadedAt: data['uploadedAt'],
      ));
    }
    return videos;
  }

  static Future<List<AudioInfo>> fillAudios(String uid) async {
    List<AudioInfo> audios = <AudioInfo>[];

    final data = await FirebaseFirestore.instance
        .collection("audios")
        .doc('users')
        .collection(uid)
        .get();
    for (var docSnapshot in data.docs) {
      print('${docSnapshot.id} => ${docSnapshot.data()}');
      final data = docSnapshot.data();
      audios.add(AudioInfo(
        audioUrl: data['audioUrl'],
        audioName: data['audioName'],
        uploadedAt: data['uploadedAt'],
      ));
    }
    return audios;
  }

  // static listenToVideos(callback) async {
  //   List videos = <VideoInfo>[];
  //   FirebaseFirestore.instance.collection("videos").snapshots().listen((event) {
  //     for (var doc in event.docs) {
  //       final data = doc.data();
  //       videos.add(VideoInfo(
  //         videoUrl: data['videoUrl'],
  //         thumbUrl: data['thumbUrl'],
  //         coverUrl: data['coverUrl'],
  //         aspectRatio: data['aspectRatio'],
  //         videoName: data['videoName'],
  //         uploadedAt: data['uploadedAt'],
  //       ));
  //     }
  //   });
  //   callback(videos);
  // }

  // static mapQueryToVideoInfo(QuerySnapshot qs) {
  //   return qs.docs.map((DocumentSnapshot ds) {
  //     return VideoInfo(
  //       videoUrl: ds.data['videoUrl'],
  //       thumbUrl: ds.data['thumbUrl'],
  //       coverUrl: ds.data['coverUrl'],
  //       aspectRatio: ds.data['aspectRatio'],
  //       videoName: ds.data['videoName'],
  //       uploadedAt: ds.data['uploadedAt'],
  //     );
  //   }).toList();
  // }
}
