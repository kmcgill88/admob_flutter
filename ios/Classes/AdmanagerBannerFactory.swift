//
//  AdmanagerBannerFactory.swift
//  admob_flutter
//
//  Created by Alan Trope on 02/10/2020.
//

import Flutter
import Foundation

class AdmanagerBannerFactory : NSObject, FlutterPlatformViewFactory {
    let messeneger: FlutterBinaryMessenger

    init(messeneger: FlutterBinaryMessenger) {
        self.messeneger = messeneger
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AdmanagerBanner(
            frame: frame,
            viewId: viewId,
            args: args as? [String : Any] ?? [:],
            messeneger: messeneger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
