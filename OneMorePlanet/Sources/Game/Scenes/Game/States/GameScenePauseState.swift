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
        gameScene.resumeLabel.isHidden = false
        gameScene.blurEffect.shouldEnableEffects = true
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        gameScene.isReallyPaused = false
        gameScene.resumeLabel.isHidden = true
        gameScene.blurEffect.shouldEnableEffects = false
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneActiveState.Type
    }
}
