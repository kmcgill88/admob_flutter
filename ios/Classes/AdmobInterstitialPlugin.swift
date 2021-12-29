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
    
    fileprivate var allIds: [Int: AdmobIntersitialPluginDelegate] = [:]
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
            if allIds[id] == nil {
                allIds[id] = AdmobIntersitialPluginDelegate()
            }
            allIds[id]!.channel = FlutterMethodChannel(name: "admob_flutter/interstitial_\(id)", binaryMessenger: pluginRegistrar!.messenger())
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
            GADInterstitialAd.load(withAdUnitID: adUnitId,
                                   request: request,
                                   completionHandler: { [weak self] ad, error in
                if let self = self {
                    if self.allIds[id] == nil {
                        self.allIds[id] = AdmobIntersitialPluginDelegate()
                    }
                    let del = self.allIds[id]!
                    
                    if let error = error {
                        del.channel?.invokeMethod("failedToLoad", arguments:  [
                            "errorCode": 1,
                            "error": error.localizedDescription
                        ])
                        result(nil)
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
            result(allIds[id]?.ad != nil)
            break
        case "show":
            if let interstitial = allIds[id]?.ad, let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                interstitial.present(fromRootViewController: rootViewController)
                result(nil)
            } else {
                result(FlutterError(code: "Interstitial Error", message: "Failed to present interstitial", details: nil))
            }
            break
        case "dispose":
            allIds.removeValue(forKey: id)
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class AdmobIntersitialPluginDelegate: NSObject, GADFullScreenContentDelegate {
    var channel: FlutterMethodChannel? = nil
    var ad: GADInterstitialAd? = nil


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
