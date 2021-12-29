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
    
    fileprivate var rewardAds: [Int: AdmobRewardPluginDelegate] = [:]
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
            if rewardAds[id] == nil {
                rewardAds[id] = AdmobRewardPluginDelegate()
            }
            rewardAds[id]!.channel = FlutterMethodChannel(
                    name: "admob_flutter/reward_\(id)",
                    binaryMessenger: pluginRegistrar!.messenger()
                )
            result(nil)
            break
        case "load":
            let request = GADRequest()
            let nonPersonalizedAds = (args["nonPersonalizedAds"] as? Bool) ?? false

            if (nonPersonalizedAds) {
                let extras = GADExtras()
                extras.additionalParameters = ["npa": "1"]
                request.register(extras)
            }
            GADRewardedAd.load(withAdUnitID: adUnitId,
                                   request: request,
                                   completionHandler: { [weak self] ad, error in
                if let self = self {
                    if self.rewardAds[id] == nil {
                        self.rewardAds[id] = AdmobRewardPluginDelegate()
                    }
                    let del = self.rewardAds[id]!
                    
                    if let error = error {
                        result(FlutterError(code: "Failed to load!", message: "Failed to load interstitial ad with error: \(error.localizedDescription)", details: error.localizedDescription))
                        return
                    }
                    del.ad = ad
                    del.ad?.fullScreenContentDelegate = del
                    del.channel?.invokeMethod("loaded", arguments: nil)
                    result(nil)
                }

            })
            break
        case "isLoaded":
            result(rewardAds[id] != nil)
            break
        case "show":
            if let del = rewardAds[id], let rewardAd = del.ad, let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rewardAd.present(fromRootViewController: rootViewController) {
                    if let channel = del.channel {
                        print("rewarded")
                        channel.invokeMethod("rewarded", arguments: [
                            "type": rewardAd.adReward.type,
                            "amount": rewardAd.adReward.amount
                        ])
                    } else {
                        print("rewarded but no channel")
                    }
                }
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
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class AdmobRewardPluginDelegate: NSObject, GADFullScreenContentDelegate {
    var channel: FlutterMethodChannel? = nil
    var ad: GADRewardedAd? = nil

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Unused
    }

    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        channel?.invokeMethod("opened", arguments: nil)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        channel?.invokeMethod("closed", arguments: nil)
    }

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        channel?.invokeMethod("impression", arguments: nil)
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        channel?.invokeMethod("clicked", arguments: nil)
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        channel?.invokeMethod("failedToLoad", arguments:  [
            "errorCode": 1,
            "error": error.localizedDescription
        ])
    }
}
