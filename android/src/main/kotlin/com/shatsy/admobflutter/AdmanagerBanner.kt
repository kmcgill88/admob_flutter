package com.shatsy.admobflutter

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.doubleclick.AppEventListener
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.doubleclick.PublisherAdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView


class AdmanagerBanner(context: Context, messenger: BinaryMessenger, id: Int, args: HashMap<*, *>) : Banner(context,args) {
    override var adView: ViewGroup = PublisherAdView(context)
    val channel: MethodChannel = MethodChannel(messenger, "admob_flutter/admanager_banner_$id")

    init {
        channel.setMethodCallHandler(this)
        (adView as PublisherAdView).setAdSizes(adSize)
        (adView as PublisherAdView).adUnitId = adUnitId
        (adView as PublisherAdView).appEventListener = AppEventListener { name, data ->
            channel.invokeMethod("appEvent", hashMapOf("name" to name, "data" to data))
        }
        (adView as PublisherAdView).loadAd(adManagerRequest())
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setListener" -> (adView as PublisherAdView).adListener = createAdListener(channel)
            "dispose" -> dispose()
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        adView.visibility = View.GONE
        (adView as PublisherAdView).destroy()
        channel.setMethodCallHandler(null)
    }
}