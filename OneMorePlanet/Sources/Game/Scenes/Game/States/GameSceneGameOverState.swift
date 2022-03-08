import FirebaseAnalytics
import GameplayKit

final class GameSceneGameOverState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        Analytics.logEvent("game_over", parameters: nil)

        Task {
            await gameScene.submitScore()
        }

        gameScene.gameOverDelegate.gameOver()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneNewGameState.Type
    }
}
