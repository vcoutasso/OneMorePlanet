platform :ios, '14.0'
use_frameworks!
inhibit_all_warnings!

target 'OneMorePlanet' do
  pod 'Google-Mobile-Ads-SDK'

  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'

  pod 'FBSDKCoreKit'

  pod 'SwiftFormat/CLI'
  pod 'SwiftLint'
  pod 'SwiftGen'
  pod 'SnapKit'

  pod 'RealmSwift'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end

    # This removes the warning about swift conversion, hopefuly forever!
    installer.pods_project.root_object.attributes['LastSwiftMigration'] = 9999
    installer.pods_project.root_object.attributes['LastSwiftUpdateCheck'] = 9999
    installer.pods_project.root_object.attributes['LastUpgradeCheck'] = 9999
end
