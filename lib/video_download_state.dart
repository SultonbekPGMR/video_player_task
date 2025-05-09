part of 'video_download_bloc.dart';

class VideoDownloadState {
  final Status status;
  final List<String> downloadedVideos;
  final double downloadProgress;
  final String? errorMessage;
  final String? videoPath;
  final String? videoTitle;
  final String? currentTaskId; // 👈 new field

  VideoDownloadState({
    this.status = Status.loading,
    this.downloadedVideos = const [],
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.videoPath,
    this.videoTitle,
    this.currentTaskId,
  });

  VideoDownloadState copyWith({
    Status? status,
    List<String>? downloadedVideos,
    double? downloadProgress,
    String? errorMessage,
    String? videoPath,
    String? videoTitle,
    String? currentTaskId,
  }) {
    return VideoDownloadState(
      status: status ?? this.status,
      downloadedVideos: downloadedVideos ?? this.downloadedVideos,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      videoPath: videoPath ?? this.videoPath,
      videoTitle: videoTitle ?? this.videoTitle,
      currentTaskId: currentTaskId ?? this.currentTaskId,
    );
  }

  @override
  String toString() {
    return 'VideoDownloadState('
        'status: $status, '
        'downloadedVideos: ${downloadedVideos.length} items, '
        'downloadProgress: $downloadProgress, '
        'errorMessage: ${errorMessage ?? "none"}, '
        'videoPath: $videoPath, '
        'videoTitle: $videoTitle, '
        'currentTaskId: $currentTaskId'
        ')';
  }
}

enum Status { loading, downloading, completed, cancelled, error, playing }

