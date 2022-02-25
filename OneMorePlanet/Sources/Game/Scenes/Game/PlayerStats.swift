import Foundation
import SpriteKit

class PlayerStats {
    static let shared = PlayerStats()
    
    static let kBackgroundMusicName = "space-invader"
    static let kBackgroundMusicExtension = "mp3"
    static let kSoundState = "kSoundState"
    
    private init() {
        setSounds(true)
    }
    
    func setSounds(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: "kSoundState")
        UserDefaults.standard.synchronize()
    }
    
    func getSound() -> Bool {
        return UserDefaults.standard.bool(forKey: PlayerStats.kSoundState)
    }
}
