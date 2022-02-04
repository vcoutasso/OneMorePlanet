import GameplayKit

final class AsteroidBelt: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("An AsteroidBelt must have a RenderComponent")
        }
        return renderComponent
    }

    var physicsComponent: PhysicsComponent {
        guard let physicsComponent = component(ofType: PhysicsComponent.self) else {
            fatalError("An AsteroidBelt must have a PhysicsComponent")
        }
        return physicsComponent
    }

    // MARK: Initialization

    override init() {
        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: "Images/asteroidBelt"))
        addComponent(renderComponent)

        let physicsBody = SKPhysicsBody(rectangleOf: renderComponent.node.size)
        physicsBody.isDynamic = false
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: ColliderType.Obstacle)
        addComponent(physicsComponent)
        
        renderComponent.node.physicsBody = physicsBody
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
