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

    var isPlaying: Bool {
        player.isPlaying
    }

    // MARK: Initialization

    private init() {}

    // MARK: Public methods

    func start() {
        if !PlayerPreferences.shared.getShouldMute() {
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

    private func mute() {
        player.volume = 0
    }

    private func unmute() {
        if !isPlaying { play() }

        player.volume = 1
    }
}
