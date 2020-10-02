package com.shatsy.admobflutter

import android.content.Context
import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.InterstitialAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class AdmobInterstitial(private val context: Context, private val messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    companion object {
        val allAds: MutableMap<Int, InterstitialAd> = mutableMapOf()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setListener" -> {
                val id = call.argument<Int>("id")
                if (allAds[id]!!.adListener != null) return

                val adChannel = MethodChannel(messenger, "admob_flutter/interstitial_$id")
                allAds[id]!!.adListener = createAdListener(adChannel)
            }
            "load" -> {
                val id = call.argument<Int>("id")
                val adUnitId = call.argument<String>("adUnitId")

                val adRequestBuilder = AdRequest.Builder()
                val npa = call.argument<Boolean>("nonPersonalizedAds")
                if (npa == true) {
                    val extras = Bundle()
                    extras.putString("npa", "1")
                    adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                }

                if (allAds[id] == null) {
                    allAds[id!!] = InterstitialAd(context)
                    allAds[id]!!.adUnitId = adUnitId
                }

                // https://developers.google.com/admob/android/interstitial#create_an_interstitial_ad_object
                // Unlike iOS a new InterstitialAd object is not required
                // "A single InterstitialAd object can be used to request and display multiple interstitial ads over the course of an activity's lifespan, so you only need to construct it once."
                allAds[id]?.loadAd(adRequestBuilder.build())
                result.success(null)
            }
            "isLoaded" -> {
                val id = call.argument<Int>("id")

                if (allAds[id] == null) {
                    return result.success(false)
                }

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
