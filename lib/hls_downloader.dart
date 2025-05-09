import 'package:flutter/services.dart';

class HlsDownloader {
  static const MethodChannel _channel = MethodChannel('hls_downloader');

  static Future<String?> downloadHls(String url) async {
    return await _channel.invokeMethod('downloadHls', {'url': url});
  }
}