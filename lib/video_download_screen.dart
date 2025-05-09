import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_downloader_player/universal_video_player.dart';
import 'package:video_player_task/context_extension.dart';
import 'video_download_bloc.dart';

class VideoDownloadScreen extends StatefulWidget {
  const VideoDownloadScreen({super.key});

  @override
  State<VideoDownloadScreen> createState() => _VideoDownloadScreenState();
}

class _VideoDownloadScreenState extends State<VideoDownloadScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<VideoDownloadBloc, VideoDownloadState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Video URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.navigateTo(UniversalVideoPlayer(source: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8'));
                    return;
                    final url = _urlController.text.trim();
                    if (url.isNotEmpty) {
                      context.read<VideoDownloadBloc>().add(
                        StartDownloadEvent(videoUrl: url),
                      );
                    }
                  },
                  child: const Text("Start Download"),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Downloaded Videos:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.downloadedVideos.isEmpty
                      ? const Center(child: Text("No videos downloaded."))
                      : ListView.builder(
                    itemCount: state.downloadedVideos.length,
                    itemBuilder: (context, index) {
                      final path = state.downloadedVideos[index];
                      final fileName = path.split('/').last;
                      return ListTile(
                        title: Text(fileName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                context.navigateTo(
                                  UniversalVideoPlayer(source: path),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context.read<VideoDownloadBloc>().add(
                                  RemoveDownloadEvent(videoId: path),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (state.status == Status.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Error: ${state.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

