//
//  AdmanagerBanner.swift
//  admob_flutter
//
//  Created by Alan Trope on 02/10/2020.
//
import Flutter
import Foundation
import GoogleMobileAds

class AdmanagerBanner : Banner {
    private var adView: DFPBannerView?
    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        super.init(frame: frame, viewId: viewId, args: args, messeneger: messeneger,viewName: "admob_flutter/admanager_banner")
    }
    override func getOrSetupBannerAdView() -> DFPBannerView {
        if let adView = adView {
            return adView
        }
        let adView = DFPBannerView(adSize: getAdSize())
        self.adView = adView
        configureAdView(adView: adView, context: self)
        let request = DFPRequest()
        configureRequest(request:request)
        request.customTargeting = getTargetInfo()
        adView.appEventDelegate = self
        adView.load(request)
        
        return adView
    }
    
    override func dispose() {
        adView?.removeFromSuperview()
        adView = nil
        super.dispose()
    }
}
extension Banner : GADAppEventDelegate {
    public func adView(_ banner: GADBannerView,
                       didReceiveAppEvent name: String, withInfo info: String?){
        getChannel().invokeMethod("appEvent", arguments: ["name":name, "data": info ?? "{}"])
    }
}
