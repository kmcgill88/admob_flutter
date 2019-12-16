#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'admob_flutter'
  s.version          = '1.0.0-beta'
  s.swift_version    = '5.0'
  s.summary          = 'Admob plugin that shows banner ads using native platform views.'
  s.description      = <<-DESC
Admob plugin that shows banner ads using native platform views.
                       DESC
  s.homepage         = 'https://github.com/YoussefKababe/admob_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kevin McGill' => 'kevin@mcgilldevtech.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  # https://firebase.google.com/docs/ios/setup
  # https://github.com/CocoaPods/Specs/blob/master/Specs/0/3/5/Firebase/6.10.0/Firebase.podspec.json
  s.dependency 'Firebase/Analytics'
  s.dependency 'FirebaseAnalytics', '~> 6.1.3'
  s.dependency 'Firebase/AdMob'
  s.dependency 'Google-Mobile-Ads-SDK', '~> 7.50'

  s.ios.deployment_target = '8.0'
  s.static_framework = true
end

