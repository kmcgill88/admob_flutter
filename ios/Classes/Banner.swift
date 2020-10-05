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

class Banner : NSObject, FlutterPlatformView {

    private let channel: FlutterMethodChannel
    private let messeneger: FlutterBinaryMessenger
    private let frame: CGRect
    private let viewId: Int64
    private let args: [String: Any]

    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger, viewName: String) {
        self.args = args
        self.messeneger = messeneger
        self.frame = frame
        self.viewId = viewId
        channel = FlutterMethodChannel(name: "\(viewName)_\(viewId)", binaryMessenger: messeneger)
    }
    
    func view() -> UIView {
        return getOrSetupBannerAdView()
    }

    func dispose() {
        channel.setMethodCallHandler(nil)
    }
    
    func getOrSetupBannerAdView() -> GADBannerView {
        // Override me
        return GADBannerView()
    }
    func configureRequest(request:GADRequest){
        if ( (args["nonPersonalizedAds"] as? Bool) == true) {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        let contentURL = args["contentUrl"] as? String ?? ""
        if(!contentURL.isEmpty){
            request.contentURL = contentURL
        }
    }
    func configureAdView(adView: GADBannerView, context:Banner){
        adView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        adView.frame = frame.width == 0 ? CGRect(x: 0, y: 0, width: 1, height: 1) : frame
        adView.adUnitID = getAdUnit()
        
        channel.setMethodCallHandler { (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in
            switch flutterMethodCall.method {
            case "setListener":
                adView.delegate = context
            case "dispose":
                context.dispose()
            default:
                flutterResult(FlutterMethodNotImplemented)
            }
        }
        
    }
    
    private var adSize: GADAdSize {
        guard let size = args["adSize"] as? [String: Any] else {
            assertionFailure("failed to get adSize")
            return kGADAdSizeBanner // fallback value
        }

        if let name = size["name"] as? String {
            switch name {
            case "BANNER":
                return kGADAdSizeBanner
            case "LARGE_BANNER":
                return kGADAdSizeLargeBanner
            case "MEDIUM_RECTANGLE":
                return kGADAdSizeMediumRectangle
            case "FULL_BANNER":
                return kGADAdSizeFullBanner
            case "LEADERBOARD":
                return kGADAdSizeLeaderboard
            case "PIXEL":
                return GADAdSizeFromCGSize(CGSize(width: 1.0, height: 1.0))
            case "SMART_BANNER":
                // TODO: Do we need Landscape too?
                return kGADAdSizeSmartBannerPortrait
            case "ADAPTIVE_BANNER":
                return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
            default:
                assertionFailure("invalid adSize.name")
                break
            }
        }
        
        let width = size["width"] as? Int ?? 0
        let height = size["height"] as? Int ?? 0
        return GADAdSize(size: CGSize(width: width, height: height), flags: 0)
    }
    
    func getAdSize() -> GADAdSize{
        return adSize
    }
    func getAdUnit() -> String {
        // Defaults to test Id's from: https://developers.google.com/admob/ios/banner
        return args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/2934735716"
    }
    func getTargetInfo() -> [String: Any] {
        var dict = [String: Any]()
        if(args["targetInfo"] != nil){
            let target = args["targetInfo"] as! [String:Any]
            for (key, value) in target {
                dict[key] = value
            }
        }
        return dict
    }
    func getChannel() -> FlutterMethodChannel {
        return channel
    }
    
}

extension Banner : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {        
        channel.invokeMethod("loaded", arguments: nil)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("failedToLoad", arguments: [
            "errorCode": error.code,
            "error": error.localizedDescription
        ])
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("clicked", arguments: nil)
        channel.invokeMethod("opened", arguments: nil)
    }
    
    // TODO: not sure this exists on iOS.
    // channel.invokeMethod("impression", null)
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("closed", arguments: nil)
    }
}
