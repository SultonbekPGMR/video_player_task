package uz.gita.video_player_task

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log


class MainActivity : FlutterActivity() {
    private val CHANNEL = "hls_downloader"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "downloadHls") {
                val url = call.argument<String>("url") ?: ""
                HlsDownloaderHelper.downloadHls(
                    this,
                    url,
                    onProgress = { percent ->
                        // Optionally: send progress updates to Flutter via EventChannel

                    },
                    onComplete = { localUrl ->
                        result.success(localUrl)
                        Log.d("HlsDownloader12", "Copied playlist to: $localUrl")

                    },
                    onError = { error ->
                        result.error("HLS_DOWNLOAD_ERROR", error, null)
                    }
                )
            } else {
                result.notImplemented()
            }
        }
    }
}