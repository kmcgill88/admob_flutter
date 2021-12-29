package com.shatsy.admobflutter

import android.app.Activity
import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AdmobInterstitial(private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding, private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        val allAds: MutableMap<Int, AdmobInterstitialListener?> = mutableMapOf()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setListener" -> {
                val id = call.argument<Int>("id")
                if (id == null) {
                    result.error("1", "Missing id", "Missing id")
                    return
                }
                if (allAds[id] == null) {
                    allAds[id] = AdmobInterstitialListener()
                }
                allAds[id]!!.adListener = createAdListener(MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/interstitial_$id"))
                return result.success(null)
            }
            "load" -> {
                val id = call.argument<Int>("id")
                val adUnitId = call.argument<String>("adUnitId")
                if (id == null || adUnitId == null) {
                    result.error("1", "Missing id and/or adUnitId", "Missing id and/or adUnitId")
                    return
                }

                val adRequestBuilder = AdRequest.Builder()
                val npa = call.argument<Boolean>("nonPersonalizedAds")
                if (npa == true) {
                    val extras = Bundle()
                    extras.putString("npa", "1")
                    adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
                }
                if (allAds[id] == null) {
                    allAds[id] = AdmobInterstitialListener()
                }

                InterstitialAd.load(activity, adUnitId, adRequestBuilder.build(), object : InterstitialAdLoadCallback() {
                    override fun onAdFailedToLoad(adError: LoadAdError) {
                        allAds[id]?.adListener?.onAdFailedToLoad(adError)
                        allAds[id] = null
                        return result.error("2", "onAdFailedToLoad", adError.message)
                    }

                    override fun onAdLoaded(interstitialAd: InterstitialAd) {
                        allAds[id]?.ad = interstitialAd
                        allAds[id]?.adListener?.onAdLoaded()
                        allAds[id]?.ad?.fullScreenContentCallback = object : FullScreenContentCallback() {
                            override fun onAdDismissedFullScreenContent() {
                                allAds[id]?.adListener?.onAdClosed()
                            }

                            override fun onAdFailedToShowFullScreenContent(adError: AdError?) {
                                adError?.let {
                                    allAds[id]?.adListener?.onAdFailedToLoad(LoadAdError(it.code, it.message, "admob_flutter", adError, null))
                                }
                            }

                            override fun onAdShowedFullScreenContent() {
                                allAds[id]?.adListener?.onAdOpened()
                            }
                        }
                        return result.success(null)
                    }
                })

            }
            "isLoaded" -> {
                val id = call.argument<Int>("id")

                return if (allAds[id] == null) {
                    result.success(false)
                } else {
                    result.success(true)
                }
            }
            "show" -> {
                val id = call.argument<Int>("id")
                return if (allAds[id]?.ad != null) {
                    allAds[id]?.ad?.show(activity)
                    result.success(null)
                } else result.error(null, null, null)
            }
            "dispose" -> {
                val id = call.argument<Int>("id")
                allAds.remove(id)
                return result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}

class AdmobInterstitialListener {
    var ad: InterstitialAd? = null
    var adListener: AdListener? = null
}