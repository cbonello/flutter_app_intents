Pod::Spec.new do |s|
  s.name             = 'flutter_app_intents'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for integrating Apple App Intents.'
  s.description      = <<-DESC
A Flutter plugin that provides a bridge to Apple's App Intents framework,
enabling integration with Siri, Shortcuts, and other system experiences.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages/tree/main/packages/flutter_app_intents'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end