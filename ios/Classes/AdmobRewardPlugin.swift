/*
 ISC License
 
 Copyright (c) 2019 Kevin McGill <kevin@mcgilldevtech.com>
 
 Permission to use, copy, modify, and/or distribute this software for any
 purpose with or without fee is hereby granted, provided that the above
 copyright notice and this permission notice appear in all copies.
 
 THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import Flutter
import Foundation
import GoogleMobileAds

public class AdmobRewardPlugin: NSObject, FlutterPlugin {
    
    fileprivate var rewardAds: [Int: GADRewardedAd] = [:]
    fileprivate var delegates: [Int: AdmobRewardPluginDelegate] = [:]
    fileprivate var pluginRegistrar: FlutterPluginRegistrar?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdmobRewardPlugin()
        instance.pluginRegistrar = registrar
        let rewardChannel = FlutterMethodChannel(name: "admob_flutter/reward", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: rewardChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any]  else {
            result(FlutterError(
                code: "Missing args!",
                message: "Unable to convert args to [String : Any]",
                details: nil)
            )
            return
        }
        guard let id = args["id"] as? Int, let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(
                code: "Missing args!",
                message: "Reward Ad is missing id or adUnitId.",
                details: nil)
            )
            return
        }
        
        switch call.method {
        case "setListener":
            let channel = FlutterMethodChannel(
                name: "admob_flutter/reward_\(id)",
                binaryMessenger: pluginRegistrar!.messenger()
            )
            delegates[id] = AdmobRewardPluginDelegate(channel: channel)
            break
        case "load":
            loadRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId, nonPersonalizedAds: (args["nonPersonalizedAds"] as? Bool) ?? false)
            result(nil)
            break
        case "isLoaded":
            let isReady = getRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId).isReady
            result(isReady)
            break
        case "show":
            let rewardVideo = getRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId)
            if rewardVideo.isReady, let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rewardVideo.present(fromRootViewController: rootViewController, delegate: delegates[id]!)
            } else {
                result(FlutterError(
                    code: "GADRewardBasedVideoAd Error",
                    message: "Failed to present reward video",
                    details: nil)
                )
            }
            break
        case "dispose":
            rewardAds.removeValue(forKey: id)
            delegates.removeValue(forKey: id)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadRewardBasedVideoAd(id: Int, rewardBasedVideoAdUnitId: String, nonPersonalizedAds: Bool) {
        let video = GADRewardedAd(adUnitID: rewardBasedVideoAdUnitId)
        rewardAds[id] = video
        let request = GADRequest()

        if (nonPersonalizedAds) {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }

        video.load(request) { [weak self] error in
            if let error = error {
                // Handle ad failed to load case.
                self?.delegates[id]?.channel.invokeMethod("failedToLoad", arguments: ["errorCode": error.localizedDescription])
            } else {
                // Ad successfully loaded.
                self?.delegates[id]?.channel.invokeMethod("loaded", arguments: nil)
            }
        }
    }
    
    private func getRewardBasedVideoAd(id: Int, rewardBasedVideoAdUnitId: String) -> GADRewardedAd {
        if rewardAds[id] == nil {
            let rewardBadedVideoAd = GADRewardedAd(adUnitID: rewardBasedVideoAdUnitId)
            rewardAds[id] = rewardBadedVideoAd
        }
        
        return rewardAds[id]!
    }
}

class AdmobRewardPluginDelegate: NSObject, GADRewardedAdDelegate {
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        channel.invokeMethod("opened", arguments: nil)
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        channel.invokeMethod("closed", arguments: nil)
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": error.localizedDescription])
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        channel.invokeMethod("rewarded", arguments: [
            "type": reward.type,
            "amount": reward.amount
        ])
    }
}
