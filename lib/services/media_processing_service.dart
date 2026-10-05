import 'dart:io';
import 'package:flutter_compress/flutter_compress.dart';

class MediaProcessingService {
  static Future<File> optimizeImage(File input) async {
    try {
      final result = await FlutterCompress.instance.compressImage(
        input.path,
        const ImageCompressConfig(
          targetSizeKB: 1200,
          maxWidth: 4096,
          maxHeight: 4096,
          quality: 90,
          keepExif: false,
          keepOriginalIfLarger: true,
        ),
      );
      final output = File(result.outputPath);
      return await output.exists() ? output : input;
    } catch (_) { return input; }
  }

  static Future<File> optimizeVideo(File input) async {
    try {
      final result = await FlutterCompress.instance.compress(
        input.path,
        const VideoCompressConfig(
          targetSizeMB: 32,
          codec: VideoCodec.h265,
          maxWidth: 2160,
          maxHeight: 2160,
          qualityPercent: 90,
          keepOriginalIfLarger: true,
          minSavingsPercent: 3,
          container: VideoContainer.mp4,
        ),
      );
      final output = File(result.outputPath);
      return await output.exists() ? output : input;
    } catch (_) { return input; }
  }
}
