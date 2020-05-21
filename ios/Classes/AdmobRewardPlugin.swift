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
        let id = args["id"] as? Int ?? 0
        // Defaults to test Id's from: https://developers.google.com/admob/ios/banner
        let adUnitId = args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/1712485313"
        
        switch call.method {
        case "setListener":
            let channel = FlutterMethodChannel(
                name: "admob_flutter/reward_\(id)",
                binaryMessenger: pluginRegistrar!.messenger()
            )
            let reload: () -> Void = { [weak self] in
                self?.rewardAds.removeValue(forKey: id)
                self?.loadRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId)
            }
            delegates[id] = AdmobRewardPluginDelegate(channel: channel, reload: reload)
            break
        case "load":
            loadRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId)
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
    
    private func loadRewardBasedVideoAd(id: Int, rewardBasedVideoAdUnitId: String) {
        let video = getRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: rewardBasedVideoAdUnitId)
        let request = GADRequest()
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
    let reload: () -> Void
    
    init(channel: FlutterMethodChannel, reload: @escaping () -> Void) {
        self.channel = channel
        self.reload = reload
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        channel.invokeMethod("opened", arguments: nil)
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        channel.invokeMethod("closed", arguments: nil)
        // https://developers.google.com/admob/ios/rewarded-ads#using_gadrewardedaddelegate_to_preload_the_next_rewarded_ad
        reload()
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
