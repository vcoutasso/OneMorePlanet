import GameplayKit

final class GameSceneGameOverState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from _: GKState?) {
        gameScene.startNewGame()
    }

    override func isValidNextState(_: AnyClass) -> Bool {
        false
    }
}
