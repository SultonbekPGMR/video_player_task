part of 'video_download_bloc.dart';

abstract class VideoDownloadEvent {}

class StartDownloadEvent extends VideoDownloadEvent {
  final String videoUrl;

  StartDownloadEvent({required this.videoUrl});
}

class CancelDownloadEvent extends VideoDownloadEvent {
  final String taskId;

  CancelDownloadEvent({required this.taskId});
}

class RemoveDownloadEvent extends VideoDownloadEvent {
  final String videoId;

  RemoveDownloadEvent({required this.videoId});
}

class PlayVideoEvent extends VideoDownloadEvent {
  final String filePath;
  final String videoTitle;

  PlayVideoEvent({required this.filePath, required this.videoTitle});
}

class PlayOnlineVideoEvent extends VideoDownloadEvent {
  final String videoUrl;

  PlayOnlineVideoEvent({required this.videoUrl});
}
