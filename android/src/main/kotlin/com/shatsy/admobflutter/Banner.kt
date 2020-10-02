package com.shatsy.admobflutter

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView


abstract class Banner(context: Context, private val args: HashMap<*, *>) : PlatformView, MethodCallHandler {
    var npa: Boolean? = args?.get("nonPersonalizedAds") as Boolean?
    var contentUrl: String? = args?.get("contentUrl") as String?
    var adSize: AdSize = getSize(context, args?.get("adSize") as HashMap<*, *>)
    var adUnitId: String? = args?.get("adUnitId") as String?
    abstract var adView: ViewGroup
    open fun getSize(context: Context, size: HashMap<*, *>): AdSize {
        val width = size["width"] as Int
        val height = size["height"] as Int

        return when (size["name"] as String) {
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

    open fun adMobRequest(): AdRequest {
        val adRequestBuilder = AdRequest.Builder()
        if (npa == true) {
            val extras = Bundle()
            extras.putString("npa", "1")
            adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
        }
        if (contentUrl != null && contentUrl!!.isNotBlank()) {
            adRequestBuilder.setContentUrl(contentUrl)
        }
        return adRequestBuilder.build()
    }

    open fun adManagerRequest(): PublisherAdRequest {
        val adRequestBuilder = PublisherAdRequest.Builder()
        if (npa == true) {
            val extras = Bundle()
            extras.putString("npa", "1")
            adRequestBuilder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
        }
        if (contentUrl != null && contentUrl!!.isNotBlank()) {
            adRequestBuilder.setContentUrl(contentUrl)
        }

        if (args?.containsKey("targetInfo")) {
            val targetInfo = args?.get("targetInfo") as HashMap<*, *>
            if (targetInfo?.isNotEmpty()!!) {
                targetInfo?.forEach { (key, value) ->
                    adRequestBuilder.addCustomTargeting(key as String, value.toString())
                }
            }
        }
        return adRequestBuilder.build()
    }

    override fun getView(): View {
        return adView
    }

    abstract override fun dispose()
    abstract override fun onMethodCall(call: MethodCall, result: Result)


}
