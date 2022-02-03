import GameKit

final class Planet: GKEntity {
    // MARK: - Initialization

    init(imageName: String, initialPosition: SIMD2<Float>, targetPosition: SIMD2<Float>) {
        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: imageName))
        addComponent(renderComponent)

        let movementBehavior = PlanetMovementBehavior(points: [initialPosition, targetPosition])
        let movementComponent = MovementComponent(behavior: movementBehavior)
        movementComponent.maxAcceleration = GameplayConfiguration.Planet.maxAcceleration
        movementComponent.maxSpeed = GameplayConfiguration.Planet.maxSpeed
        movementComponent.speed = GameplayConfiguration.Planet.maxSpeed
        addComponent(movementComponent)

        let gravitationalComponent = GravitionalComponent()
        addComponent(gravitationalComponent)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
