package com.shatsy.admobflutter

import android.os.Bundle
import android.util.Log
import com.google.ads.mediation.admob.AdMobAdapter
import com.google.android.gms.ads.AdRequest

import java.util.ArrayList
import java.util.Date

internal class AdRequestBuilderFactory(private val targetingInfo: HashMap<*, *>?) {
    private fun getTargetingInfoString(key: String, value: Any?): String? {
        if (value == null) return null
        if (value !is String) {
            Log.w(TAG, "targeting info $key: expected a String")
            return null
        }
        if (value.isEmpty()) {
            Log.w(TAG, "targeting info $key: expected a non-empty String")
            return null
        }
        return value
    }

    private fun getTargetingInfoBoolean(key: String, value: Any?): Boolean? {
        if (value == null) return null
        if (value !is Boolean) {
            Log.w(TAG, "targeting info $key: expected a boolean")
            return null
        }
        return value
    }

    private fun getTargetingInfoInteger(key: String, value: Any?): Int? {
        if (value == null) return null
        if (value !is Int) {
            Log.w(TAG, "targeting info $key: expected an integer")
            return null
        }
        return value
    }

    private fun getTargetingInfoArrayList(key: String, value: Any?): List<*>? {
        if (value == null) return null
        if (value !is ArrayList<*>) {
            Log.w(TAG, "targeting info $key: expected an ArrayList")
            return null
        }
        return value
    }

    fun createAdRequestBuilder(): AdRequest.Builder {
        val builder: AdRequest.Builder = AdRequest.Builder()
        if (targetingInfo == null) return builder
        val testDevices = getTargetingInfoArrayList("testDevices", targetingInfo["testDevices"])
        if (testDevices != null) {
            for (deviceValue in testDevices) {
                val device = getTargetingInfoString("testDevices element", deviceValue)
                if (device != null) builder.addTestDevice(device)
            }
        }
        val keywords = getTargetingInfoArrayList("keywords", targetingInfo["keywords"])
        if (keywords != null) {
            for (keywordValue in keywords) {
                val keyword = getTargetingInfoString("keywords element", keywordValue)
                if (keyword != null) builder.addKeyword(keyword)
            }
        }
        val contentUrl = getTargetingInfoString("contentUrl", targetingInfo["contentUrl"])
        if (contentUrl != null) builder.setContentUrl(contentUrl)
        val birthday = targetingInfo["birthday"]
        if (birthday != null) {
            if (birthday !is Long) Log.w(TAG, "targetingInfo birthday: expected a long integer") else builder.setBirthday(Date(birthday))
        }
        val gender = getTargetingInfoInteger("gender", targetingInfo["gender"])
        if (gender != null) {
            when (gender) {
                0, 1, 2 -> builder.setGender(gender)
                else -> Log.w(TAG, "targetingInfo gender: invalid value")
            }
        }
        val designedForFamilies = getTargetingInfoBoolean("designedForFamilies", targetingInfo["designedForFamilies"])
        if (designedForFamilies != null) builder.setIsDesignedForFamilies(designedForFamilies)
        val childDirected = getTargetingInfoBoolean("childDirected", targetingInfo["childDirected"])
        if (childDirected != null) builder.tagForChildDirectedTreatment(childDirected)
        val requestAgent = getTargetingInfoString("requestAgent", targetingInfo["requestAgent"])
        if (requestAgent != null) builder.setRequestAgent(requestAgent)
        val nonPersonalizedAds = getTargetingInfoBoolean("nonPersonalizedAds", targetingInfo["nonPersonalizedAds"])
        if (nonPersonalizedAds != null && nonPersonalizedAds) {
            val extras = Bundle()
            extras.putString("npa", "1")
            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
        }
        return builder
    }

    companion object {
        private const val TAG = "flutter"
    }

}