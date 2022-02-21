import AdSupport
import AppTrackingTransparency
import FBSDKCoreKit
import GameKit
import GoogleMobileAds
import SnapKit
import UIKit

final class MainMenuViewController: UIViewController {
    private lazy var playButton: RoundedButton = {
        let button = RoundedButton.createPurpleButton(title: Strings.MainMenu.PlayButton.title)
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tutorialButton: RoundedButton = {
        let button = RoundedButton.createPurpleButton(title: Strings.MainMenu.TutorialButton.title)
        button.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var leaderboardButton: RoundedButton = {
        let button = RoundedButton.createPurpleButton(title: Strings.MainMenu.LeaderboardButton.title)
        button.addTarget(self, action: #selector(scoreboardButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var alien: UIImageView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.alienCover))
        imageView.layer.zPosition = 0
        return imageView
    }()

    private lazy var stars: UIImageView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.starsCover))
        imageView.layer.zPosition = -1
        return imageView
    }()

    private lazy var planet: UIImageView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.planetCover))
        imageView.layer.zPosition = 0
        return imageView
    }()

    private lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        banner.translatesAutoresizingMaskIntoConstraints = false
        #if DEBUG
            banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
            banner.adUnitID = "ca-app-pub-3502520160790339/7000888003"
        #endif
        banner.rootViewController = self
        return banner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        requestTrackingPermission()
        gameCenterAuthentication()

        setupViews()
        setupHierarchy()
        setupConstraints()

        addBannerView()

        bannerView.load(GADRequest())
    }

    // MARK: Private methods

    private func gameCenterAuthentication() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, _ in
            if let viewController = viewController {
                self?.present(viewController, animated: true)
                return
            }
        }
    }

    private func setupViews() {
        view.backgroundColor = UIColor(asset: Assets.Colors.spaceBackground)
    }

    private func setupHierarchy() {
        view.addSubview(stars)
        view.addSubview(planet)
        view.addSubview(alien)
        view.addSubview(playButton)
        view.addSubview(leaderboardButton)
        view.addSubview(tutorialButton)
    }

    private func setupConstraints() {
        let constraints = [
            playButton.heightAnchor.constraint(equalToConstant: LayoutMetrics.buttonHeight),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: LayoutMetrics.buttonHorizontalPadding),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -LayoutMetrics.buttonHorizontalPadding),
            playButton.bottomAnchor.constraint(equalTo: tutorialButton.topAnchor,
                                               constant: LayoutMetrics.distanceBetweenButtons),

            tutorialButton.heightAnchor.constraint(equalToConstant: LayoutMetrics.buttonHeight),
            tutorialButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: LayoutMetrics.buttonHorizontalPadding),
            tutorialButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorialButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -LayoutMetrics.buttonHorizontalPadding),
            tutorialButton.bottomAnchor.constraint(equalTo: leaderboardButton.topAnchor,
                                                   constant: LayoutMetrics.distanceBetweenButtons),

            leaderboardButton.heightAnchor.constraint(equalToConstant: LayoutMetrics.buttonHeight),
            leaderboardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: LayoutMetrics.buttonHorizontalPadding),
            leaderboardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            leaderboardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -LayoutMetrics.buttonHorizontalPadding),
            leaderboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                      constant: LayoutMetrics.distanceFromBotton),
        ]

        NSLayoutConstraint.activate(constraints)

        alien.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(1.2)
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
    }

    private func addBannerView() {
        view.addSubview(bannerView)

        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    @objc private func playButtonTapped() {
        navigationController?.pushViewController(GameViewController(), animated: true)
    }

    @objc private func tutorialButtonTapped() {
        navigationController?.pushViewController(TutorialViewController(), animated: true)
    }

    @objc private func scoreboardButtonTapped() {
        let leaderboardID = "AllTimeBests"
        let gcVC = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gcVC.gameCenterDelegate = self
        GKAccessPoint.shared.isActive = false

        present(gcVC, animated: true)
    }

    private func requestTrackingPermission() {
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    Settings.shared.isAdvertiserTrackingEnabled = true
                    Settings.shared.isAutoLogAppEventsEnabled = true
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                    print("Authorized")
                case .denied:
                    Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAutoLogAppEventsEnabled = false
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            })
        }
    }

    // MARK: Layout Metrics

    private enum LayoutMetrics {
        static let buttonHeight: CGFloat = 55
        static let buttonFontSize: CGFloat = 30
        static let buttonHorizontalPadding: CGFloat = 80
        static let buttonVerticalPadding: CGFloat = -60
        static let distanceBetweenButtons: CGFloat = -25
        static let distanceFromBotton: CGFloat = -65
    }
}

extension MainMenuViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
