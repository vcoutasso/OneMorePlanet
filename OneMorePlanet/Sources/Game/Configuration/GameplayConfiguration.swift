import CoreGraphics
import Foundation

struct GameplayConfiguration {
    enum Planet {
        /// Distance between planets to trigger a spawn
        static let planetSpawnDistance: CGFloat = 200.0

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 48

        /// Scaling of planet nodes. Also used to calculate the scaled physicsBody
        static let renderComponentScale: CGFloat = 0.4

        /// The range that defines which positions are invalid for the very first planet
        /// This is needed to give a chance for the player to actually play the game every time instead of bumping into a planet as the only option
        static let invalidInitialRange: ClosedRange<CGFloat> = -0.2...0.2

        /// Initial range so the planets are not offscreen
        static let validInitialRange: ClosedRange<CGFloat> = -0.5...0.5

        /// Planets spawn between asteroid belts. This multiplier assures there is room for the planet to not overlap with the asteroidi belt
        static let asteroidPositionMultiplier: CGFloat = 0.6
    }

    enum Player {
        /// Maximum speed
        static let maxSpeed: CGFloat = 450.0

        /// Maximum amount of lives
        static let maximumLives: Int = 3

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 16

        /// Mass of the physics body
        static let physicsBodyMass: CGFloat = 0.05

        /// Linear damping of the physics body
        static let physicsBodyLinearDamping: CGFloat = 0.2

        /// Scaling of player node. Also used to calculate the scaled physicsBody
        static let renderComponentScale: CGFloat = 0.2

        /// Duration in seconds that the player  willremain invulnerable to collisions after a life is lost
        static let collisionInvincibilityDuration: TimeInterval = 3

        /// Duration in seconds that the player  willremain invulnerable to collisions after an extra life is awarded
        static let extraLifeInvincibilityDuration: TimeInterval = 5

        /// Duration of the fade actions of invincibility animation
        static let invincibilityBlinkingFadeDuration: TimeInterval = 0.25
    }

    enum AsteroidBelt {
        /// Speed
        static let speed: CGFloat = -50.0

        /// The screen width factor for the horizontal offset of asteroid belts
        static let positionScreenWidthMultiplier: CGFloat = 1
    }

    enum Star {
        /// Scaling of star nodes
        static let renderComponentScale: CGFloat = 1
    }

    enum Ads {
        /// Games the player has to play before seeing an interstitial ad
        static let interstitialAdInterval: Int = 4
    }
}
