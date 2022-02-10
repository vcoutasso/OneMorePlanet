import GameplayKit

final class GameSceneOverlayState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneActiveState.Type
    }
}
