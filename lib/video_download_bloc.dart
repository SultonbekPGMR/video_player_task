import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_downloader_player/video_downlaod_manager.dart';

part 'video_download_event.dart';
part 'video_download_state.dart';

class VideoDownloadBloc extends Bloc<VideoDownloadEvent, VideoDownloadState> {
  final VideoDownloadManager downloadManager;

  late final StreamSubscription _progressSubscription;
  late final StreamSubscription _completeSubscription;
  late final StreamSubscription _errorSubscription;
  late final StreamSubscription _videosSubscription;

  VideoDownloadBloc({required this.downloadManager}) : super(VideoDownloadState()) {
    on<StartDownloadEvent>(_onStartDownload);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<RemoveDownloadEvent>(_onRemoveDownload);
    on<PlayVideoEvent>(_onPlayVideo);
    on<PlayOnlineVideoEvent>(_onPlayOnlineVideo);
    on<_DownloadError>(_onDownloadError);
    on<_DownloadProgressUpdate>(_onDownloadProgress);
    on<_DownloadComplete>(_onDownloadComplete);
    on<_LoadDownloadedVideos>(_onLoadDownloadedVideos);

    _progressSubscription = downloadManager.downloadProgressStream.listen((progress) {
      add(_DownloadProgressUpdate(progress));
    });
    _completeSubscription = downloadManager.downloadCompleteStream.listen((taskId) {
      add(_DownloadComplete(taskId));
    });
    _errorSubscription = downloadManager.downloadErrorStream.listen((message) {
      add(_DownloadError(message));
    });
    _videosSubscription = downloadManager.downloadedVideosStream.listen((paths) {
      print('TTTPPP _videosSubscription $paths');
      add(_LoadDownloadedVideos(paths));
    });
  }

  Future<void> _onStartDownload(StartDownloadEvent event, Emitter<VideoDownloadState> emit) async {
    emit(state.copyWith(status: Status.downloading, errorMessage: null));
    try {
      final taskId = await downloadManager.startDownload(event.videoUrl );
      emit(state.copyWith(currentTaskId: taskId, ));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString(), currentTaskId: null));
    }
  }

  Future<void> _onCancelDownload(CancelDownloadEvent event, Emitter<VideoDownloadState> emit) async {
    try {
      await downloadManager.cancelDownload(event.taskId);
      emit(state.copyWith(status: Status.cancelled, currentTaskId: null, downloadProgress: 0.0));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString(), currentTaskId: null));
    }
  }

  Future<void> _onRemoveDownload(RemoveDownloadEvent event, Emitter<VideoDownloadState> emit) async {
    try {
      await downloadManager.removeDownload(event.videoId);

    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  void _onPlayVideo(PlayVideoEvent event, Emitter<VideoDownloadState> emit) {
    emit(state.copyWith(status: Status.playing, videoPath: event.filePath, videoTitle: event.videoTitle));
  }

  void _onPlayOnlineVideo(PlayOnlineVideoEvent event, Emitter<VideoDownloadState> emit) {
    emit(state.copyWith(status: Status.playing, videoPath: event.videoUrl, videoTitle: 'Online Video'));
  }

  void _onDownloadProgress(_DownloadProgressUpdate event, Emitter<VideoDownloadState> emit) {
    emit(state.copyWith(downloadProgress: event.progress));
  }

  Future<void> _onDownloadComplete(_DownloadComplete event, Emitter<VideoDownloadState> emit) async {
    emit(state.copyWith(status: Status.completed, currentTaskId: null, downloadProgress: 1.0));
  }

  Future<void> _onLoadDownloadedVideos(_LoadDownloadedVideos event, Emitter<VideoDownloadState> emit) async {
    emit(state.copyWith(downloadedVideos: event.videoPaths));
  }

  void _onDownloadError(_DownloadError event, Emitter<VideoDownloadState> emit) {
    emit(state.copyWith(status: Status.error, errorMessage: event.message, currentTaskId: null));
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    await _completeSubscription.cancel();
    await _errorSubscription.cancel();
    await _videosSubscription.cancel();
    return super.close();
  }
}

class _DownloadProgressUpdate extends VideoDownloadEvent {
  final double progress;
  _DownloadProgressUpdate(this.progress);
}

class _DownloadComplete extends VideoDownloadEvent {
  final String taskId;
  _DownloadComplete(this.taskId);
}

class _DownloadError extends VideoDownloadEvent {
  final String message;
  _DownloadError(this.message);
}

class _LoadDownloadedVideos extends VideoDownloadEvent {
  final List<String> videoPaths;
  _LoadDownloadedVideos(this.videoPaths);
}