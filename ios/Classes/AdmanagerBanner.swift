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
    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        super.init(frame: frame, viewId: viewId, args: args, messeneger: messeneger,viewName: "admob_flutter/admanager_banner")
    }
}
