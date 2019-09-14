#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'admob_flutter'
  s.version          = '0.3.2'
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
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/AdMob'

  s.ios.deployment_target = '8.0'
  s.static_framework = true
end

