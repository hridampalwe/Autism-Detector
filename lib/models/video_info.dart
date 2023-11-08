import 'package:cloud_firestore/cloud_firestore.dart';

class VideoInfo {
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;

  VideoInfo({
    this.videoUrl = "",
    this.thumbUrl = "",
    this.coverUrl = "",
    this.aspectRatio = 0,
    this.uploadedAt = 0,
    this.videoName = "",
  });
  factory VideoInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return VideoInfo(
      videoUrl: data?['videoUrl'],
      thumbUrl: data?['thumbUrl'],
      coverUrl: data?['coverUrl'],
      aspectRatio: data?['aspectRatio'],
      uploadedAt: data?['uploadedAt'],
      videoName: data?['videoName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "videoUrl": videoUrl,
      "thumbUrl": thumbUrl,
      "coverUrl": coverUrl,
      "aspectRatio": aspectRatio,
      "uploadedAt": uploadedAt,
      "videoName": videoName,
    };
  }
}
