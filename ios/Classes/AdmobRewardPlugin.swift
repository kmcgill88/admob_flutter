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

import Foundation
import GoogleMobileAds

public class AdmobRewardPlugin: NSObject, FlutterPlugin {
    
    fileprivate var allIds: [Int: GADRewardBasedVideoAd] = [:]
    fileprivate var delegates: [Int: GADRewardBasedVideoAdDelegate] = [:]
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
        let adUnitId = args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/1712485313"
        
        switch call.method {
        case "setListener":
            let channel = FlutterMethodChannel(
                name: "admob_flutter/interstitial_\(id)",
                binaryMessenger: pluginRegistrar!.messenger()
            )
            delegates[id] = AdmobRewardPluginDelegate(channel: channel)
            let rewardVideo = getRewardBasedVideoAd(id: id)
            rewardVideo.delegate = delegates[id]
            break
        case "load":
            allIds[id] = getRewardBasedVideoAd(id: id)
            loadRewardBasedVideoAd(id: id, rewardBasedVideoAdUnitId: adUnitId)
            result(nil)
            break
        case "isLoaded":
            result(getRewardBasedVideoAd(id: id).isReady)
            break
        case "show":
            let rewardVideo = getRewardBasedVideoAd(id: id)
            if rewardVideo.isReady, let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rewardVideo.present(fromRootViewController: rootViewController)
            } else {
                result(FlutterError(
                    code: "GADRewardBasedVideoAd Error",
                    message: "Failed to present reward video",
                    details: nil)
                )
            }
            break
        case "dispose":
            allIds.removeValue(forKey: id)
            delegates.removeValue(forKey: id)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadRewardBasedVideoAd(id: Int, rewardBasedVideoAdUnitId: String) {
        let interstantial = getRewardBasedVideoAd(id: id)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstantial.load(request, withAdUnitID: rewardBasedVideoAdUnitId)
    }
    
    private func getRewardBasedVideoAd(id: Int) -> GADRewardBasedVideoAd {
        if allIds[id] == nil {
            let rewardBadedVideoAd = GADRewardBasedVideoAd.sharedInstance()
            allIds[id] = rewardBadedVideoAd
        }
        
        return allIds[id]!
    }
}

class AdmobRewardPluginDelegate: NSObject, GADRewardBasedVideoAdDelegate {
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        channel.invokeMethod("rewarded", arguments: [
            "type": reward.type,
            "amount": reward.amount
        ])
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("opened", arguments: nil)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("closed", arguments: nil)
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("loaded", arguments: nil)
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("started", arguments: nil)
    }
    
    func rewardBasedVideoAdMetadataDidChange(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        // UNUSED
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("completed", arguments: nil)
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": error.localizedDescription])
    }
}
