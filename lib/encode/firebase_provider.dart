import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_info.dart';

class FirebaseProvider {
  static saveVideo(VideoInfo video) async {
    await FirebaseFirestore.instance.collection('videos').doc().set({
      'videoUrl': video.videoUrl,
      'thumbUrl': video.thumbUrl,
      'coverUrl': video.coverUrl,
      'aspectRatio': video.aspectRatio,
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    });
  }

  // static listenToVideos(callback) async {
  //   final ref =
  //       FirebaseFirestore.instance.collection("videos").doc().withConverter(
  //             fromFirestore: VideoInfo.fromFirestore,
  //             toFirestore: (VideoInfo city, _) => city.toFirestore(),
  //           );
  //   final docSnap = await ref.get();
  //   final videos = docSnap.data();
  //   devtools.log(videos.toString());
  //   callback(videos);
  // }

  static Future<List<VideoInfo>> fillVideos() async {
    List<VideoInfo> videos = <VideoInfo>[];

    final data = await FirebaseFirestore.instance.collection("videos").get();
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

  static listenToVideos(callback) async {
    List videos = <VideoInfo>[];
    FirebaseFirestore.instance.collection("videos").snapshots().listen((event) {
      for (var doc in event.docs) {
        final data = doc.data();
        videos.add(VideoInfo(
          videoUrl: data['videoUrl'],
          thumbUrl: data['thumbUrl'],
          coverUrl: data['coverUrl'],
          aspectRatio: data['aspectRatio'],
          videoName: data['videoName'],
          uploadedAt: data['uploadedAt'],
        ));
      }
    });
    callback(videos);
  }

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
