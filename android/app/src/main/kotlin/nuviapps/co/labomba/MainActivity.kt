package nuviapps.co.labomba

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import android.net.Uri
import android.os.Bundle
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.appodeal.ads.Appodeal
import com.appodeal.ads.RewardedVideoCallbacks
import com.appodeal.consent.ConsentManager
import com.appodeal.consent.OnConsentFormDismissedListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val PRODUCTION_APPODEAL_APP_KEY = "68e4bbc88495da884d3a820e1a38f905af1201f287cc8866"
    }

    private var soundPool: SoundPool? = null
    private var tickSoundId: Int = 0
    private var tickLoaded = false
    private var isTicking = false
    private var tickIntervalMs = 500L
    private val tickHandler = Handler(Looper.getMainLooper())
    private val tickRunnable = object : Runnable {
        override fun run() {
            if (!isTicking) return
            if (tickLoaded && tickSoundId != 0) {
                soundPool?.play(tickSoundId, 0.9f, 0.9f, 1, 0, 1.0f)
            }
            tickHandler.postDelayed(this, tickIntervalMs)
        }
    }
    private var explosion: MediaPlayer? = null
    private var pendingRewardResult: MethodChannel.Result? = null
    private var rewardEarned = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val isDebugBuild = applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
        Appodeal.setTesting(false)
        Appodeal.setLogLevel(
            if (isDebugBuild) com.appodeal.ads.utils.Log.LogLevel.verbose
            else com.appodeal.ads.utils.Log.LogLevel.none
        )
        Appodeal.setRewardedVideoCallbacks(object : RewardedVideoCallbacks {
            override fun onRewardedVideoLoaded(isPrecache: Boolean) {}
            override fun onRewardedVideoFailedToLoad() {}
            override fun onRewardedVideoShown() {}
            override fun onRewardedVideoShowFailed() {
                finishPendingReward(false)
            }
            override fun onRewardedVideoClicked() {}
            override fun onRewardedVideoFinished(amount: Double, name: String) {
                rewardEarned = true
            }
            override fun onRewardedVideoClosed(finished: Boolean) {
                finishPendingReward(rewardEarned || finished)
            }
            override fun onRewardedVideoExpired() {}
        })
        Appodeal.initialize(
            this,
            PRODUCTION_APPODEAL_APP_KEY,
            Appodeal.INTERSTITIAL or Appodeal.REWARDED_VIDEO,
        ) { }
        ReminderScheduler.createNotificationChannel(this)
        if (ReminderScheduler.isEnabled(this)) ReminderScheduler.scheduleAll(this)
    }

    private fun finishPendingReward(earned: Boolean) {
        val pending = pendingRewardResult ?: return
        pendingRewardResult = null
        rewardEarned = false
        runOnUiThread {
            pending.success(earned)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        soundPool = SoundPool.Builder()
            .setMaxStreams(4)
            .setAudioAttributes(attributes)
            .build().apply {
                setOnLoadCompleteListener { _, sampleId, status ->
                    if (sampleId == tickSoundId && status == 0) {
                        tickLoaded = true
                    }
                }
            }
        try {
            assets.openFd("flutter_assets/assets/audio/bomb_single_tick.wav").use { fd ->
                tickSoundId = soundPool?.load(fd, 1) ?: 0
            }
        } catch (_: Exception) {
            tickSoundId = 0
        }
        explosion = player("flutter_assets/assets/audio/bomb_explosion_loud.wav", attributes, false, 1f)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "labomba/audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTicking" -> {
                        tickIntervalMs = 500L
                        isTicking = true
                        tickHandler.removeCallbacks(tickRunnable)
                        tickHandler.post(tickRunnable)
                        result.success(true)
                    }
                    "setTickingRate" -> {
                        val rate = (call.argument<Double>("rate") ?: 1.0).coerceIn(0.6, 2.5)
                        tickIntervalMs = (500.0 / rate).toLong().coerceIn(200L, 850L)
                        result.success(null)
                    }
                    "pauseTicking" -> {
                        isTicking = false
                        tickHandler.removeCallbacks(tickRunnable)
                        result.success(null)
                    }
                    "resumeTicking" -> {
                        if (!isTicking) {
                            isTicking = true
                            tickHandler.removeCallbacks(tickRunnable)
                            tickHandler.post(tickRunnable)
                        }
                        result.success(null)
                    }
                    "stopTicking" -> {
                        isTicking = false
                        tickIntervalMs = 500L
                        tickHandler.removeCallbacks(tickRunnable)
                        result.success(null)
                    }
                    "explode" -> {
                        explosion?.seekTo(0)
                        explosion?.start()
                        result.success(null)
                    }
                    "openAppOrStore" -> {
                        val packageName = call.argument<String>("package")
                        if (packageName == null) {
                            result.error("missing_package", "Package name is required", null)
                        } else {
                            openAppOrStore(packageName)
                            result.success(null)
                        }
                    }
                    "openStore" -> {
                        val packageName = call.argument<String>("package")
                        if (packageName == null) {
                            result.error("missing_package", "Package name is required", null)
                        } else {
                            openStore(packageName)
                            result.success(null)
                        }
                    }
                    "showInterstitial" -> {
                        val shown = if (Appodeal.isLoaded(Appodeal.INTERSTITIAL)) {
                            Appodeal.show(this, Appodeal.INTERSTITIAL)
                        } else {
                            false
                        }
                        result.success(shown)
                    }
                    "isRewardedReady" -> {
                        result.success(Appodeal.isLoaded(Appodeal.REWARDED_VIDEO))
                    }
                    "showRewarded" -> {
                        if (pendingRewardResult != null) {
                            result.success(false)
                        } else if (Appodeal.isLoaded(Appodeal.REWARDED_VIDEO)) {
                            rewardEarned = false
                            pendingRewardResult = result
                            val shown = Appodeal.show(this, Appodeal.REWARDED_VIDEO)
                            if (!shown) {
                                finishPendingReward(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "setReminders" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        ReminderScheduler.setEnabled(this, enabled)
                        if (enabled) {
                            requestNotificationPermission()
                            ReminderScheduler.scheduleAll(this)
                        } else {
                            ReminderScheduler.cancelAll(this)
                        }
                        result.success(null)
                    }
                    "areRemindersEnabled" -> result.success(ReminderScheduler.isEnabled(this))
                    "requestNotificationPermission" -> {
                        requestNotificationPermission()
                        result.success(null)
                    }
                    "showPrivacyOptions" -> {
                        ConsentManager.showPrivacyOptionsForm(
                            this,
                            OnConsentFormDismissedListener { error ->
                                if (error == null) result.success(true)
                                else result.error("privacy_options", error.toString(), null)
                            },
                        )
                    }
                    "openUrl" -> {
                        val url = call.argument<String>("url")
                        if (url == null) result.error("missing_url", "URL is required", null)
                        else {
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 2110)
        }
    }

    private fun openAppOrStore(packageName: String) {
        packageManager.getLaunchIntentForPackage(packageName)?.let {
            startActivity(it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            return
        }
        openStore(packageName)
    }

    private fun openStore(packageName: String) {
        try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$packageName")))
        } catch (_: ActivityNotFoundException) {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$packageName")))
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

    private fun playerWithFallback(
        preferredPath: String,
        fallbackPath: String,
        attributes: AudioAttributes,
        loop: Boolean,
        volume: Float,
    ): MediaPlayer = try {
        player(preferredPath, attributes, loop, volume)
    } catch (_: Exception) {
        player(fallbackPath, attributes, loop, volume)
    }

    override fun onDestroy() {
        finishPendingReward(false)
        isTicking = false
        tickHandler.removeCallbacks(tickRunnable)
        soundPool?.release()
        soundPool = null
        explosion?.release()
        explosion = null
        super.onDestroy()
    }
}
