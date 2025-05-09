package uz.gita.video_player_task

import android.content.Context
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.datasource.cache.CacheDataSink
import androidx.media3.exoplayer.hls.offline.HlsDownloader
import androidx.media3.exoplayer.hls.playlist.HlsPlaylistParser
import kotlinx.coroutines.*
import java.io.File
import java.nio.file.Files
import java.nio.file.StandardCopyOption
import java.util.concurrent.Executors

object HlsDownloaderHelper {
    private var cache: SimpleCache? = null

    fun getCache(context: Context): SimpleCache {
        if (cache == null) {
            val cacheDir = File(context.cacheDir, "exo_cache")
            cache = SimpleCache(cacheDir, LeastRecentlyUsedCacheEvictor(1000 * 1024 * 1024)) // 100MB
        }
        return cache!!
    }

    fun downloadHls(
        context: Context,
        url: String,
        onProgress: (Float) -> Unit,
        onComplete: (String) -> Unit,
        onError: (String) -> Unit
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                    Log.d("HlsDownloader", "Starting HLS download: $url")
                val mediaItem = MediaItem.fromUri(url)
                val cache = getCache(context)
                val dataSourceFactory = DefaultDataSource.Factory(context)
                val cacheDataSourceFactory = CacheDataSource.Factory()
                    .setCache(cache)
                    .setUpstreamDataSourceFactory(dataSourceFactory)
                    .setCacheWriteDataSinkFactory(CacheDataSink.Factory().setCache(cache))
                    .setFlags(CacheDataSource.FLAG_BLOCK_ON_CACHE or CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR)

                val hlsDownloader = HlsDownloader(
                    mediaItem,
                    HlsPlaylistParser(),
                    cacheDataSourceFactory,
                    Executors.newSingleThreadExecutor()
                )

                hlsDownloader.download { contentLength, bytesDownloaded, percentDownloaded ->
                    Log.d(
                        "HlsDownloader",
                        "Progress: $percentDownloaded% ($bytesDownloaded/$contentLength bytes)"
                    )
                    onProgress(percentDownloaded)
                }

                // Copy the master playlist to app's files dir for Dart discovery
                val cacheDir = File(context.cacheDir, "exo_cache")
                val playlistFiles = cacheDir.walkTopDown().filter { it.extension == "m3u8" }.toList()
                val appDir = File(context.filesDir, "hls_downloads")
                if (!appDir.exists()) appDir.mkdirs()
                var destFile: File? = null
                if (playlistFiles.isNotEmpty()) {
                    // Copy the first found playlist (usually master)
                    val srcFile = playlistFiles.first()
                    destFile = File(appDir, "downloaded_${System.currentTimeMillis()}.m3u8")
                    Files.copy(srcFile.toPath(), destFile.toPath(), StandardCopyOption.REPLACE_EXISTING)
                    Log.d("HlsDownloader", "Copied playlist to: ${destFile.absolutePath}")
                } else {
                    Log.w("HlsDownloader", "No playlist file found to copy!")
                }

                withContext(Dispatchers.Main) {
                    if (destFile != null) {
                        onComplete(destFile.absolutePath)
                    } else {
                        onError("Playlist file not found after download")
                    }
                }
            } catch (e: Exception) {
                Log.e("HlsDownloader", "Download error: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    onError(e.message ?: "Unknown error")
                }
            }
        }
    }
}