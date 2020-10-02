#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'admob_flutter'
  s.version          = '1.0.0'
  s.swift_version    = '5.0'
  s.summary          = 'Admob plugin that shows banner ads using native platform views.'
  s.description      = <<-DESC
Admob plugin that shows banner ads using native platform views.
                       DESC
  s.homepage         = 'https://github.com/kmcgill88/admob_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kevin McGill' => 'kevin@mcgilldevtech.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  # https://firebase.google.com/docs/ios/setup
  s.dependency 'Firebase/Analytics', '~> 6.26.0'
  s.dependency 'Firebase/AdMob'
  s.dependency 'Google-Mobile-Ads-SDK', '~> 7.64'
  s.ios.deployment_target = '9.0'
  s.static_framework = true
end

