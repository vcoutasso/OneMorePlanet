import GameKit

final class Planet: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Planet must have a RenderComponent")
        }
        return renderComponent
    }

    var physicsComponent: PhysicsComponent {
        guard let physicsComponent = component(ofType: PhysicsComponent.self) else {
            fatalError("A Planet must have a PhysicsComponent")
        }
        return physicsComponent
    }

    var gravitationalComponent: GravitionalComponent {
        guard let gravitationalComponent = component(ofType: GravitionalComponent.self) else {
            fatalError("A Planet must have an GravitationalComponent")
        }
        return gravitationalComponent
    }

    // MARK: - Initialization

    init(imageName: String, initialPosition _: SIMD2<Float>) {
        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: imageName))
        renderComponent.node.setScale(GameplayConfiguration.Planet.renderComponentScale)
        addComponent(renderComponent)

        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Planet.physicsBodyCircleRadius *
            GameplayConfiguration.Planet.renderComponentScale)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: ColliderType.Obstacle)
        addComponent(physicsComponent)

        let gravitationalComponent = GravitionalComponent()
        addComponent(gravitationalComponent)

        renderComponent.node.physicsBody = physicsBody
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
