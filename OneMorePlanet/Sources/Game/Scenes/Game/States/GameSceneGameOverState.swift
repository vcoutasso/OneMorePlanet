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

        Task {
            await gameScene.submitScore()
        }
        gameScene.isReallyPaused = true
        gameScene.gameOverDelegate.gameOver()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneNewGameState.Type
    }
}
