import Foundation

struct GameplayConfiguration {
    struct Planet {
        /// The tolerance radius of the planet's path
        static let pathToleranceRadius: Float = 0.0

        /// Determines how far ahead of time the agent will predict its own movement. We are not concerning with the planet stopping
        /// since it disappears offscreen, so this value can be very low
        static let maxPredictionTimeWhenFollowingPath: TimeInterval = 0.0

        /// How often planets spawn
        static let spawnInterval: TimeInterval = 1

        /// Maximum acceleration
        static let maxAcceleration: Float = 0.0

        /// Maximum speed
        static let maxSpeed: Float = -300.0
    }

    struct Player {
        /// The tolerance radius of the planet's path
        static let pathToleranceRadius: Float = 0.0

        /// Determines how far ahead of time the agent will predict its own movement. We are not concerning with the planet stopping
        /// since it disappears offscreen, so this value can be very low
        static let maxPredictionTimeWhenFollowingPath: TimeInterval = 0.0

        /// Maximum acceleration
        static let maxAcceleration: Float = 0.0

        /// Maximum speed
        static let maxSpeed: Float = -300.0
    }
}
