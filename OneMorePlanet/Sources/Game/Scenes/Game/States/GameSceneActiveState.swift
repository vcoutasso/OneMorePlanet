import AVFoundation
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

        gameScene.isReallyPaused = false
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameScenePauseState.Type ||
            stateClass is GameSceneNewGameState.Type ||
            stateClass is GameSceneGameOverState.Type ||
            stateClass is GameSceneOverlayState.Type
    }
}
