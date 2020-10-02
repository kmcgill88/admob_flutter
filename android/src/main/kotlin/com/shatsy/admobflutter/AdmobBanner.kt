package com.shatsy.admobflutter

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView


class AdmobBanner(context: Context, messenger: BinaryMessenger, id: Int, args: HashMap<*, *>)  : Banner(context,args)   {

   override var adView: ViewGroup = AdView(context)
    private val channel: MethodChannel = MethodChannel(messenger, "admob_flutter/banner_$id")

    init {
        channel.setMethodCallHandler(this)
        (adView as AdView).adSize = adSize
        (adView as AdView).adUnitId = adUnitId
        (adView as AdView).loadAd(adMobRequest())
    }
    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            "setListener" -> (adView as AdView).adListener = createAdListener(channel)
            "dispose" -> dispose()
            else -> result.notImplemented()
        }
    }
    override fun dispose() {
        adView.visibility = View.GONE
        (adView as AdView).destroy()
        channel.setMethodCallHandler(null)
    }
}