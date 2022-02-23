import CoreGraphics

struct GameplayConfiguration {
    enum Planet {
        /// Distance between planets to trigger a spawn
        static let planetSpawnDistance: CGFloat = 200.0

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 12

        /// Scaling of planet nodes. Also used to calculate the scaled physicsBody
        static let renderComponentScale: CGFloat = 1.5

        /// The range that defines which positions are invalid for the very first planet
        /// This is needed to give a chance for the player to actually play the game every time instead of bumping into a planet as the only option
        static let invalidInitialRange: ClosedRange<CGFloat> = -0.2...0.2

        /// Initial range so the planets are not offscreen
        static let validInitialRange: ClosedRange<CGFloat> = -0.5...0.5

        /// Planets spawn between asteroid belts. This multiplier assures there is room for the planet to not overlap with the asteroidi belt
        static let asteroidPositionMultiplier: CGFloat = 0.7
    }

    enum Player {
        /// Maximum speed
        static let maxSpeed: CGFloat = 350.0

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 16

        /// Mass of the physics body
        static let physicsBodyMass: CGFloat = 0.05

        /// Linear damping of the physics body
        static let physicsBodyLinearDamping: CGFloat = 0.05

        /// Scaling of planet nodes. Also used to calculate the scaled physicsBody
        static let renderComponentScale: CGFloat = 0.2
    }

    enum AsteroidBelt {
        /// Speed
        static let speed: CGFloat = -50.0

        /// The screen width factor for the horizontal offset of asteroid belts
        static let positionScreenWidthMultiplier: CGFloat = 0.85
    }

    enum Ads {
        /// Games the player has to play before seeing an interstitial ad
        static let interstitialAdInterval: Int = 4
    }
}
