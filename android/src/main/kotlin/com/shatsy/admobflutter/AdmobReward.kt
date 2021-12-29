package com.shatsy.admobflutter

import android.app.Activity
import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.*
import com.google.android.gms.ads.rewarded.RewardItem
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AdmobReward(private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding, private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        val allAds: MutableMap<Int, AdmobRewardedListener?> = mutableMapOf()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setListener" -> {
                val id = call.argument<Int>("id") ?: 0
                if (allAds[id] == null) {
                    allAds[id] = AdmobRewardedListener()
                }
                allAds[id]?.adListener = createAdListener(MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/reward_$id"))
            }
            "load" -> {
                val id = call.argument<Int>("id") ?: 0
                val adUnitId = call.argument<String>("adUnitId")
                if (adUnitId == null) {
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
                    allAds[id] = AdmobRewardedListener()
                }

                RewardedAd.load(activity, adUnitId, adRequestBuilder.build(), object : RewardedAdLoadCallback() {
                    override fun onAdFailedToLoad(adError: LoadAdError) {
                        allAds[id]?.adListener?.onAdFailedToLoad(adError)
                        allAds[id] = null
                        return result.error("2", "onAdFailedToLoad", adError.message)
                    }

                    override fun onAdLoaded(rewardedAd: RewardedAd) {
                        allAds[id]?.ad = rewardedAd
                        allAds[id]?.adListener?.onAdLoaded()
                        allAds[id]!!.ad?.fullScreenContentCallback = object : FullScreenContentCallback() {
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
                } else result.success(true)
            }
            "show" -> {
                val id = call.argument<Int>("id")

                if (allAds[id]?.ad != null) {
                    allAds[id]?.ad?.show(activity) {
                        allAds[id]?.adListener?.onRewarded(it)
                    }
                } else result.error(null, null, null)
            }
            "dispose" -> {
                val id = call.argument<Int>("id") ?: 0
                AdmobInterstitial.allAds.remove(id)
                return result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}

class AdmobRewardedListener {
    var ad: RewardedAd? = null
    var adListener: AdmobFlutterAdListener? = null
}