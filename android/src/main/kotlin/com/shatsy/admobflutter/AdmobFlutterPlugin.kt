package com.shatsy.admobflutter

import android.content.Context
import com.google.android.gms.ads.AdListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.gms.ads.MobileAds

fun createAdListener(channel: MethodChannel) : AdListener {
  return object: AdListener() {
    override fun onAdLoaded() = channel.invokeMethod("loaded", null)
    override fun onAdFailedToLoad(errorCode: Int) = channel.invokeMethod("failedToLoad", hashMapOf("errorCode" to errorCode))
    override fun onAdClicked() = channel.invokeMethod("clicked", null)
    override fun onAdImpression() = channel.invokeMethod("impression", null)
    override fun onAdOpened() = channel.invokeMethod("opened", null)
    override fun onAdLeftApplication() = channel.invokeMethod("leftApplication", null)
    override fun onAdClosed() = channel.invokeMethod("closed", null)
  }
}

class AdmobFlutterPlugin(private val context: Context): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val defaultChannel = MethodChannel(registrar.messenger(), "admob_flutter")
      defaultChannel.setMethodCallHandler(AdmobFlutterPlugin(registrar.context()))

      val interstitialChannel = MethodChannel(registrar.messenger(), "admob_flutter/interstitial")
      interstitialChannel.setMethodCallHandler(AdmobInterstitial(registrar))

      val rewardChannel = MethodChannel(registrar.messenger(), "admob_flutter/reward")
      rewardChannel.setMethodCallHandler(AdmobReward(registrar))

      registrar
        .platformViewRegistry()
        .registerViewFactory("admob_flutter/banner", AdmobBannerFactory(registrar.messenger()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "initialize" -> MobileAds.initialize(context, call.arguments())
      else -> result.notImplemented()
    }
  }
}
