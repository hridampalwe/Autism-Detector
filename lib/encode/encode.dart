import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:developer' as devtools show log;

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig config = FlutterFFmpegConfig();

  static Future<String> getThumb(videoPath, width, height) async {
    devtools.log("AT GET THUMB");
    assert(File(videoPath).existsSync());

    final String outPath = '$videoPath.jpg';
    final arguments =
        '-y -i $videoPath -vframes 1 -an -s ${width}x$height -ss 1 $outPath';

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);
    assert(File(outPath).existsSync());

    return outPath;
  }

  static Future<Map<dynamic, dynamic>> getMediaInformation(String path) async {
    devtools.log("AT getMediaInfo");
    final po = await _probe.getMediaInformation(path);
    return po.getAllProperties();
  }

  static double getAspectRatio(Map<dynamic, dynamic> info) {
    devtools.log("At GetAspectRatio");
    final int width = info['streams'][0]['width'];
    final int height = info['streams'][0]['height'];
    final double aspect = height / width;
    return aspect;
  }

  static int getDuration(Map<dynamic, dynamic> info) {
    devtools.log("at duration");
    int time = 5;
    return time;
  }

  static Future<String> encodeHLS(videoPath, outDirPath) async {
    devtools.log("encodeHLS");

    assert(File(videoPath).existsSync());

    // ignore: prefer_interpolation_to_compose_strings
    // final arguments = '-y -i $videoPath ' +
    //     '-preset ultrafast -g 48 -sc_threshold 0 ' +
    //     '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
    //     '-c:v:0 libx264 -b:v:0 2000k ' +
    //     '-c:v:1 libx264 -b:v:1 365k ' +
    //     '-c:a copy ' +
    //     '-var_stream_map "v:0,a:0 v:1,a:1" ' +
    //     '-master_pl_name master.m3u8 ' +
    //     '-f hls -hls_time 6 -hls_list_size 0 ' +
    //     '-hls_segment_filename "$outDirPath/%v_fileSequence_%d.ts" ' +
    //     '$outDirPath/%v_playlistVariant.m3u8';

    final arguments =
        '-y -i $videoPath -c:v libx264-preset slow-crf 22-c:a copy output.mkv';
    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);

    return outDirPath + "/output.mkv";
  }
}
