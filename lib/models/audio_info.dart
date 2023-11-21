import 'package:cloud_firestore/cloud_firestore.dart';

class AudioInfo {
  String audioUrl;
  int uploadedAt;
  String audioName;

  AudioInfo({
    this.audioUrl = "",
    this.uploadedAt = 0,
    this.audioName = "",
  });
  factory AudioInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AudioInfo(
      audioUrl: data?['audioUrl'],
      uploadedAt: data?['uploadedAt'],
      audioName: data?['audioName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "audioUrl": audioUrl,
      "uploadedAt": uploadedAt,
      "audioName": audioName,
    };
  }
}
