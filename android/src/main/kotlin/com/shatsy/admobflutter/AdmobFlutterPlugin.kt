package com.shatsy.admobflutter

import android.content.Context
import androidx.annotation.NonNull
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlin.collections.HashMap

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

class AdmobFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private var defaultChannel: MethodChannel? = null
    private var interstitialChannel: MethodChannel? = null
    private var rewardChannel: MethodChannel? = null
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var context: Context

    companion object {
        const val DEFAULT_CHANNEL_NAME = "admob_flutter"
        const val INTERSTITIAL_CHANNEL_NAME = "admob_flutter/interstitial"
        const val REWARD_CHANNEL_NAME = "admob_flutter/reward"
        const val ADMOB_BANNER = "admob_flutter/banner"
        const val ADMANAGER_BANNER = "admob_flutter/admanager_banner"
    }

    private fun setHandlers(platformViewRegistry: PlatformViewRegistry) {
        this.defaultChannel = MethodChannel(binaryMessenger, DEFAULT_CHANNEL_NAME)
        this.interstitialChannel = MethodChannel(binaryMessenger, INTERSTITIAL_CHANNEL_NAME)
        this.rewardChannel = MethodChannel(binaryMessenger, REWARD_CHANNEL_NAME)
        this.defaultChannel?.setMethodCallHandler(this)
        this.interstitialChannel?.setMethodCallHandler(AdmobInterstitial(context, binaryMessenger))
        this.rewardChannel?.setMethodCallHandler(AdmobReward(context, binaryMessenger))
        platformViewRegistry.registerViewFactory(ADMOB_BANNER, AdmobBannerFactory(binaryMessenger))
        platformViewRegistry.registerViewFactory(ADMANAGER_BANNER, AdmanagerBannerFactory(binaryMessenger))
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext
        this.binaryMessenger = flutterPluginBinding.binaryMessenger
        setHandlers(flutterPluginBinding.platformViewRegistry);
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        defaultChannel?.setMethodCallHandler(null)
        defaultChannel = null
        interstitialChannel?.setMethodCallHandler(null)
        interstitialChannel = null
        rewardChannel?.setMethodCallHandler(null)
        rewardChannel = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

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
                        val metrics = context.resources.displayMetrics
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
