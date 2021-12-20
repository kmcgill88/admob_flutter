package com.shatsy.admobflutter

import android.content.Context
import androidx.annotation.NonNull
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

fun createAdListener(channel: MethodChannel): AdListener {
    return object : AdListener() {
        override fun onAdLoaded() = channel.invokeMethod("loaded", null)
        override fun onAdFailedToLoad(errorCode: Int) = channel.invokeMethod("failedToLoad", hashMapOf("errorCode" to errorCode))
        override fun onAdClicked() = channel.invokeMethod("clicked", null)
        override fun onAdImpression() = channel.invokeMethod("impression", null)
        override fun onAdOpened() = channel.invokeMethod("opened", null)
        override fun onAdLeftApplication() = channel.invokeMethod("leftApplication", null)
        override fun onAdClosed() = channel.invokeMethod("closed", null)
    }
}

class AdmobFlutterPlugin : MethodCallHandler, FlutterPlugin {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var defaultChannel: MethodChannel
    private lateinit var interstitialChannel: MethodChannel
    private lateinit var rewardChannel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        defaultChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter")
        defaultChannel.setMethodCallHandler(this)

        interstitialChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/interstitial")
        interstitialChannel.setMethodCallHandler(AdmobInterstitial(flutterPluginBinding))

        rewardChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/reward")
        rewardChannel.setMethodCallHandler(AdmobReward(flutterPluginBinding))

        flutterPluginBinding.platformViewRegistry.registerViewFactory("admob_flutter/banner", AdmobBannerFactory(flutterPluginBinding.binaryMessenger))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        defaultChannel.setMethodCallHandler(null)
        interstitialChannel.setMethodCallHandler(null)
        rewardChannel.setMethodCallHandler(null)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        if (context == null) {
            return result.error("null_android_context", "Android context is null.", "Android context is null.")
        }

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
                    "SMART_BANNER" -> {
                        val metrics = context!!.resources.displayMetrics
                        result.success(hashMapOf(
                                "width" to AdSize.SMART_BANNER.getWidthInPixels(context) / metrics.density,
                                "height" to AdSize.SMART_BANNER.getHeightInPixels(context) / metrics.density
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
