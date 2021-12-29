package com.shatsy.admobflutter

import androidx.annotation.NonNull
import com.google.android.gms.ads.*
import com.google.android.gms.ads.rewarded.RewardItem
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

abstract class AdmobFlutterAdListener : AdListener() {
    open fun onRewarded(reward: RewardItem) {}
}

fun createAdListener(channel: MethodChannel): AdmobFlutterAdListener {
    return object : AdmobFlutterAdListener() {
        override fun onAdLoaded() = channel.invokeMethod("loaded", null)
        override fun onAdFailedToLoad(errorCode: LoadAdError) = channel.invokeMethod("failedToLoad", hashMapOf("errorCode" to errorCode))
        override fun onAdClicked() = channel.invokeMethod("clicked", null)
        override fun onAdImpression() = channel.invokeMethod("impression", null)
        override fun onAdOpened() = channel.invokeMethod("opened", null)
        override fun onAdClosed() = channel.invokeMethod("closed", null)
        override fun onRewarded(reward: RewardItem) = channel.invokeMethod("rewarded", hashMapOf("type" to (reward.type), "amount" to (reward.amount)))
    }
}

class AdmobFlutterPlugin : MethodCallHandler, FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var defaultChannel: MethodChannel
    private lateinit var interstitialChannel: MethodChannel
    private lateinit var rewardChannel: MethodChannel
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding

        defaultChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter")
        defaultChannel.setMethodCallHandler(this)
        interstitialChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/interstitial")
        rewardChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/reward")
        flutterPluginBinding.platformViewRegistry.registerViewFactory("admob_flutter/banner", AdmobBannerFactory(flutterPluginBinding.binaryMessenger))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        interstitialChannel.setMethodCallHandler(null)
        rewardChannel.setMethodCallHandler(null)
        flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        flutterPluginBinding?.let {
            interstitialChannel.setMethodCallHandler(AdmobInterstitial(it, binding.activity))
            rewardChannel.setMethodCallHandler(AdmobReward(it, binding.activity))
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // no-op
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        flutterPluginBinding?.let {
            interstitialChannel.setMethodCallHandler(AdmobInterstitial(it, binding.activity))
            rewardChannel.setMethodCallHandler(AdmobReward(it, binding.activity))
        }
    }

    override fun onDetachedFromActivity() {
        interstitialChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (flutterPluginBinding == null) {
            return result.error("null_android_flutterPluginBinding", "flutterPluginBinding is null.", "flutterPluginBinding is null.")
        }
        val context = flutterPluginBinding!!.applicationContext
        when (call.method) {
            "initialize" -> {
                MobileAds.initialize(context)
                @Suppress("UNCHECKED_CAST")
                (call.arguments as? ArrayList<String>)?.apply {
                    val configuration = RequestConfiguration.Builder().setTestDeviceIds(this).build()
                    MobileAds.setRequestConfiguration(configuration)
                }
            }
            "banner_size" -> {
                val args = call.arguments as HashMap<*, *>
                val name = args["name"] as String
                val width = args["width"] as Int
                when (name) {
                    "FLUID" -> {
                        val metrics = context.resources.displayMetrics
                        result.success(hashMapOf(
                                "width" to AdSize.FLUID.getWidthInPixels(context) / metrics.density,
                                "height" to AdSize.FLUID.getHeightInPixels(context) / metrics.density
                        ))
                    }
                    "ADAPTIVE_BANNER" -> {
                        val adSize = AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, width)
                        result.success(hashMapOf(
                                "width" to adSize.width,
                                "height" to adSize.height
                        ))
                    }
                    else -> result.error("banner_size", "not implemented name", name)
                }
            }
            else -> result.notImplemented()
        }
    }
}
