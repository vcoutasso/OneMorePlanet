import CoreGraphics

struct GameplayConfiguration {
    enum Planet {
        /// Distance between planets to trigger a spawn
        static let planetSpawnDistance: CGFloat = 400.0

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 12
    }

    enum Player {
        /// Maximum speed
        static let maxSpeed: CGFloat = 350.0

        /// The radius of  the physics body of the node
        static let physicsBodyCircleRadius: CGFloat = 12

        /// Mass of the physics body
        static let physicsBodyMass: CGFloat = 0.05

        /// Linear damping of the physics body
        static let physicsBodyLinearDamping: CGFloat = 0.05
    }
}
