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

class AdmobBanner : Banner {
    private var adView: GADBannerView?
    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        super.init(frame: frame, viewId: viewId, args: args, messeneger: messeneger,viewName: "admob_flutter/banner")
    }
    override func getOrSetupBannerAdView() -> GADBannerView {
        if let adView = adView {
            return adView
        }
        let adView = GADBannerView(adSize: getAdSize())
        self.adView = adView
        configureAdView(adView: adView, context: self)
        let request = GADRequest()
        configureRequest(request:request)
        adView.load(request)
        return adView
    }
    override func dispose() {
        adView?.removeFromSuperview()
        adView = nil
        super.dispose()
    }
    
}
