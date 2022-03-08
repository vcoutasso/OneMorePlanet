import Foundation
import SpriteKit

final class PlayerPreferences {
    private typealias MuteButtonNamespace = Strings.MainMenu.MuteButton

    // MARK: Singletion

    static let shared = PlayerPreferences()

    // MARK: Properties

    private let shouldMuteKey = Strings.UserDefaults.ShouldMute.key

    var muteButtonIconName: String {
        getShouldMute() ? MuteButtonNamespace.mutedIcon : MuteButtonNamespace.unmutedIcon
    }

    // MARK: Initialization

    private init() {
        if UserDefaults.standard.object(forKey: shouldMuteKey) == nil {
            setShouldMute(true)
        }
    }

    // MARK: Public methods

    func getShouldMute() -> Bool {
        UserDefaults.standard.bool(forKey: shouldMuteKey)
    }

    func toggleShouldMute() -> Bool {
        let isMuted = getShouldMute()
        let newState = !isMuted
        setShouldMute(newState)

        return newState
    }

    // MARK: Convenience

    private func setShouldMute(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: shouldMuteKey)
        UserDefaults.standard.synchronize()
    }
}
