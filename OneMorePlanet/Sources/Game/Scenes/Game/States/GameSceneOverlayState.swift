import GameplayKit

final class GameSceneOverlayState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        gameScene.isReallyPaused = true
        gameScene.interstitialDelegate.presentInterstitialAd()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneGameOverState.Type
    }
}
