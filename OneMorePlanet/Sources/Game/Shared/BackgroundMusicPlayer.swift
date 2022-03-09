import AVFAudio

final class BackgroundMusicPlayer {
    // MARK: Singleton

    static let shared = BackgroundMusicPlayer()

    // MARK: Properties

    private lazy var player: AVAudioPlayer! = {
        let url = Musics.spaceInvaderMp3.url
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1

        return player
    }()

    private var isPlaying: Bool {
        player.isPlaying
    }

    private var shouldPlay: Bool {
        !PlayerPreferences.shared.getShouldMute()
    }

    // MARK: Initialization

    private init() {}

    // MARK: Public methods

    func start() {
        if shouldPlay {
            BackgroundMusicPlayer.shared.play()
        }
    }

    func changeVolume(shouldMute: Bool) {
        shouldMute ? mute() : unmute()
    }

    private func play() {
        player.play()
    }

    private func stop() {
        player.stop()
    }

    func mute() {
        player.volume = 0
    }

    func unmute() {
        if shouldPlay {
            if !isPlaying { play() }

            player.volume = 1
        }
    }
}
