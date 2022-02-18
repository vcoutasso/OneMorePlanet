import AppTrackingTransparency
import FBSDKCoreKit
import Firebase
import GoogleMobileAds
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 14, *) {
            listenForDidBecomeActiveNotification()
        }

        GADMobileAds.sharedInstance().start(completionHandler: nil)

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        FirebaseApp.configure()

        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 14, *)
    private func listenForDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requestTrackingPermission),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @available(iOS 14, *)
    @objc private func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            switch status {
            case .authorized:
                Settings.shared.isAdvertiserTrackingEnabled = true
                Settings.shared.isAutoLogAppEventsEnabled = true
                Settings.shared.isAdvertiserIDCollectionEnabled = true

                Analytics.setUserProperty("true", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                Analytics.setAnalyticsCollectionEnabled(true)
            case .denied, .notDetermined, .restricted:
                Settings.shared.isAdvertiserTrackingEnabled = false
                Settings.shared.isAutoLogAppEventsEnabled = false
                Settings.shared.isAdvertiserIDCollectionEnabled = false

                Analytics.setUserProperty("false", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                Analytics.setAnalyticsCollectionEnabled(false)
            @unknown default:
                break
            }
        })
    }
}
