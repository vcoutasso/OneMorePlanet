import GameKit

final class Player: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Player must have a RenderComponent")
        }
        return renderComponent
    }

    var movementComponent: MovementComponent {
        guard let movementComponent = component(ofType: MovementComponent.self) else {
            fatalError("A Player must have a MovementComponent")
        }
        return movementComponent
    }

    var orbitalComponent: OrbitalComponent {
        guard let orbitalComponent = component(ofType: OrbitalComponent.self) else {
            fatalError("A Player must have an OrbitalComponent")
        }
        return orbitalComponent
    }

    var physicsComponent: PhysicsComponent {
        guard let physicsComponent = component(ofType: PhysicsComponent.self) else {
            fatalError("A Player must have a PhysicsComponent")
        }
        return physicsComponent
    }

    // MARK: Initialization

    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        let renderComponent = RenderComponent(texture: texture)
        addComponent(renderComponent)

        let movementComponent = MovementComponent(behavior: nil)
        addComponent(movementComponent)

        let orbitalComponent = OrbitalComponent()
        addComponent(orbitalComponent)

        let physicsBody =  SKPhysicsBody(circleOfRadius: renderComponent.node.frame.width / 2)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: ColliderType.Player)
        addComponent(physicsComponent)
        physicsBody.linearDamping = 0
        renderComponent.node.physicsBody = physicsBody

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
