import GameplayKit
import AVFoundation

final class GameSceneActiveState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene
    
    lazy var backgroundMusic: AVAudioPlayer! = {
        guard let url = Bundle.main.url(forResource: PlayerStats.kBackgroundMusicName, withExtension: PlayerStats.kBackgroundMusicExtension) else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        gameScene.isReallyPaused = false
        if PlayerStats.shared.getSound() {
            backgroundMusic.play()
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        if PlayerStats.shared.getSound() {
            backgroundMusic.stop()
        } 
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is GameScenePauseState.Type ||
            stateClass is GameSceneNewGameState.Type ||
            stateClass is GameSceneGameOverState.Type ||
            stateClass is GameSceneOverlayState.Type
    }
}
