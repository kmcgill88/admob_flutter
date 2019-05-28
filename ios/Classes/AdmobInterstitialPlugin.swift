/*
 Copyright (c) 2019 Kevin McGill <kevin@mcgilldevtech.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
            loadInterstantialAd(id: id, interstantialAdUnitId: adUnitId)
            result(nil)
            break
        case "isLoaded":
            result(getInterstitialAd(id: id, interstantialAdUnitId: adUnitId).isReady)
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
    
    private func loadInterstantialAd(id: Int, interstantialAdUnitId: String) {
        let interstantial = getInterstitialAd(id: id, interstantialAdUnitId: interstantialAdUnitId)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstantial.load(request)
    }
    
    private func getInterstitialAd(id: Int, interstantialAdUnitId: String) -> GADInterstitial {
        if allIds[id] == nil {
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
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": error])
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": ad.isReady && ad.hasBeenUsed])
    }
}
