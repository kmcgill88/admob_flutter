package com.shatsy.admobflutter

import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.reward.RewardItem
import com.google.android.gms.ads.reward.RewardedVideoAd
import com.google.android.gms.ads.reward.RewardedVideoAdListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AdmobReward(private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding): MethodChannel.MethodCallHandler, RewardedVideoAdListener {
  companion object {
    val allAds: MutableMap<Int, RewardedVideoAd> = mutableMapOf()
  }

  lateinit var adChannel: MethodChannel

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when(call.method) {
      "setListener" -> {
        val id = call.argument<Int>("id")
        if (allAds[id]!!.rewardedVideoAdListener != null) return

        adChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "admob_flutter/reward_$id")
        allAds[id]!!.rewardedVideoAdListener = this
      }
      "load" -> {
        val id = call.argument<Int>("id")
        val adUnitId = call.argument<String>("adUnitId")
        val userId = call.argument<String?>("userId")
        val customData = call.argument<String?>("customData")

        val adRequestBuilder = AdRequest.Builder()
        val npa = call.argument<Boolean>("nonPersonalizedAds")
        if(npa == true) {
          val extras = Bundle()
          extras.putString("npa", "1")
          adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
        }

        if (allAds[id] == null) allAds[id!!] = MobileAds.getRewardedVideoAdInstance(flutterPluginBinding.applicationContext)
        if (userId != null) allAds[id]?.setUserId(userId)
        if (customData != null) allAds[id]?.setCustomData(customData)
        allAds[id]?.loadAd(adUnitId, adRequestBuilder.build())
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
        } else result.error("2", null, null)
      }
      "dispose" -> {
        val id = call.argument<Int>("id")

        allAds[id]!!.destroy(flutterPluginBinding.applicationContext)
        allAds.remove(id)
      }
      else -> result.notImplemented()
    }
  }

  override fun onRewardedVideoAdClosed() = adChannel.invokeMethod("closed", null)
  override fun onRewardedVideoAdLeftApplication() = adChannel.invokeMethod("leftApplication", null)
  override fun onRewardedVideoAdLoaded() = adChannel.invokeMethod("loaded", null)
  override fun onRewardedVideoAdOpened() = adChannel.invokeMethod("opened", null)
  override fun onRewardedVideoCompleted() = adChannel.invokeMethod("completed", null)
  override fun onRewarded(reward: RewardItem?) = adChannel.invokeMethod("rewarded", hashMapOf("type" to (reward?.type ?: ""), "amount" to (reward?.amount ?: 0)))
  override fun onRewardedVideoStarted() = adChannel.invokeMethod("started", null)
  override fun onRewardedVideoAdFailedToLoad(errorCode: Int) = adChannel.invokeMethod("failedToLoad", hashMapOf("errorCode" to errorCode))
}
