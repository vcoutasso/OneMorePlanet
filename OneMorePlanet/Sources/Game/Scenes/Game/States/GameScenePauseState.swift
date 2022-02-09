import GameplayKit

final class GameScenePauseState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        gameScene.isReallyPaused = true
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        gameScene.isReallyPaused = false
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneActiveState.Type
    }
}
