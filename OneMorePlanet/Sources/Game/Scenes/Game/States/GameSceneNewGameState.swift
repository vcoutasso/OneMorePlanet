import FirebaseAnalytics
import GameplayKit

final class GameSceneNewGameState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from _: GKState?) {
        Analytics.logEvent("new_game", parameters: nil)
        gameScene.startNewGame()
    }

    override func isValidNextState(_: AnyClass) -> Bool {
        false
    }
}
