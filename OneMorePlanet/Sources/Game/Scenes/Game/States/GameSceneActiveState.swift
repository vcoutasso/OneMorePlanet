import AVFoundation
import GameplayKit

final class GameSceneActiveState: GKState {
    // MARK: Properties

    unowned let gameScene: GameScene

    lazy var backgroundMusic: AVAudioPlayer! = {
        let url = Bundle.main.url(forResource: Musics.spaceInvaderMp3.name, withExtension: Musics.spaceInvaderMp3.ext)!
        let player: AVAudioPlayer! = try? AVAudioPlayer(contentsOf: url)
        player.numberOfLoops = -1
        return player
    }()

    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        gameScene.isReallyPaused = false
        if !PlayerPreferences.shared.getShouldMute() {
            backgroundMusic.play()
        }
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        if !PlayerPreferences.shared.getShouldMute() {
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
