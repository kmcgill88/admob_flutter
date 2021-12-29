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

class AdmobBanner : NSObject, FlutterPlatformView {

    private let channel: FlutterMethodChannel
    private let messeneger: FlutterBinaryMessenger
    private let frame: CGRect
    private let viewId: Int64
    private let args: [String: Any]
    private var adView: GADBannerView?

    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        self.args = args
        self.messeneger = messeneger
        self.frame = frame
        self.viewId = viewId
        channel = FlutterMethodChannel(name: "admob_flutter/banner_\(viewId)", binaryMessenger: messeneger)
    }
    
    func view() -> UIView {
        return getOrSetupBannerAdView()
    }

    private func dispose() {
        adView?.removeFromSuperview()
        adView = nil
        channel.setMethodCallHandler(nil)
    }
    
    private func getOrSetupBannerAdView() -> GADBannerView {
        if let adView = adView {
            return adView
        }

        let adView = GADBannerView(adSize: adSize)
        self.adView = adView
        adView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        adView.frame = frame.width == 0 ? CGRect(x: 0, y: 0, width: 1, height: 1) : frame
        
        // Defaults to test Id's from: https://developers.google.com/admob/ios/banner
        adView.adUnitID = args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/2934735716"
        channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in
            switch flutterMethodCall.method {
            case "setListener":
                self?.adView?.delegate = self
            case "dispose":
                self?.dispose()
            default:
                flutterResult(FlutterMethodNotImplemented)
            }
        }

        let request = GADRequest()

        if ((args["nonPersonalizedAds"] as? Bool) == true) {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }

        adView.load(request)

        return adView
    }
    
    private var adSize: GADAdSize {
        guard let size = args["adSize"] as? [String: Any] else {
            assertionFailure("failed to get adSize")
            return GADAdSizeBanner // fallback value
        }

        if let name = size["name"] as? String {
            switch name {
            case "BANNER":
                return GADAdSizeBanner
            case "LARGE_BANNER":
                return GADAdSizeLargeBanner
            case "MEDIUM_RECTANGLE":
                return GADAdSizeMediumRectangle
            case "FULL_BANNER":
                return GADAdSizeFullBanner
            case "LEADERBOARD":
                return GADAdSizeLeaderboard
            case "FLUID":
                return GADAdSizeFluid
            case "ADAPTIVE_BANNER":
                return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
            default:
                assertionFailure("invalid ad size: \(name)")
                break
            }
        }

        let width = size["width"] as? Int ?? 0
        let height = size["height"] as? Int ?? 0
        return GADAdSize(size: CGSize(width: width, height: height), flags: 0)
    }
}

extension AdmobBanner : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        channel.invokeMethod("loaded", arguments: nil)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView: Failled to load banner view: \(error.localizedDescription)")
        channel.invokeMethod("failedToLoad", arguments: [
            "errorCode": error.localizedDescription,
            "error": error.localizedDescription
        ])
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("opened", arguments: nil)
    }
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        channel.invokeMethod("impression", arguments: nil)
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("closed", arguments: nil)
    }
}
