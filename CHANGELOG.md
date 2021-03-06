## [1.0.1] - 2020/10/27
- Added testAdUnitId getter for Banner, Interstitial and Reward ads. PR[227](https://github.com/kmcgill88/admob_flutter/pull/227). Thank you [DoctorJohn](https://github.com/DoctorJohn)!
- Fixes typo in README.md PR[224](https://github.com/kmcgill88/admob_flutter/pull/224). Thank you [Skyost](https://github.com/Skyost)!

## [1.0.0] - 2020/09/21
- Added support for non-personalized ads. PR [215](https://github.com/kmcgill88/admob_flutter/pull/215). Thank you [Skyost](https://github.com/Skyost)!
- **REQUIRES Xcode 12**

## [1.0.0-beta.7] - 2020/09/05
- Resolve iOS 14 [Dependency issue](https://github.com/kmcgill88/admob_flutter/issues/214).

## [1.0.0-beta.6] - 2020/08/31
- Add [iOS 14 Support](https://github.com/kmcgill88/admob_flutter/issues/208). Thank you [Skyost](https://github.com/Skyost)!
    - Bump iOS min version to iOS 9
    - iOS REQUIRES Xcode 12+ to build for iOS 14
    - Update Bitrise build machine to Xcode 12.0.x, on macOS 10.15.5 (Catalina); Flutter 1.20.2
- Added some extension banner ad recipes
- Added page navigation to example app.

## [1.0.0-beta.5] - 2020/06/20
- Fixed [183](https://github.com/kmcgill88/admob_flutter/issues/183) iOS Reward Ad consecutive loads

## [1.0.0-beta.4] - 2020/06/02
- Removed some dead code from `AdmobRewardPlugin.swift`
- Reverted: Explicitly `dispose` Banners via `AdmobBannerController`
- More FAQ's added to README

## [1.0.0-beta.3] - 2020/05/21
- Add support for `testDeviceIds`
- Add some FAQ's to README
- Explicitly `dispose` Banners via `AdmobBannerController`
- Update iOS and Android API versions
- Update iOS rewards to use new api
- Update Bitrise build machine to Xcode 11.5.x, on macOS 10.15.4 (Catalina); Flutter 1.17.1

## [1.0.0-beta.2] - 2020/04/03
- Add Adaptive banner support.
- Now prevents ads from being reloaded on setState.

## [1.0.0-beta] - 2019/12/15
- Update Android dependencies
- Update iOS Podfile for Flutter 1.12.13+hotfix.5
- Update example for Flutter to 1.12.13+hotfix.5
- Update Bitrise build machine to Xcode 11.3.x, on macOS 10.14.6 (Mojave)
- Set min Flutter version to 1.10.x
- Set plug-in platforms to Android and iOS

## [0.3.4] - 2019/10/25
- Pin iOS dependencies
- Add bitrise build
- Add analysis_options.yaml

## [0.3.3] - 2019/09/25
- iOS 13.0 fixes

## [0.3.2] - 2019/09/11
- iOS Interstitial crash fix if `didFailToReceiveAdWithError`

## [0.3.1] - 2019/05/31
- iOS Banner crash fix

## [0.3.0] - 2019/05/28
- Add iOS support!

## [0.2.0] - 2019/04/04
- Update to AndroidX.
> **Note:** This is a breaking change on Android!

## [0.1.2] - Dec 10
- Release first version
