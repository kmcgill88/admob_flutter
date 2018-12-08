package com.shatsy.admobflutter

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.gms.ads.MobileAds

class AdmobFlutterPlugin(private val context: Context): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val defaultChannel = MethodChannel(registrar.messenger(), "admob_flutter")
      defaultChannel.setMethodCallHandler(AdmobFlutterPlugin(registrar.context()))

      val interstitialChannel = MethodChannel(registrar.messenger(), "admob_flutter/interstitial")
      interstitialChannel.setMethodCallHandler(AdmobInterstitial(registrar.context()))

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
