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

public class AdmobIntersitialPlugin: NSObject, FlutterPlugin {
    
    fileprivate var allIds: [Int: GADInterstitial] = [:]
    fileprivate var delegates: [Int: GADInterstitialDelegate] = [:]
    fileprivate var pluginRegistrar: FlutterPluginRegistrar?

    fileprivate var interstantialAdUnitId: String?
    fileprivate var interstitialChannel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdmobIntersitialPlugin()
        instance.pluginRegistrar = registrar
        let channel = FlutterMethodChannel(name: "admob_flutter/interstitial", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any]  else {
            result(FlutterError(code: "Missing args!", message: "Unable to convert args to [String : Any]", details: nil))
            return
        }
        let id = args["id"] as? Int ?? 0
        // Defaults to test Id's from: https://developers.google.com/admob/ios/banner
        let adUnitId = args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/1033173712"

        switch call.method {
        case "setListener":
            let channel = FlutterMethodChannel(name: "admob_flutter/interstitial_\(id)", binaryMessenger: pluginRegistrar!.messenger())
            delegates[id] = AdmobIntersitialPluginDelegate(channel: channel)
            let interstantialAd = getInterstitialAd(id: id, interstantialAdUnitId: adUnitId)
            interstantialAd.delegate = delegates[id]
            break
        case "load":
            allIds[id] = getInterstitialAd(id: id, interstantialAdUnitId: adUnitId)
            loadInterstantialAd(id: id, interstantialAdUnitId: adUnitId, nonPersonalizedAds: (args["nonPersonalizedAds"] as? Bool) ?? false)
            result(nil)
            break
        case "isLoaded":
            let interstitial = getInterstitialAd(id: id, interstantialAdUnitId: adUnitId)
            result(interstitial.isReady && !interstitial.hasBeenUsed)
            break
        case "show":
            let interstitial = getInterstitialAd(id: id, interstantialAdUnitId: adUnitId)
            if interstitial.isReady && !interstitial.hasBeenUsed, let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                interstitial.present(fromRootViewController: rootViewController)
            } else {
                result(FlutterError(code: "Interstitial Error", message: "Failed to present interstitial", details: nil))
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
    
    private func loadInterstantialAd(id: Int, interstantialAdUnitId: String, nonPersonalizedAds: Bool) {
        let interstantial = getInterstitialAd(id: id, interstantialAdUnitId: interstantialAdUnitId)
        let request = GADRequest()

        if (nonPersonalizedAds) {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }

        interstantial.load(request)
    }
    
    private func getInterstitialAd(id: Int, interstantialAdUnitId: String) -> GADInterstitial {
        if let interstantialAd = allIds[id] {
            // https://developers.google.com/admob/ios/interstitial#use_gadinterstitialdelegate_to_reload
            // "GADInterstitial is a one-time-use object. This means once an interstitial is shown, hasBeenUsed returns true and the interstitial can't be used to load another ad. To request another interstitial, you'll need to create a new GADInterstitial object."
            if (interstantialAd.hasBeenUsed) {
                let interstantialAd = GADInterstitial(adUnitID: interstantialAdUnitId)
                allIds[id] = interstantialAd
            }
        } else {
            let interstantialAd = GADInterstitial(adUnitID: interstantialAdUnitId)
            allIds[id] = interstantialAd
        }
        
        return allIds[id]!
    }
}

class AdmobIntersitialPluginDelegate: NSObject, GADInterstitialDelegate {
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    // TODO: not sure this exists on iOS.
    // channel.invokeMethod("impression", null)
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        channel.invokeMethod("clicked", arguments: nil)
        channel.invokeMethod("opened", arguments: nil)
    }

    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        // Unused
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        channel.invokeMethod("closed", arguments: nil)
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        channel.invokeMethod("loaded", arguments: nil)
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("failedToLoad", arguments:  [
            "errorCode": error.code,
            "error": error.localizedDescription
        ])
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": ad.isReady && ad.hasBeenUsed])
    }
}
