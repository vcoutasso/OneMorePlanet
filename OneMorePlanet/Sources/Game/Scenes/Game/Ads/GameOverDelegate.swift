import Foundation

protocol GameOverDelegate: AnyObject {
    func gameOver()
    func loadInterstitialAd()
    func presentInterstitialAd()
    func presentLeaderboard()
}
