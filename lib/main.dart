import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:video_downloader_player/video_downlaod_manager.dart';

import 'video_download_bloc.dart';
import 'video_download_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  final videoDownloadManager = await VideoDownloadManager.initialize();

  runApp(MyApp(videoDownloadManager: videoDownloadManager));
}

class MyApp extends StatelessWidget {
  final VideoDownloadManager videoDownloadManager;

  const MyApp({super.key, required this.videoDownloadManager});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoDownloadBloc(downloadManager: videoDownloadManager),
      child: MaterialApp(
        home: VideoDownloadScreen(),
      ),
    );
  }
}