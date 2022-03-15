source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
inhibit_all_warnings!

def meettalk_pods
  pod 'TapTalk'
  pod 'AFNetworking', '~> 4.0.0', :modular_headers => true
  pod 'JSONModel', '~> 1.1', :modular_headers => true
  pod 'PodAsset'
  pod 'SDWebImage'
  pod 'JitsiMeetSDK', '3.7.0'
end

target 'MeetTalk' do

  # Pods for MeetTalk
  meettalk_pods

  target 'MeetTalkTests' do
    # Pods for testing
  end

end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['ENABLE_BITCODE'] = 'NO'
#    end
#  end
#end