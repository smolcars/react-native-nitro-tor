require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "ReactNativeNitroTor"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported, :osx => '14.0' }
  s.source       = { :git => "https://github.com/niteshbalusu11/react-native-nitro-tor.git", :tag => "v#{s.version}" }

  s.source_files = ["ios/**/*.{m,mm,cc,cpp}", "cpp/**/*.cpp"]
  s.ios.vendored_frameworks = "ios/framework/libreactnativenitrotor.xcframework"
  s.osx.vendored_frameworks = "macos/framework/libreactnativenitrotor.xcframework"
  s.osx.frameworks = 'Security', 'SystemConfiguration', 'CoreFoundation'
  s.osx.libraries = 'resolv', 'iconv'
  s.pod_target_xcconfig = {
    "HEADER_SEARCH_PATHS" => [
      '"${PODS_TARGET_SRCROOT}/cpp"',
      '"${PODS_TARGET_SRCROOT}/ios/include"',
    ].join(' '),
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20",
  }

  install_modules_dependencies(s)
end
