package nuviapps.co.labomba

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.MediaPlayer
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var ticking: AudioTrack? = null
    private var explosion: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        ticking = loopingTrack("flutter_assets/assets/audio/bomb_ticking_tight.wav", attributes)
        explosion = player("flutter_assets/assets/audio/bomb_explosion.wav", attributes, false, 1f)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "labomba/audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTicking" -> {
                        ticking?.stop()
                        ticking?.reloadStaticData()
                        ticking?.setPlaybackHeadPosition(0)
                        ticking?.play()
                        result.success(ticking?.playState == AudioTrack.PLAYSTATE_PLAYING)
                    }
                    "pauseTicking" -> {
                        if (ticking?.playState == AudioTrack.PLAYSTATE_PLAYING) ticking?.pause()
                        result.success(null)
                    }
                    "resumeTicking" -> {
                        ticking?.play()
                        result.success(null)
                    }
                    "stopTicking" -> {
                        ticking?.stop()
                        ticking?.reloadStaticData()
                        result.success(null)
                    }
                    "explode" -> {
                        explosion?.seekTo(0)
                        explosion?.start()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun player(path: String, attributes: AudioAttributes, loop: Boolean, volume: Float): MediaPlayer {
        return assets.openFd(path).use { descriptor ->
            MediaPlayer().apply {
                setAudioAttributes(attributes)
                setDataSource(descriptor.fileDescriptor, descriptor.startOffset, descriptor.length)
                isLooping = loop
                setVolume(volume, volume)
                prepare()
            }
        }
    }

    private fun loopingTrack(path: String, attributes: AudioAttributes): AudioTrack {
        val wav = assets.open(path).use { it.readBytes() }
        var offset = 12
        var channels = 2
        var sampleRate = 44100
        var pcm = ByteArray(0)
        while (offset + 8 <= wav.size) {
            val id = String(wav, offset, 4, Charsets.US_ASCII)
            val size = littleEndianInt(wav, offset + 4)
            if (id == "fmt " && offset + 16 < wav.size) {
                channels = littleEndianShort(wav, offset + 10)
                sampleRate = littleEndianInt(wav, offset + 12)
            }
            if (id == "data") {
                val start = offset + 8
                pcm = wav.copyOfRange(start, minOf(start + size, wav.size))
                break
            }
            offset += 8 + size + (size and 1)
        }
        val channelMask = if (channels == 1) AudioFormat.CHANNEL_OUT_MONO else AudioFormat.CHANNEL_OUT_STEREO
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(sampleRate)
            .setChannelMask(channelMask)
            .build()
        return AudioTrack.Builder()
            .setAudioAttributes(attributes)
            .setAudioFormat(format)
            .setBufferSizeInBytes(pcm.size)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build().apply {
                write(pcm, 0, pcm.size, AudioTrack.WRITE_BLOCKING)
                setLoopPoints(0, pcm.size / (channels * 2), -1)
                setVolume(.78f)
            }
    }

    private fun littleEndianInt(data: ByteArray, offset: Int): Int =
        (data[offset].toInt() and 0xff) or
            ((data[offset + 1].toInt() and 0xff) shl 8) or
            ((data[offset + 2].toInt() and 0xff) shl 16) or
            ((data[offset + 3].toInt() and 0xff) shl 24)

    private fun littleEndianShort(data: ByteArray, offset: Int): Int =
        (data[offset].toInt() and 0xff) or ((data[offset + 1].toInt() and 0xff) shl 8)

    override fun onDestroy() {
        ticking?.release()
        explosion?.release()
        ticking = null
        explosion = null
        super.onDestroy()
    }
}
