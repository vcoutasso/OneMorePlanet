import Foundation
import SpriteKit

class PlayerPreferences {
    static let shared = PlayerPreferences()

    private let shouldMuteKey = Strings.UserDefaults.ShouldMute.key

    private init() {
        if UserDefaults.standard.object(forKey: shouldMuteKey) == nil {
            setShouldMute(true)
        }
    }

    func setShouldMute(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: shouldMuteKey)
        UserDefaults.standard.synchronize()
    }

    func getShouldMute() -> Bool {
        UserDefaults.standard.bool(forKey: shouldMuteKey)
    }

    func toggleShouldMute() {
        let isMuted = getShouldMute()
        let shouldMute = isMuted ? false : true
        setShouldMute(shouldMute)
    }
}
