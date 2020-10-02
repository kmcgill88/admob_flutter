package com.shatsy.admobflutter

import android.content.Context
import android.os.Bundle
import android.view.View
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.doubleclick.AppEventListener
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.doubleclick.PublisherAdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView


class AdmobBanner(context: Context, messenger: BinaryMessenger, id: Int, args: HashMap<*, *>) : PlatformView, MethodCallHandler {
  private val channel: MethodChannel = MethodChannel(messenger, "admob_flutter/banner_$id")
  private val adView: PublisherAdView = PublisherAdView(context)

  init {
    channel.setMethodCallHandler(this)
    adView.setAdSizes(getSize(context, args?.get("adSize") as HashMap<*, *>))
    adView.adUnitId = args?.get("adUnitId") as String?
    adView.appEventListener = AppEventListener { name, data ->
        channel.invokeMethod("appEvent", hashMapOf("name" to name, "data" to data))
    }
    val npa: Boolean? = args?.get("nonPersonalizedAds") as Boolean?
    adView.loadAd(publisherAdRequest(args?.get("targetInfo") as HashMap<*, *>,npa))
  }

  private fun publisherAdRequest(targetInfo: HashMap<*, *>, npa: Boolean?): PublisherAdRequest {
      val adRequestBuilder = PublisherAdRequest.Builder()
      if(npa == true) {
      val extras = Bundle()
      extras.putString("npa", "1")
      adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
      }
      if(targetInfo.isNotEmpty()){
        targetInfo.forEach {
            (key, value) -> adRequestBuilder.addCustomTargeting(key as String, value.toString())
        }
      }
      return adRequestBuilder.build()
  }
  private fun getSize(context: Context, size: HashMap<*, *>) : AdSize {
    val width = size["width"] as Int
    val height = size["height"] as Int
    val name = size["name"] as String

    return when(name) {
      "BANNER" -> AdSize.BANNER
      "LARGE_BANNER" -> AdSize.LARGE_BANNER
      "MEDIUM_RECTANGLE" -> AdSize.MEDIUM_RECTANGLE
      "FULL_BANNER" -> AdSize.FULL_BANNER
      "LEADERBOARD" -> AdSize.LEADERBOARD
      "SMART_BANNER" -> AdSize.SMART_BANNER
      "ADAPTIVE_BANNER" -> AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, width)
      else -> AdSize(width, height)
    }
  }

  override fun getView(): View {
    return adView
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "setListener" -> adView.adListener = createAdListener(channel)
      "dispose" -> dispose()
      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    adView.visibility = View.GONE
    adView.destroy()
    channel.setMethodCallHandler(null)
  }
}