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

import Flutter
import UIKit
import GoogleMobileAds

public class SwiftAdmobFlutterPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAdmobFlutterPlugin()
    let defaultChannel = FlutterMethodChannel(name: "admob_flutter", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: defaultChannel)

    let interstitialChannel = FlutterMethodChannel(name: "admob_flutter/interstitial", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: interstitialChannel)

    let rewardChannel = FlutterMethodChannel(name: "admob_flutter/reward", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: rewardChannel)

    registrar.register(
        AdmobBannerFactory(messeneger: registrar.messenger()),
        withId: "admob_flutter/banner"
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
        GADMobileAds.sharedInstance().start { (initializationStatus: GADInitializationStatus) in
            print("initializationStatus:")
            print(initializationStatus)
        }
        break
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
        break
    default:
        result("success")
//        result(FlutterMethodNotImplemented)
    }
  }
}
