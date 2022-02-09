import GameplayKit

final class GameSceneActiveState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameScenePauseState.Type ||
            stateClass is GameSceneGameOverState.Type ||
            stateClass is GameSceneOverlayState.Type
    }
}
