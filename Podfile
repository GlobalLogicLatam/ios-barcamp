source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
inhibit_all_warnings!


def common_pods
  use_frameworks!
  pod 'Kingfisher'
  pod 'TwitterKit'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKLoginKit'
  pod 'SwiftSpinner'
  pod 'ObjectMapper', '~> 2.2'
  pod 'ReachabilitySwift', '~> 3'
end


target 'BarCamp MDQ-Dev' do
  common_pods
end

target 'BarCamp MDQ-Prod' do
  common_pods
end
