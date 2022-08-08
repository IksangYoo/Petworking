# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Petwork' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Petwork
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  end
 end
end
pod 'FirebaseAnalytics'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'Firebase/Storage'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Firestore'
pod 'Firebase/Database'
pod 'GoogleSignIn', '5.0.2'
pod 'YPImagePicker'
pod 'Kingfisher', '~> 7.0'
pod 'IQKeyboardManagerSwift'
end
