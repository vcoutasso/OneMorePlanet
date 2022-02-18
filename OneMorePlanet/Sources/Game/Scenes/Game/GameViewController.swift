import FBSDKCoreKit
import GameplayKit
import GoogleMobileAds
import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private var interstitialAdView: GADInterstitialAd?

    #if DEBUG
        private let interstitialID: String = "ca-app-pub-3940256099942544/4411468910"
    #else
        private let interstitialID: String = "ca-app-pub-3502520160790339/8584420650"
    #endif

    // FIXME: Come on we can do better than this
    private var gameScene: GameScene {
        ((view as? SKView)!.scene as? GameScene)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = view as? SKView else { return }

        let scene = GameScene(size: self.view.frame.size, delegate: self)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        view.ignoresSiblingOrder = true

        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif

        loadInterstitialAd()
    }

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - GADFullScreenContentDelegate extension

extension GameViewController: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadInterstitialAd()
        gameScene.interstitialAdDidDismiss()
    }

    /// Tells the delegate that the ad presented full screen content.
    private func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitialAd()
        gameScene.interstitialAdDidDismiss()
    }
}

// MARK: - InterstitialAdDelegate extension

extension GameViewController: InterstitialAdDelegate {
    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialID,
                               request: request) { [weak self] loadedAd, error in
            guard error == nil else {
                print("Failed to load interstitial ad with error: \(error!.localizedDescription)")
                return
            }

            self?.interstitialAdView = loadedAd
            self?.interstitialAdView?.fullScreenContentDelegate = self
        }
    }

    func presentInterstitialAd() {
        interstitialAdView?.present(fromRootViewController: self)
    }
}
