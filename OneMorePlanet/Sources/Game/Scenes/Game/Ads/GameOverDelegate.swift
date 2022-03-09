import Foundation

protocol GameOverDelegate: AnyObject {
    var isPresentingInterstitial: Bool { get set }
    var isPresentingRewarded: Bool { get set }
    var shouldGetReward: Bool { get set }

    func gameOver()
    func loadInterstitialAd()
    func presentInterstitialAd()
    func loadRewardedAd()
    func presentRewardedAd()
    func presentLeaderboard()
    func presentLimitExceededAlert()
}
