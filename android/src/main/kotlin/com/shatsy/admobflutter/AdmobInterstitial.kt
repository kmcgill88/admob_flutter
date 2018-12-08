package com.shatsy.admobflutter

import android.content.Context
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.InterstitialAd
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AdmobInterstitial(private val context: Context): MethodChannel.MethodCallHandler {
  companion object {
    val allAds: MutableMap<Int, InterstitialAd> = mutableMapOf()
  }
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when(call.method) {
      "load" -> {
        val id = call.argument<Int>("id")
        val adUnitId = call.argument<String>("adUnitId")
        val adRequest = AdRequest.Builder().build()

        allAds[id!!] = InterstitialAd(context)
        allAds[id]!!.adUnitId = adUnitId
        allAds[id]?.loadAd(adRequest)
        result.success(null)
      }
      "isLoaded" -> {
        val id = call.argument<Int>("id")

        if (allAds[id]!!.isLoaded) {
          result.success(true)
        } else result.success(false)
      }
      "show" -> {
        val id = call.argument<Int>("id")

        if (allAds[id]!!.isLoaded) {
          allAds[id]!!.show()
        } else result.error(null, null, null)
      }
      "dispose" -> {
        val id = call.argument<Int>("id")

        allAds.remove(id)
      }
      else -> result.notImplemented()
    }
  }
}
