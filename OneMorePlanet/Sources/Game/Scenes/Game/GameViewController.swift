import AVFoundation
import FBSDKCoreKit
import FirebaseAnalytics
import GameKit
import GameplayKit
import GoogleMobileAds
import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    // MARK: Properties

    #if DEBUG
        private let interstitialID: String = "ca-app-pub-3940256099942544/4411468910"
        private let rewardedID: String = "ca-app-pub-3940256099942544/1712485313"
    #else
        private let interstitialID: String = "ca-app-pub-3502520160790339/8584420650"
        private let rewardedID: String = "ca-app-pub-3502520160790339/7067835606"
    #endif

    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?

    // FIXME: Come on we can do better than this
    private var gameScene: GameScene {
        ((view as? SKView)!.scene as? GameScene)!
    }

    private var gamesPlayed: Int = 0

    var _isPresentingInterstitial = false
    var _isPresentingRewarded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = view as? SKView else { return }

        let scene = GameScene(size: view.frame.size, delegate: self)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        view.ignoresSiblingOrder = true

        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif

        loadInterstitialAd()
        loadRewardedAd()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // FIXME: This should probably be somewhere else
        if !isPresentingRewarded && !isPresentingInterstitial {
            Task {
                await gameScene.submitScore()
            }
        }
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

// MARK: - InterstitialAdDelegate extension

extension GameViewController: GameOverDelegate {
    var isPresentingInterstitial: Bool {
        get {
            _isPresentingInterstitial
        }
        set {
            _isPresentingInterstitial = newValue
        }
    }

    var isPresentingRewarded: Bool {
        get {
            _isPresentingRewarded
        }
        set {
            _isPresentingRewarded = newValue
        }
    }

    func gameOver() {
        gamesPlayed += 1
        if gamesPlayed % GameplayConfiguration.Ads.interstitialAdInterval == 0 {
            presentInterstitialAd()
        } else {
            gameScene.gameOverHandlingDidFinish()
        }
    }

    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialID,
                               request: request) { [weak self] loadedAd, error in
            guard error == nil else {
                print("Failed to load interstitial ad with error: \(error!.localizedDescription)")
                return
            }

            self?.interstitialAd = loadedAd
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func presentInterstitialAd() {
        isPresentingInterstitial = true
        BackgroundMusicPlayer.shared.mute()
        if let interstitialAdView = interstitialAd {
            Analytics.logEvent("interstitial_success", parameters: nil)
            interstitialAdView.present(fromRootViewController: self)
        } else {
            Analytics.logEvent("interstitial_fail", parameters: nil)
            gameScene.gameOverHandlingDidFinish()
        }
    }

    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: rewardedID, request: request) { [weak self] loadedAd, error in
            guard error == nil else {
                print("Failed to load rewarded ad with error: \(error!.localizedDescription)")
                return
            }

            self?.rewardedAd = loadedAd
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func presentRewardedAd() {
        isPresentingRewarded = true
        BackgroundMusicPlayer.shared.mute()
        if let rewardedAd = rewardedAd {
            rewardedAd.present(fromRootViewController: self) {
                Analytics.logEvent("rewarded_success", parameters: nil)
            }
        } else {
            Analytics.logEvent("rewarded_fail", parameters: nil)
            isPresentingRewarded = false
            gameScene.gameOverHandlingDidFinish()
        }
    }

    func presentLeaderboard() {
        let leaderboardID = "AllTimeBests"
        GKAccessPoint.shared.isActive = false
        let gcVC = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gcVC.gameCenterDelegate = self
        present(gcVC, animated: true)
    }

    func presentLimitExceededAlert() {
        let alert = UIAlertController(title: "Exceeded reward limit", message: "Maximum of one extra life per match",
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            self?.gameScene.gameOverHandlingDidFinish()
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}

// MARK: - GADFullScreenContentDelegate extension

extension GameViewController: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("ad:didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        gameScene.gameOverHandlingDidFinish()
        loadAds()
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        Analytics.logEvent("interstitial_clicked", parameters: nil)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        BackgroundMusicPlayer.shared.unmute()
        if isPresentingInterstitial {
            gameScene.gameOverHandlingDidFinish()
        } else if isPresentingRewarded {
            gameScene.continueWithExtraLife()
        }
        loadAds()
        print("Did dismiss ad")
    }

    private func loadAds() {
        if isPresentingInterstitial {
            loadInterstitialAd()
            _isPresentingInterstitial = false
        } else if isPresentingRewarded {
            loadRewardedAd()
            _isPresentingRewarded = false
        }
    }
}

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
