import GameplayKit

final class PlanetMovementBehavior: GKBehavior {
    // MARK: Initialization

    init(points: [SIMD2<Float>]) {
        super.init()

        let path = GKPath(points: points, radius: GameplayConfiguration.Planet.pathToleranceRadius, cyclical: false)
        let goal = GKGoal(toFollow: path, maxPredictionTime: GameplayConfiguration.Planet.maxPredictionTimeWhenFollowingPath, forward: true)

        setWeight(1.0, for: goal)
    }
}
