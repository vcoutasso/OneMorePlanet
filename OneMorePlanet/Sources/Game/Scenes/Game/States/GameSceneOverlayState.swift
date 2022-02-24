import GameplayKit
import SnapKit

final class GameSceneOverlayState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    private(set) lazy var gameOverOverlay: GameOverOverlayView = {
        let overlay = GameOverOverlayView(score: gameScene.score.value, bestScore: gameScene.currentBest.value)
        overlay.extraLifeButton.addTarget(gameScene, action: #selector(gameScene.extraLifeReward), for: .touchUpInside)
        overlay.playAgainButton.addTarget(gameScene, action: #selector(gameScene.playAgain), for: .touchUpInside)
        overlay.leaderboardButton.addTarget(gameScene, action: #selector(gameScene.leaderboard), for: .touchUpInside)

        return overlay
    }()

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        gameScene.isReallyPaused = true
        setupOverlayMenu()
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        gameOverOverlay.removeFromSuperview()

        if nextState is GameSceneActiveState {
            gameScene.resetPlayer()
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameSceneActiveState.Type ||
            stateClass is GameSceneGameOverState.Type
    }

    private func setupOverlayMenu() {
        gameScene.view?.addSubview(gameOverOverlay)

        gameOverOverlay.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.center.equalToSuperview()
        }
    }
}
