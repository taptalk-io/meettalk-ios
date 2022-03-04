source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
inhibit_all_warnings!
use_modular_headers!

def meettalk_pods
  pod 'TapTalk'
  pod 'AFNetworking', '~> 4.0.0', :modular_headers => true
  pod 'JSONModel', '~> 1.1', :modular_headers => true
  pod 'PodAsset'
  pod 'SDWebImage'
end

target 'MeetTalk' do

  # Pods for MeetTalk
  meettalk_pods

  target 'MeetTalkTests' do
    # Pods for testing
  end

end
